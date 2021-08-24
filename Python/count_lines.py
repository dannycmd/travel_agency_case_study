# This program prints the number of lines in each of the input data files. The results can be compared against
# the PROC CONTENTS report to check that the number of lines in each dataset matches the number of lines in the input files.

# Enter the path to the root directory
root_directory = r"C:\Users\Graduate July 2021\Documents\Business Analytics Case Study v1.4"

bookings = root_directory + "\SAS\Data\Input\Bookings.csv"
destinations = root_directory + "\SAS\Data\Input\Destinations.csv"
households = root_directory + "\SAS\Data\Input\Households.csv"
loyalty = root_directory + "\SAS\Data\Input\loyalty.dat"

files = [bookings, destinations, households, loyalty]

# Open each file and use a sum generator expression to count the total number of lines
for file in files:
    with open(file) as f:
        print(f"{sum(1 for line in f)} lines in {file}")
