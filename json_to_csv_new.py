import json
import pandas as pd
import urllib.parse

# Load the JSON file
file_path = r"C:\Users\priiy\Downloads\compiled_profiles\compiled_profiles.json"
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Initialize a list to store all flattened profile data
profile_data = []

# Loop through each profile in the JSON file
for profile in data['profiles']:
    # Base profile information
    profile_info = {
        'username': urllib.parse.unquote(profile.get('username', '')),
        'profile_name': profile.get('profile_name', '').encode('utf-8', errors='ignore').decode('utf-8'),
        'location_name': profile.get('Location_Name', '').encode('utf-8', errors='ignore').decode('utf-8')
    }

    # Initialize dictionaries to store numbered experience and education data
    numbered_experience = {}
    numbered_education = {}
    
    # Loop through and number each experience
    for i, exp in enumerate(profile.get('experience', []), start=1):
        numbered_experience[f'{i}_experience_title'] = exp.get('title', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_experience[f'{i}_experience_company_name'] = exp.get('company_name', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_experience[f'{i}_experience_location'] = exp.get('location', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_experience[f'{i}_experience_start_date'] = exp.get('start_date', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_experience[f'{i}_experience_end_date'] = exp.get('end_date', '').encode('utf-8', errors='ignore').decode('utf-8')

    # Loop through and number each education
    for i, edu in enumerate(profile.get('education', []), start=1):
        numbered_education[f'{i}_education_degree'] = edu.get('degree', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_education[f'{i}_education_institution'] = edu.get('institution', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_education[f'{i}_education_start_date'] = edu.get('start_date', '').encode('utf-8', errors='ignore').decode('utf-8')
        numbered_education[f'{i}_education_end_date'] = edu.get('end_date', '').encode('utf-8', errors='ignore').decode('utf-8')

    # Combine all data into one dictionary for the profile, with experiences first
    combined_data = {**profile_info, **numbered_experience, **numbered_education}
    profile_data.append(combined_data)

# Create a DataFrame with the combined data
profile_df = pd.DataFrame(profile_data)

# Reorder the columns so that all experience columns appear before education columns
experience_cols = [col for col in profile_df.columns if '_experience_' in col]
education_cols = [col for col in profile_df.columns if '_education_' in col]
base_cols = ['username', 'profile_name', 'location_name']

# Rearranging the DataFrame columns
profile_df = profile_df[base_cols + experience_cols + education_cols]

# Save the DataFrame to a CSV file with proper encoding
output_file_path = r"C:\Users\priiy\Downloads\compiled_profiles\compiled_profiles.csv"
profile_df.to_csv(output_file_path, index=False, encoding='utf-8-sig')  # Use utf-8-sig for better compatibility

print(f"CSV file has been saved to {output_file_path}")
