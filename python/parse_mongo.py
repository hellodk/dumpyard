import datetime
from datetime import datetime as dt
from datetime import timedelta
from pymongo import MongoClient
import csv
import time


database_name = "notifications"
collection_name = "feedbacks"
host = "192.168.30.2"
port = 27017

csv_file = 'feedbacks-' + time.strftime("%Y%m%d") + ".csv"


def get_db_connection(database_name, host, port):
    '''
    Returns database client object
    '''
    client = MongoClient(host, port)
    return client[database_name]


def get_data():
    '''
    Scans through mongo db and returns back
    menu to the caller
    '''
    data = []
    db = get_db_connection(database_name, host, port)
    today = dt.utcnow()
    yesterday = dt.now() - timedelta(days=1)
    print(type(today), type(yesterday), type(yesterday))
    print('today', today)
    print('yesterday', yesterday)
    filter = {"date": {"$lte": today, "$gte": yesterday}}
    try:
        cursor = db[collection_name].find(filter, {'_id': 0, })  # 'date': 0})
        print(cursor.count())
    except Exception as ex:
        print("Exception during query execution", ex)
    for values in cursor:
        print(values)
        data.append(values)
    return data


def generate_csv(data, csv_file):
    '''
    Accepts a list of dictionaries and parses them
    to csv file
    '''
    print("The file name is ", csv_file)
    if (len(data) == 0):
        return None
    keys = data[0].keys()
    print("Keys are ", keys)
    with open(csv_file, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(data)


filtered_data = get_data()
generate_csv(filtered_data, csv_file)
