import os
from supabase import create_client, Client

SUPABASE_URL = os.environ.get("SUPABASE_URL", "").strip()
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "").strip()

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required.")

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
