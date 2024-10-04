import pandas as pd

# Read the CSV files into DataFrames
df1 = pd.read_csv(r"C:\Users\priiy\Downloads\SCRAPING\json\iscte\2015_misc\iscte_2015_final.csv")
df2 = pd.read_csv(r"C:\Users\priiy\Downloads\SCRAPING\excel_profiles\iscte\2015\iscte_combined_2015.csv")

# Find the common usernames present in both df1 and df2
common_usernames = df1[df1['username'].isin(df2['username'])]

# Keep only the 'username' column (optional: if you only want to store usernames)
common_usernames_only = common_usernames[['username']]

# Write the result to a new CSV file
common_usernames_only.to_csv(r'C:\Users\priiy\Downloads\iscte_common_userrr.csv', index=False)

