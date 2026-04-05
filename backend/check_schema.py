import os
import httpx
import asyncio
from dotenv import load_dotenv

load_dotenv()

async def check_schema():
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_ANON_KEY")
    if not url or not key:
        print("Missing SUPABASE_URL or SUPABASE_ANON_KEY")
        return

    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}"
    }

    async with httpx.AsyncClient() as client:
        print("--- Pharmacies Table ---")
        try:
            r = await client.get(f"{url}/rest/v1/pharmacies?limit=1", headers=headers)
            print(r.json())
        except Exception as e:
            print(f"Error fetching pharmacies: {e}")

        print("\n--- Inventory Table ---")
        try:
            r = await client.get(f"{url}/rest/v1/inventory?limit=1", headers=headers)
            print(r.json())
        except Exception as e:
            print(f"Error fetching inventory: {e}")

if __name__ == "__main__":
    asyncio.run(check_schema())
