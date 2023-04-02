import os
from os import listdir
from os.path import isfile, join

def remove_numbers(filename):
    """
    Removes numbers from the file name until the first alphabet is found.
    """
    for i, char in enumerate(filename):
        if char.isalpha():
            return filename[i:]
    return filename


mypath = "/home/dk/rename"
onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]

for filename in onlyfiles:
    new_filename = remove_numbers(filename)
    os.rename(filename, new_filename)
    print(f"Renamed {filename} to {new_filename}")

print ("Ho gaya bhai ")

