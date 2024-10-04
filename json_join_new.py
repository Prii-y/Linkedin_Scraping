import os
import json

def read_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def merge_json_files(directory_path, output_file_path):
    all_profiles = []

    # Loop through all files in the directory
    for filename in os.listdir(directory_path):
        if filename.endswith('.json'):
            file_path = os.path.join(directory_path, filename)
            data = read_json(file_path)

            # Ensure 'profiles' key exists and is a list
            if 'profiles' in data and isinstance(data['profiles'], list):
                all_profiles.extend(data['profiles'])

    # Write the combined profiles to a new JSON file
    with open(output_file_path, 'w', encoding='utf-8') as output_file:
        json.dump({'profiles': all_profiles}, output_file, ensure_ascii=False, indent=4)

# Paths to the input directory and output file
input_directory_path = r"C:\Users\priiy\Downloads\compiled_profiles"
output_json_path = r"C:\Users\priiy\Downloads\compiled_profiles\compiled_profiles.json"

# Merge the JSON files
merge_json_files(input_directory_path, output_json_path)

print(f"JSON files merged into {output_json_path}")
