import pandas as pd
import requests
from datetime import datetime
import os
import sys
from dotenv import load_dotenv

load_dotenv()

def create_dataframe():
    """Create a DataFrame and return it"""
    df = pd.DataFrame({
        "Name": ["Alice", "Bob", "Charlie"],
        "Age": [25, 30, 35]
    })
    df["Age_after_5_years"] = df["Age"] + 5
    print(df)
    print("-" * 40)
    return df

def send_discord_notification(df, environment="Unknown"):
    """Send Discord notification with DataFrame info"""
    webhook_url = os.getenv("DISCORD_WEBHOOK_URL")
    
    if not webhook_url:
        print("⚠️ Warning: DISCORD_WEBHOOK_URL not set")
        return False
    
    message = f"""
🎉 **Application Deployed Successfully!** 

⏰ **Time:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
🌍 **Environment:** {environment}
🐳 **Platform:** Docker + Kubernetes

📊 **DataFrame Created:**
- Total Records: {len(df)}
- Columns: {', '.join(df.columns.tolist())}
- People: {', '.join(df['Name'].tolist())}

✅ **Status:** All operations completed successfully!
    """
    
    data = {"content": message.strip()}
    
    try:
        response = requests.post(webhook_url, json=data, timeout=10)
        if response.status_code == 204:
            print("✅ Discord notification sent successfully!")
            return True
        else:
            print(f"⚠️ Discord failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Starting application...")
    df = create_dataframe()
    
    if df is not None:
        env = os.getenv("ENVIRONMENT", "Kubernetes")
        send_discord_notification(df, env)
        print("\n🎊 App execution completed!")
        sys.exit(0)
    else:
        print("\n❌ App failed!")
        sys.exit(1)
