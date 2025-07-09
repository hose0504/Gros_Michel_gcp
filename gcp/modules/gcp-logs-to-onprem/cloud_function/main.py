import base64
import os
import requests
from datetime import datetime

ONPREM_API_URL = os.environ.get("ONPREM_API_URL")

def lambda_handler(event, context):
    try:
        if 'data' in event:
            decoded_data = base64.b64decode(event['data']).decode('utf-8')
            print(f"✅ Received Pub/Sub message: {decoded_data}")
        else:
            print("⚠️ No data in event")
            decoded_data = None

        log_entry = {
            "source": "gcp",  # 👈 추가
            "timestamp": datetime.utcnow().isoformat(),
            "data": decoded_data
        }

        resp = requests.post(
            ONPREM_API_URL,
            json=log_entry,
            headers={"X-Log-Source": "gcp"},  # 👈 헤더도 추가
            timeout=5
        )
        resp.raise_for_status()
        print(f"🚀 Sent to on-prem: {log_entry}")
        return "Success"

    except Exception as e:
        print(f"❌ Error: {e}")
        raise
