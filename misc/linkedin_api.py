import pandas as pd
from linkedin_api import Linkedin
import json
import time
import random

# Load the CSV file
df = pd.read_csv(r"C:\Users\priiy\Downloads\SCRAPING\profiles\iseg\new_combined_iseg.csv")

# Extract the LinkedIn usernames from the URLs
df['username'] = df['LinkedIn URL'].str.extract(r'https://www\.linkedin\.com/in/([^?]+)')
# print(df.iloc[:10])


# Authenticate with LinkedIn
# api = Linkedin('miguel.e.nunes@outlook.com', '14171907Mn&')
api = Linkedin('priyanshu.yadav.152@gmail.com', 'Priyanshu@152')
# api = Linkedin('miguelitoen@gmail.com', '14171907Mn?')
def fetch_profile_data(api, profile_name):
    try:
        profile_data = api.get_profile(profile_name)
        return profile_data
    except Exception as e:
        print(f"Error fetching profile for {profile_name}: {e}")
        return None

profile_data_list = []
error_profiles = []  # List to store profile links that encounter errors
interaction_count = 0

# Access elements from index 350 to the end of the DataFrame
for profile_name in df['username']:
    profile_data = fetch_profile_data(api, profile_name)
    interaction_count += 1
    print(f'Data Fetched: {interaction_count}')
    if profile_data:
        profile_data_list.append(profile_data)
    else:
        profile_link = f"https://www.linkedin.com/in/{profile_name}"
        error_profiles.append(profile_link)

    # Introduce a random delay between 3 and 10 seconds
    time.sleep(random.uniform(3, 10))

# Convert the profile data to JSON and save it to a file
profile_data_json = json.dumps(profile_data_list, indent=4, ensure_ascii=False)

json_file_path = r'C:\Users\priiy\Downloads\SCRAPING\json\catolica\catolica_errors.json'
with open(json_file_path, 'w', encoding='utf-8') as json_file:
    json_file.write(profile_data_json)

# Print the profiles that encountered errors
print("Profiles that encountered errors:")
for profile_link in error_profiles:
    print(profile_link)
