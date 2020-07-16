import datetime
from datetime import date
from datetime import timedelta
from datetime import datetime as dt
from pymongo import MongoClient
import csv
import time

# {'date': {$lt: new Date()}} --> working
# {'date': {$gte: {$subtract : [new Date(), (1000*3600*24*20)]}}}
'''
isoformat()
'''

# Get today's date
today = date.today()
print("Today is: ", today)

# Yesterday date
yesterday = today - timedelta(days=1)
print("Yesterday was: ", yesterday)

print(datetime.date.today())

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
    filter = {'date': {'$lt': dt.utcnow()},}
    today = dt.utcnow()
    yesterday = datetime.date.today() - datetime.timedelta(2)

    yesterday1 = dt.combine(yesterday, dt.min.time())

    print(type(today), type(yesterday), type(yesterday1))
    print('today', today)
    print('yesterday', yesterday)
    # datetime.date.today()-datetime.timedelta(1)
    # filter = {'date': {'$lt': datetime.utcnow()}, {'$gt': datetime.today() - timedelta(days=1)}}
    # filter = {'date': {'$lt': dt.utcnow()}, {'$gt': t}}
    filter = {"date": {"$lte": today, "$gte": yesterday1}}
    # filter = {"date": {"$lt": today}}
    try:
        cursor = db[collection_name].find(filter, {'_id': 0, }) #'date': 0})

        # cursor = db[collection_name].find(
        #     {"date": {"$gte": datetime.datetime(yesterday),
        #               "$lte": datetime.datetime(today)}},
        #     {'_id': 0})

        # cursor = db[collection_name].find(
        #     {"date": {"$gte": datetime(yesterday),
        #               "$lte": datetime(today)}},
        #     {'_id': 0})

        # f1 = {'date': {'$gte': datetime(2019, 6, 7, 0, 0, 0, tzinfo=timezone.utc), '$lt': datetime(2020, 5, 6, 0, 0, 0, tzinfo=timezone.utc)}}
        # cursor = db[collection_name].find({}, {'_id': 0, 'date': 0}) # working
        # print("Got the cursor")
        print(cursor.count())
        # print(dir(cursor))
    except Exception as ex:
        date1 = datetime.datetime.utcnow() - datetime.timedelta(minutes=15)
        for cursor in db[collection_name].find({'date': {'$gte': date1}}):
            print(cursor)
        print("Exception during query execution", ex)
    for values in cursor:
        print(values)
        data.append(values)
        # print(values['feedbacks'])
    #     print("Values ", values)
    #     for elem in values['feedbacks']:
    #         print(elem)
    #         print(type(elem))
    # print("Data is \n", data, type(data))
    return data


def generate_csv(data, csv_file):
    '''
    Accepts a list of dictionaries and parses them
    to csv file
    '''
    print("The file name is ", csv_file)
    keys = data[0].keys()
    print("Keys are ", keys)
    with open(csv_file, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys)
        dict_writer.writeheader()
        dict_writer.writerows(data)


filtered_data = get_data()
generate_csv(filtered_data, csv_file)
