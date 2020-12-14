# Library Database System

This project is part of a database systems coursework taught at the Queen Mary University of London Electrical Engineering & Computer Science Department to create a simple MySQL database based on the following scenario:

“A college library provides various resources for students and staff, including books, videos, DVDs, and CDs. Commonly, several copies are kept of some resources, for example, recommended books for courses. The usual loan period of a resource is two weeks, but some resources are available for short loan only (2 days), and some other resources can only be used within the library. The library consists of 3 floors. Resources are stored in the library on the shelves. A combination of floor number and shelf number is used to locate a specific item in the library. In addition to this, a class number system is used to identify in which subject area a particular item belongs; for example, all resources concerned with Database Systems will have the same class number. Students hold library cards that identify them as valid members of the library. Students can loan a number of different resources at one time, but the total number of resources they may borrow at a given time must never exceed 5. Staff members at the College also hold library cards and are allowed to loan up to 10 different items at one time. The library charges a fine for resources that are loaned for longer than the time allowed for that resource. For each day a resource is overdue; the member is fined one dollar. When the amount owed in fines by a member is more than 10 dollars, that member is suspended until all resources have been returned and all fines paid in full” (Tony Stockman, 2020).

## Relational Database Schema ##
The image below shows the structure of the database in a relational databse schema.

![alt text](https://github.com/hauni97/Library_Database_System/blob/main/Relational_Schema/%20Library_Final_3NF.png)


## Relational Database Schema ##
Additional larger sets of data to test the database can be created with [mockaroo](https://www.mockaroo.com/) 
To comply with the restraints in the database; it is advisable to generate additional data with regex; for instance, a suggested Username and Email_Address formula may be:

| Field Name |   Regex Code Example in [Mockaroo formula syntax](https://www.mockaroo.com/help/formulas)    |
| ------------- | ------------- |
| Email_Address  | lower("#{field('First_Name')}.#{field('Last_Name')}@qmul.ac.uk")  |
| Username  | lower("#{field('Last_Name')[0,3]}#{field('First_Name')[0,3]}")    |


