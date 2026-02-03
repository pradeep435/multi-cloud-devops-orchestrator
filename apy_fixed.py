from flask import Flask
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return f"Multi-Cloud App running on host: {socket.gethostname()}"

@app.route("/health")
def health():
    return {"status": "UP"}

@app.route("/metrics")
def metrics():
    return "app_up 1\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
