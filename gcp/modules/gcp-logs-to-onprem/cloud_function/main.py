import base64
import os
import requests
from datetime import datetime

ONPREM_API_URL = os.environ.get("ONPREM_API_URL")

def lambda_handler(event, context):
    try:
        # Pub/Sub는 Base64로 인코딩된 데이터가 들어옴
        if 'data' in event:
            decoded_data = base64.b64decode(event['data']).decode('utf-8')
            print(f"✅ Received Pub/Sub message: {decoded_data}")
        else:
            print("⚠️ No data in event")
            decoded_data = None

        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "data": decoded_data
        }

        # 온프레미스로 전송
        resp = requests.post(
            ONPREM_API_URL,
            json=log_entry,
            timeout=5
        )
        resp.raise_for_status()
        print(f"🚀 Sent to on-prem: {log_entry}")
        return "Success"

    except Exception as e:
        print(f"❌ Error: {e}")
        raise
