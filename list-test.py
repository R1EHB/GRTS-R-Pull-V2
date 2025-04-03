import csv


infile_name = './DataInput/HUC12NewEnglandvector.csv'
# filereader = csv.DictReader(infile_name, delimiter = ',', quotechar='"')
# filereader = open (infile_name, "r")

with open (infile_name, newline='') as csvfile:
    filereader = csv.DictReader(csvfile)
    
    for row in filereader:
        print (row)


