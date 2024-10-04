import json
import os

# Specify the path to the folder containing the JSON file
folder_path = r"C:\Users\priiy\Downloads\compiled_profiles"  # Replace with the correct folder path
file_name = 'compiled_profiles.json'      # Replace with the correct JSON file name

# Full path to the JSON filer
file_path = os.path.join(folder_path, file_name)

# Open and read the JSON file
with open(file_path, 'r', encoding='utf-8') as file:
    data = json.load(file)

# Count the number of profiles in the "profiles" array
num_of_profiles = len(data["profiles"])

# Output the result
print(f'The number of profiles: {num_of_profiles}')

