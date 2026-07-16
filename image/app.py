from flask import Flask, jsonify
import os
import logging

LOG_DIR = os.environ.get("LOG_DIR", "/logs")
os.makedirs(LOG_DIR, exist_ok=True)

logging.basicConfig(
    filename=os.path.join(LOG_DIR, "app.log"),
    level=logging.INFO,
    format="%(asctime)s %(message)s"
)

app = Flask(__name__)

@app.route('/health')
def health():
  return 'OK' , 200

@app.route('/')
def index():
  app_mode = os.environ.get('APP_MODE' , 'unknown')
  return f'Audit Notes Service [{app_mode}]' , 200

@app.route('/secret-check')
@app.route('/secret_check')
def secret_check():
  secret = os.environ.get('API_TOKEN')
  if secret:
    return 'API_TOKEN exists: YES' , 200
  return 'API_TOKEN exists: NO' , 200
@app.route('/config')
def config():
  return jsonify({
    'APP_MODE': os.environ.get('APP_MODE' , 'unknown'),
    'MESSAGE': os.environ.get('MESSAGE' , 'no message'),
    'DATA_PATH': os.environ.get('DATA_PATH' , '/data/message.txt')
  }) , 200

@app.route('/logs')
def logs():
  logging.info('Logs endpoint called')
  return 'Log event written' , 200

@app.route('/write')
def write():
  path = os.environ.get('DATA_PATH' , '/data/message.txt')
  logging.info(f'Write called, path={path}')
  try:
    os.makedirs(os.path.dirname(path),exist_ok=True)
    with open(path, 'w') as f:
      f.write('Hello from flask running on Kubernetes')
    return f'Written to {path}' , 200
  except Exception as e:
        return f'Error: {str(e)}', 500
@app.route('/read')
def read():
    path = os.environ.get('DATA_PATH', '/data/message.txt')
    try:
        with open(path, 'r') as f:
            return f.read(), 200
    except FileNotFoundError:
        return 'Nothing written yet. Call /write first.', 404
    except Exception as e:
        return f'Error: {str(e)}', 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555)
