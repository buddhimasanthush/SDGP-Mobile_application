import asyncio
import os
from search.pharmacy_search import search_pharmacies_by_names, response_to_dict

# Set these for testing
os.environ["SUPABASE_URL"] = "https://zdgugonfvsadghkijfnh.supabase.co"
os.environ["SUPABASE_ANON_KEY"] = "ey..." # Replace with your real anon key for testing

async def test_search():
    print("Testing Multi-Database Search...")
    
    # Mocking a search for Paracetamol
    medicines = [{"drug_name": "Paracetamol", "quantity": 10}]
    
    # User's location (Negombo)
    lat, lng = 7.2111, 79.8400
    
    try:
        response = await search_pharmacies_by_names(lat, lng, medicines)
        results = response_to_dict(response)
        
        print("\nSearch Results:")
        if results["best_match"]:
            print(f"Best Match: {results['best_match']['pharmacy_name']}")
        
        print(f"Partial Matches Found: {len(results['partial_matches'])}")
        for p in results['partial_matches']:
            print(f"- {p['pharmacy_name']} ({p['distance_meters']}m)")
            
    except Exception as e:
        print(f"Error during test: {e}")

if __name__ == "__main__":
    asyncio.run(test_search())
