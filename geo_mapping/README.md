# MediFind Geo-Mapping

Nearby pharmacy search and geo-mapping logic for the MediFind application.

## Overview

This module handles geolocation-based pharmacy discovery and medicine availability checking for the MediFind backend.

## Files

- `pharmacy_search.py` - Finds nearby pharmacies using geolocation (Google Maps API + Supabase)
- `medicine_resolver.py` - Resolves medicine names and checks availability at nearby pharmacies
- `__init__.py` - Module initialization
- `requirements.txt` - Python dependencies

## Setup

Configure the following in your `.env` file:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Your Supabase service key
- `GOOGLE_MAPS_API_KEY` - Google Maps Geocoding API key

## Usage

The pharmacy_search module is called by the FastAPI backend to find pharmacies
near a given location and check medicine stock availability.
