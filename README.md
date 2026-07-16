<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=26&pause=1000&color=00E5FF&center=true&vCenter=true&width=700&lines=☁️+Audit+Notes+Service+-+Cloud;From+localhost+→+to+AWS+EKS;Terraform+%2B+Kubernetes+%2B+CI%2FCD" alt="Header" />
</div>

<br>

<div align="center">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/AWS_EKS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" height="30">
</div>

<br>

---

## 🙋 What is this project, really?

This repo is the **next step** after [audit-notes-service](https://github.com/mihai-minascurta/audit-notes-service), which ran locally, on my own laptop, using `kind` and `kubectl`.

That first project proved the app and the Kubernetes setup actually worked. This one asks a different question:

> "Okay, it works on my laptop. But how do I make it run in the cloud, the way a real company would, where nobody clicks buttons by hand and everything is built from code instead?"

So I took the same app (didn't touch it) and built everything that was missing to make it work like a real, cloud version:
- a real network in AWS (a VPC),
- a real managed Kubernetes cluster (EKS), not a local one,
- real access from the internet (a Load Balancer),
- real persistent storage (EBS),
- and automation with Terraform and GitHub Actions.

Basically: the local project was "building a small prototype on your desk". This one is "building the actual factory".

---

## 🧠 What I left out on purpose (and why)

In the local project, the pipeline built the Docker image, tested it, and pushed it to a registry (GHCR).

**I didn't do that here.** This repo assumes the image already exists and is already published somewhere. The reason is simple: here I want to focus 100% on the **infrastructure** side — I didn't want to mix "how do I build the app" with "how do I build the cloud part". So the deploy workflow in this repo just **grabs** the already-built image and installs it on the cluster.

This is a split you see a lot on real teams: one team/pipeline handles the app, another handles the infrastructure. I basically copied that same boundary here.

---

## 🧩 The main pieces, explained simply

### 1️⃣ Terraform — the "building plan"
Instead of clicking around in the AWS console (network, cluster, permissions, etc.), I wrote everything that needs to exist as code. That way I can delete everything and rebuild it exactly the same, from scratch, anytime.

### 2️⃣ The Network (VPC)
A Kubernetes cluster in the cloud doesn't just float in empty space — it needs a network. I built:
- **public** subnets (where traffic from the internet comes in),
- **private** subnets (where the actual machines running the app live, hidden from the internet).

### 3️⃣ EKS — the "managed" Kubernetes cluster
Instead of installing and maintaining Kubernetes myself from scratch, AWS gives me a cluster that's already managed. I just add the machines (worker nodes) that will run the app.

### 4️⃣ ALB Controller — this one gave me a hard time 😅
For the app to be reachable from the internet, you need a Load Balancer. The problem: Kubernetes doesn't know by itself how to create a Load Balancer in AWS — it needs a "translator" between an Ingress (Kubernetes) and AWS. That translator is the ALB Controller.

This is where I ran into the most trouble: wrong permissions, roles that weren't connecting properly to the right service account, incomplete policies. I still don't fully understand every detail of the mechanism behind it (called IRSA — how exactly an AWS permission gets linked to a specific pod), but I did get it working, and I used **AI help** along the way to understand where exactly my permissions were wrong.

### 5️⃣ EBS CSI Driver — round two of the same fight
For the app to save data that survives a restart, it needs EBS storage volumes. Just like with the ALB, Kubernetes doesn't know how to create these volumes by itself — it needs a driver, and that driver needs the right permissions set up correctly too.

Same story here: I debugged volumes stuck in a "Pending" state, pods that wouldn't start because a volume couldn't attach, and permissions that were missing small but important pieces — again with help from AI to figure out exactly what was missing.

### 6️⃣ IAM — the part I understand the least, honestly
IAM (deciding who's allowed to do what in AWS) is the part I feel I still have the most to learn about. I have separate permission sets for: the EKS cluster itself, the worker machines, GitHub Actions, the ALB Controller, and the EBS driver — each one only gets exactly what it needs, nothing more. It works, but I'll be honest, I don't have full intuition for it yet, especially the part about OIDC (how GitHub Actions gets access to AWS without using fixed, permanent keys).

---

## 🔘 Why the workflows start with a button, not automatically on push

Normally, in a real project, you'd want a `git push` to automatically trigger everything: infrastructure + deploy. Here, I did that **on purpose**. The workflows (`bootstrap`, `backend`, `infra`, `deploy`, `destroy`) all start manually, from GitHub, using `workflow_dispatch`.

Why?
- creating or destroying infrastructure in AWS **costs real money** — I don't want an accidental push to create or delete a whole cluster by mistake;
- the infrastructure has to happen in a strict order (backend → bootstrap → infra → deploy), and running it automatically risks trying to deploy to a cluster that doesn't exist yet;
- since this is a learning project, I wanted full control over **when** each step happens, so I can actually watch what each piece does on its own.

In a real production setup, I would automate:
- `infra.yml` when merging to an infrastructure branch (with a manual approval step before `apply`, using GitHub's environment protection rules),
- `deploy.yml` automatically whenever a new image gets published (which is exactly where the local project, `audit-notes-service`, leaves off),
- and I'd keep `destroy.yml` manual forever, with a confirmation step — you never want something deleting your infrastructure by accident.

---

## 🔄 How the full deploy should ideally look, start to finish

```text
1. [Local repo] audit-notes-service
      → code, tests, build image, push to GHCR
                    │
                    ▼
2. [This repo] terraform apply (once, or whenever infra changes)
      → VPC, EKS, permissions, ALB Controller, EBS driver
                    │
                    ▼
3. deploy.yml workflow (manual button now, ideally automatic on new image)
      → helm upgrade --install, using the image tag from GHCR
                    │
                    ▼
4. Ingress + ALB Controller
      → automatically creates a real Load Balancer in AWS
                    │
                    ▼
5. Traffic from the internet reaches the Load Balancer → Service → Pod
                    │
                    ▼
6. The app saves notes on an EBS volume, mounted through a PVC
      → data survives even if the pod restarts
```

If any step above is missing (network, permissions, driver), the whole chain breaks somewhere — and this is exactly where I spent most of my debugging time, especially on steps 2 and 4.

---

## 🗂️ Folder structure, quick view

```text
├── helm/            ← the "instructions" for Kubernetes (deployment, service, ingress, pvc...)
├── terraform/
│   ├── environments/  ← backend, bootstrap, dev (the actual environments)
│   └── modules/       ← networking, iam, cluster, workers, ebs-csi, alb-controller, github-actions
├── tests/           ← tests for the app
└── workflows/       ← bootstrap → backend → infra → deploy → destroy (buttons, not automatic)
```

---

## 🎓 What I learned (and what I honestly still don't fully get)

What I understand well: the VPC network, how Terraform is split into modules, Helm, and how traffic flows from Ingress down to a Pod.

What I'm still working on: the finer details of IAM Roles for Service Accounts (how exactly a pod gets linked to a permission set), and why the ALB Controller and EBS driver need such specific policies. For both of these, I used **AI help**, mostly for debugging — to understand why a role wasn't connecting properly, or why a volume was stuck — not to generate the infrastructure for me, but to help me see exactly where I was going wrong.

---

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=13&pause=2000&color=39FF14&center=true&vCenter=true&width=600&lines=local+🖥️+→+cloud+☁️+→+still+learning+📚" alt="Footer" />
</div>

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=13&pause=2000&color=39FF14&center=true&vCenter=true&width=600&lines=local+🖥️+→+cloud+☁️+→+still+learning+📚" alt="Footer" />
</div>
