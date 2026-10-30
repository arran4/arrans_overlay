import urllib.request
import json
import re
import subprocess
import os

def get_latest_release():
    url = "https://api.github.com/repos/arran4/klookup/releases"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                if data and isinstance(data, list):
                    return data[0].get("tag_name")
    except Exception as e:
        print(f"Error fetching releases: {e}")
    return None

if __name__ == "__main__":
    release = get_latest_release()
    print(f"Latest release: {release}")
    if release:
        # In the future this will generate versioned ebuilds when releases exist
        pass
