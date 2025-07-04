from flask import Flask, request, jsonify
import requests
import os
from datetime import datetime

app = Flask(__name__)

ONPREM_API_URL = os.environ.get("ONPREM_API_URL")

@app.route("/", methods=["POST"])
def lambda_handler():
    try:
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "data": request.json
        }

        # 온프레미스로 로그 전송
        resp = requests.post(
            ONPREM_API_URL,
            json=log_entry,
            timeout=5
        )
        resp.raise_for_status()

        print(f"✅ Sent to on-prem: {log_entry}")
        return jsonify({"status": "success"}), 200

    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500
