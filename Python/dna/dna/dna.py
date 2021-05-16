import csv
import cs50
import sys
import collections


def main(argv):
    # open and read csv (database)
    with open(argv[1], newline='') as csvfile:
        database = csv.DictReader(csvfile, delimiter=',')
        # create list of field names and remove name column
        dnaFields = database.fieldnames
        csvList = list(database)
        dnaFields.remove("name")

    # open and read DNA sequence
    with open(argv[2], newline='') as textfile:
        dnaFile = textfile.read()

    # returns dictionary with STR counts for each sequence
    textDict = compareSTR(dnaFields, dnaFile)
    # compare dictionary with csv, prints either the name of who the match is or prints
    # 'No match'
    compareDict(textDict, csvList)

# function to compare STR


def compareSTR(dnaField, dnaFile):
    # number of STRs in set, 3 for small, 8 for large
    strNum = len(dnaField)
    # store match counts in dictionary with STR keys
    matchList = {}

    # for each STR in dataset (3 or 8 times)
    for STR in dnaField:
        # instantiate matchList STR keys with a 0 value
        matchList.update({STR: 0})
        # for each letter in the file # source: https://stackoverflow.com/questions/522563/accessing-the-index-in-for-loops
        for index, char in enumerate(dnaFile):
            # keep track of current position
            n = index
            substring = dnaFile[n: n + len(STR)]
            matches = 0
            while (substring == STR):
                matches += 1
                n += len(STR)
                substring = dnaFile[n: n + len(STR)]
                #print(f"Inside: {substring}")
            # insert match count
            if (matchList.get(STR) <= matches):
                matchList.update({STR: matches})

    return matchList


# function to compare csv with text. d1 is data, d2 is dictionary returned from
# compareSTR
def compareDict(text, csv):
    i = 0
    matches = 0
    # loop for each person in csv file
    while i < len(csv):
        # loop for each STR in text
        for sequence in text:
            # compare integer key values. Have to cast the string to int
            if (text[sequence] == int(csv[i][sequence])):
                matches += 1
                # if number of matches are equal to the number of STR sequences
                if (matches == len(text)):
                    print(csv[i]['name'])
                    return
            # reset match counts to 0 if there's any STR mismatches
            else:
                matches = 0
        i += 1
    print("No match")


main(sys.argv)