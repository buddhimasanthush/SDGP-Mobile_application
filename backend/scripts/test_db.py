import os
from supabase import create_client, Client

SUPABASE_URL = "https://zdgugonfvsadghkijfnh.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkZ3Vnb25mdnNhZGdoa2lqZm5oIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjQ4MjI5NSwiZXhwIjoyMDU4MDY2Mjk1fQ.X2xheN0eIixP5MrtC1fOf2kK_-J8Ecl3T-_6N4aK8zU"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

try:
    print("Fetching users...")
    response = supabase.auth.admin.list_users()
    users = response
    
    missing_profiles = 0
    for user in users:
        existing_profile = supabase.table("profiles").select("id").eq("id", user.id).execute()
        
        if len(existing_profile.data) == 0:
            print(f"User {user.email} ({user.id}) is missing a profile. Backfilling...")
            missing_profiles += 1
            try:
                supabase.table("profiles").insert({
                    "id": user.id,
                    "email": user.email,
                    "full_name": "User",
                    "role": "patient",
                    "has_completed_onboarding": False
                }).execute()
                print(f"  -> Successfully created profile for {user.email}")
            except Exception as e:
                print(f"  -> Failed to create profile: {e}")
        else:
            pass # Profile exists
            
    print(f"\nChecked all users. Missing profiles fixed: {missing_profiles}")
except Exception as e:
    print(f"Error: {e}")
