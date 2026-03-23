import os
from supabase import create_client, Client

SUPABASE_URL = "https://zdgugonfvsadghkijfnh.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkZ3Vnb25mdnNhZGdoa2lqZm5oIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjQ4MjI5NSwiZXhwIjoyMDU4MDY2Mjk1fQ.X2xheN0eIixP5MrtC1fOf2kK_-J8Ecl3T-_6N4aK8zU"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

try:
    print("Fetching users...")
    # Get all users using the admin API
    response = supabase.auth.admin.list_users()
    users = response
    
    for user in users:
        print(f"Checking profile for user: {user.email} ({user.id})")
        
        # Check if profile exists
        existing_profile = supabase.table("profiles").select("id").eq("id", user.id).execute()
        
        if len(existing_profile.data) == 0:
            print(f"  -> Profile missing. Creating backfill profile...")
            # Create a fake profile to satisfy FK constraints
            try:
                supabase.table("profiles").insert({
                    "id": user.id,
                    "email": user.email,
                    "role": "patient",
                    "has_completed_onboarding": False
                }).execute()
                print(f"  -> Successfully created profile for {user.email}")
            except Exception as e:
                print(f"  -> Failed to create profile: {e}")
        else:
            print(f"  -> Profile already exists.")
            
    print("\nBackfill operation complete.")
except Exception as e:
    print(f"Error: {e}")
