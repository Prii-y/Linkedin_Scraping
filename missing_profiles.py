import pandas as pd

# Read the CSV files into DataFrames
df1 = pd.read_csv(r"C:\Users\priiy\Downloads\SCRAPING\excel_profiles\iscte_bschool\2015\iscte_bschool_combined_2015.csv")
df2 = pd.read_csv(r"C:\Users\priiy\Downloads\SCRAPING\json\iscte_bschool\iscte_bschool_2015_final.csv")

# Find the usernames present in df1 and not in df2
# Assuming the column containing usernames is called 'username'
diff_usernames = df1[~df1['username'].isin(df2['username'])]

# Optionally, write the result to a new CSV file
diff_usernames.to_csv(r"C:\Users\priiy\Downloads\missing.csv", index=False)

# Display the result
print(diff_usernames)
