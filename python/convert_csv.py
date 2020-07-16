import csv

csv_columns = ['No', 'Name', 'Country']
dict_data = [
    {'No': 1, 'Name': 'Alex', 'Country': 'India'},
    {'No': 2, 'Name': 'Ben', 'Country': 'USA'},
    {'No': 3, 'Name': 'Shri Ram', 'Country': 'India'},
    {'No': 4, 'Name': 'Smith', 'Country': 'USA'},
    {'No': 5, 'Name': 'Yuva Raj', 'Country': 'India'},
    {'No': 6, 'Name': 'Deepak', 'Country': 'Brazil', 'Type': 'Testing'},
    # {'No': 7, 'Name': 'Deep', 'Country': 'Srilanka', 'Type': 'Demo', 'Here': 'There'},
    # {'No': 8, 'Name': 'Yuva', 'Country': 'Japan'},
    # {'No': 9, 'Name': 'Pampa', 'Country': 'India', 'Occupation': 'Doctor'},
    # {'No': 10, 'Name': 'Dimple', 'Occupation': 'IT', 'Type': 'Testing', 'Country': 'India', 'Occupation': 'Doctor'},
]
csv_file = "Names.csv"
try:
    with open(csv_file, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
        writer.writeheader()
        for data in dict_data:
            writer.writerow(data)
except IOError:
    print("I/O error")
