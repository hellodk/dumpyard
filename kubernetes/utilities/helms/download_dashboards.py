import requests
import json
import os
import re

DASHBOARD_IDS = [
    17375, 7187, 11673, 13646, 15762, 11455, 12623, 13042, 22174, 22128, 20842, 14314, 10000, 14588,
    8685, 15760, 15759, 15757, 12006, 17347, 15761, 11001, 3831, 6417, 741, 747, 1471, 3063, 15758,
    12239, 13332, 11454, 6336, 8670, 16696, 13922, 12575, 12680, 12740, 5228, 6663, 10518, 10856,
    5225, 15661, 14055, 928, 12030, 16675, 367, 361, 12056, 12865, 17119, 14361, 12111, 16071, 14359,
    4701, 22108, 8531, 19268, 11802, 1860, 7249, 9614, 12693, 14282, 10557, 19105, 16337, 13502
]

OUTPUT_DIR = "dashboards-custom"

def slugify(value):
    """
    Normalizes string, converts to lowercase, removes non-alpha characters,
    and converts spaces to hyphens.
    """
    value = str(value)
    value = re.sub(r'[^\w\s-]', '', value).strip().lower()
    value = re.sub(r'[-\s]+', '-', value)
    return value

def download_dashboard(dashboard_id):
    url = f"https://grafana.com/api/dashboards/{dashboard_id}/revisions/latest/download"
    try:
        response = requests.get(url)
        response.raise_for_status()
        dashboard_data = response.json()
        
        title = dashboard_data.get('title', 'untitled')
        slug = slugify(title)
        filename = f"{dashboard_id}-{slug}.json"
        filepath = os.path.join(OUTPUT_DIR, filename)
        
        # Ensure we don't double wrap or have issues with the structure
        # Some dashboards might be returned wrapped in a way we need to handle, 
        # but typically the download endpoint returns the JSON model directly or wrapped.
        # It's safer to save exactly what we get unless we know for sure.
        
        with open(filepath, 'w') as f:
            json.dump(dashboard_data, f, indent=2)
            
        print(f"Downloaded: {filename}")
        
    except Exception as e:
        print(f"Failed to download {dashboard_id}: {e}")

def main():
    if not os.path.exists(OUTPUT_DIR):
        print(f"Directory {OUTPUT_DIR} does not exist.")
        return

    print(f"Starting download of {len(DASHBOARD_IDS)} dashboards...")
    for pid in DASHBOARD_IDS:
        download_dashboard(pid)
    print("Download complete.")

if __name__ == "__main__":
    main()
