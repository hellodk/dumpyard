import os

'''
Reference
https://medium.com/devops-challenge/apache-log-parser-using-python-8080fbc41dda

https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/apache_logs/apache_logs

'''

def read_file(file_name):
    '''
    Reads and returns the file contents
    '''
    try:
        with open(file, 'r') as f:
            return f.readlines()
    except Exception as ex:
        print ("Caught in Exception %s" % ex)
        return None


def report(data):
    '''
    Prints the report
    '''
    report = {}
    di1 = {}
    data_served = 0
    for line in data:
        li = elem.split(" ")
        # status_code = int(int(li[8]) / 100)
        status_code = int(li[8])
        data_transferred = li[9]
        if (data_transferred == '-'):
            continue
        if status_code in di.keys():
            report[status_code] = report[status_code] + 1
            di1[status_code] = di1[status_code] + float(size)
    else:
        report[status_code] = 1
        di1[status_code] = float(size)
if __name__ == "__main__":
    print ("Running from main")
