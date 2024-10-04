import os
import json

def read_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def merge_json_files(directory_path, output_file_path):
    all_data = []

    # Loop through all files in the directory
    for filename in os.listdir(directory_path):
        if filename.endswith('.json'):
            file_path = os.path.join(directory_path, filename)
            data = read_json(file_path)
            all_data.extend(data)  # Assuming each file contains a list of records

    # Write the combined data to a new JSON file
    with open(output_file_path, 'w', encoding='utf-8') as output_file:
        json.dump(all_data, output_file, ensure_ascii=False, indent=4)

# Paths to the input directory and output file
input_directory_path = r"C:\Users\priiy\Downloads\compiled_profiles"
output_json_path = r"C:\Users\priiy\Downloads\compiled_profiles\compiled_join.json"

# Merge the JSON files
merge_json_files(input_directory_path, output_json_path)

output_json_path























# import json

# def load_json(file_path):
#     with open(file_path, 'r') as file:
#         return json.load(file)

# def save_json(data, file_path):
#     with open(file_path, 'w') as file:
#         json.dump(data, file, indent=4)

# def join_json_files(file1_path, file2_path, output_path):
#     # Load the JSON data from both files
#     data1 = load_json(file1_path)
#     data2 = load_json(file2_path)
    
#     # Combine the data (assuming both are lists of dictionaries)
#     combined_data = data1 + data2
    
#     # Save the combined data to a new JSON file
#     save_json(combined_data, output_path)

# # Example usage
# file1_path = "C:/Users/priiy/Downloads/SCRAPING/json/nova/nova_1_350.json"
# file2_path = "C:/Users/priiy/Downloads/SCRAPING/json/nova/nova_350_700.json"
# output_path = 'C:/Users/priiy/Downloads/SCRAPING/json/nova/combined.json'

# join_json_files(file1_path, file2_path, output_path)
