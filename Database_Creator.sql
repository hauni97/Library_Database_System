drop table IF EXISTS Loan;
drop table IF EXISTS Member;
drop table IF EXISTS CD;
drop table IF EXISTS Book;
drop table IF EXISTS Film_Studios_List_Film;
drop table IF EXISTS DVD_Video;
drop table IF EXISTS Film;
drop table IF EXISTS Author_ISBN;
drop table IF EXISTS Author;
drop table IF EXISTS ISBN;
drop table IF EXISTS Artist_CD_Name;
drop table IF EXISTS Artist;
drop table IF EXISTS CD_Name;
drop table IF EXISTS Film_Studios_List;
drop table IF EXISTS Country;
drop table IF EXISTS Resource;
drop table IF EXISTS Location;
drop table IF EXISTS Class_Number;
drop table IF EXISTS Department_Number;
drop table if EXISTS Paid_Fines_Record;
drop view if exists `Max loan ability` cascade;

drop view if exists FINES cascade;
drop view if exists `Max loan ability` cascade;
drop view if exists Member_Fines cascade;
drop view if exists `Number of copies of resource available` cascade;
drop view if exists `Outstanding Loans with due date` cascade;
drop view if exists `Overdue Items with Contact Details` cascade;
drop view if exists Popular_Items cascade;
drop view if exists `number of loans by member` cascade;





/*note, some views and columns have been aliased with spaces using special character ` */
/*
ON UPDATE CASCADE MOSTLY UNNECESSARY AS USING AUTO INCREMENTED PRIMARY (FOREIGN) KEYS
*/
CREATE TABLE Member (
    Member_ID SMALLINT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*The unsigned range is 0 to 65535. so max 65k members, more than enough*/
    First_Name varchar(40) NOT NULL,
    Last_Name varchar(40) NOT NULL,
    /* more than enough max length*/
    Email_Address varchar(255) NOT NULL UNIQUE,
    House_Number_or_Name varchar(30),
    /* more than enough max length*/
    Postcode varchar(12),
    /* more than enough max length*/
    Phone_Number varchar(15) NOT NULL UNIQUE,
    /*should store numbers as string characters |SHALL NOT BE NULL, AS IT IS VERIFICATION METHOD*/
    Member_Type varchar(7) NOT NULL,
    /*max length of options*/
    DOB date NOT NULL,
    CHECK (
        (Email_Address like '%@%')
        AND (Email_Address like '%.%')
        AND (Email_Address like '%qmul.ac.uk')
    ),
    /* Checks email address has @, ., qmul.ac.uk in it (only QMUL addressses allowed) */
    CHECK (Member_Type in ('Student', 'Staff'))
);
/*The unsigned range is 0 to 65535. SMALL INT*/
CREATE TABLE Country (
    Country_ID TINYINT(3) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*range is 0 to 255. so max 255, more than enough*/
    Country_Name varchar(50) NOT NULL UNIQUE
    /* more than enough max length*/
);

CREATE TABLE Location (
    Location_ID TINYINT(3) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*range is 0 to 255. so max 255, more than enough*/
    Shelf_No TINYINT(3) UNSIGNED NOT NULL,
    /*range is 0 to 255. so max 255, more than enough*/
    Floor_No TINYINT(1) UNSIGNED NOT NULL,
    CHECK (Floor_No in (0, 1, 2))
    /* Ground is 0, 1st is 1, 2nd is 2  Only 3 floors in library as per spec*/
);

CREATE TABLE Department_Number (
    Dept_No TINYINT(3) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*range is 0 to 255. so max 255, more than enough*/
    Department_Name varchar(50) NOT NULL UNIQUE
    /* more than enough max length*/
);

CREATE TABLE Class_Number (
    Class_ID TINYINT(3) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*range is 0 to 255. so max 255, more than enough*/
    `Subject` varchar(50) NOT NULL UNIQUE,
    /* more than enough max length*/
    Dept_No TINYINT(3) UNSIGNED,
    FOREIGN KEY (Dept_No) REFERENCES Department_Number(Dept_No) ON DELETE SET NULL
    /*SET NULL IF ASSOCIATED DEPARTMENT IS DELETED*/
);

CREATE TABLE Resource (
    Resource_ID SMALLINT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*The unsigned range is 0 to 65535. so max 65k resources, more than enough*/
    Borrowable_Time TINYINT(2) UNSIGNED NOT NULL,
    `Type` varchar(12) NOT NULL,
    /* more than enough max length*/
    No_of_Total_Copies TINYINT(3) UNSIGNED NOT NULL,
    /*range is 0 to 255. so max 255, more than enough*/
    Location_ID TINYINT(3) UNSIGNED,
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID) ON DELETE SET NULL,
    Class_ID TINYINT(3) UNSIGNED,
    FOREIGN KEY (Class_ID) REFERENCES Class_Number(Class_ID) ON DELETE SET NULL,
    CHECK (Borrowable_Time in (0, 2, 14)), 
    /* NUMBER OF DAYS BOOK CAN BE BORROWED FOR */
    CHECK (`Type` in ('Book', 'CD', 'DVD/VIDEO')) 
    /* Three options, DVD/Video distinction will be made later*/
);

CREATE TABLE Loan (
    Loan_ID MEDIUMINT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /* THE unsigned range is 16777215, more than enough */
    Date_Taken_Out date NOT NULL,
    Date_Returned date,
    Date_Paid date,
    Member_ID SMALLINT(5) UNSIGNED,
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID) ON DELETE SET NULL,
    /* IF MEMBER DELETED LOAN INFO STILL STORED, USEFUL FOR POPULARITY OF RESOURCE */
    Resource_ID SMALLINT(5) UNSIGNED,
    FOREIGN KEY (Resource_ID) REFERENCES Resource(Resource_ID) ON DELETE SET NULL,
    /* IF RESOURCE DELETED LOAN INFO STILL STORED, USEFUL FOR MEMBER LOANS AND FINES DETAILS */
    CHECK (Date_Returned >= Date_Taken_Out) /*CAN RETURN ON SAME DAY or after*/
);

CREATE TABLE CD_Name (
    CD_Name_ID SMALLINT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*The unsigned range is 0 to 65535. so max 65k, more than enough*/
    Album_Name varchar(120) NOT NULL,
    Date_Released date,
    Parental_Advisory CHAR(1) NOT NULL,
    /*Y OR N FOR YES OR NO */
    CHECK (Parental_Advisory in ('Y', 'N'))
);

CREATE TABLE Film (
    Film_ID SMALLINT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*The unsigned range is 0 to 65535. so max 65k, more than enough*/
    Film_Name varchar(60) NOT NULL,
    Date_Released date,
    Genre varchar(60) NOT NULL,
    Age_Rating VARCHAR(3) NOT NULL, /* STORED AS A STRING*/
    CHECK (
        Genre in (
            'TV Show', 'Thriller', 'Sports Movie',
            'Sci-fi', 'Romantic Movie', 'Music',
            'Horror', 'Foreign Movie', 'Gay & Lesbian Movie',
            'Drama', 'Crime', 'Faith & Spiritiality',
            'Documentary', 'Cult Movie', 'Comedy',
            'Children & Family', 'Anime', 'Action',
            'Foreign', 'Animation','Action and Adventure'
        )
    ),/* Netflix Genres*/
    CHECK (Age_Rating in ('U', 'PG', '12', '15', '18'))
    /* UK AGE RATINGS*/
);

CREATE TABLE ISBN (
    ISBN VARCHAR(13) PRIMARY KEY,
    /* ISBN STORED AS A STRING WITH DASHES/SPACES REMOVED, ISBN CAN BE 10 OR 13 DIGITS */
    Book_Name varchar(255) NOT NULL,
    /* more than enough max length*/
    Date_Published date,
    CHECK(ISBN REGEXP '^[0-9]+$')
    /*CHECKS ISBN ONLY CONTAINS DIGITS*/
);

CREATE TABLE Author (
    Author_ID SMALLINT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*The unsigned range is 0 to 65535. so max 65k, more than enough*/
    Author_First_Name varchar(50),
    /* more than enough max length*/
    Author_Last_Name varchar(50) NOT NULL,
    /* more than enough max length*/
    Country_ID TINYINT(3) UNSIGNED,
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID) ON DELETE SET NULL
    /*IF COUNTRY DELETED, SET TO NULL*/
);

CREATE TABLE Artist (
    Artist_ID SMALLINT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*The unsigned range is 0 to 65535. so max 65k, more than enough*/
    Artist_Name varchar(75) NOT NULL,
    /* more than enough max length*/
    Country_ID TINYINT(3) UNSIGNED,
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID) ON DELETE SET NULL
    /*IF COUNTRY DELETED, SET TO NULL*/
);

CREATE TABLE Film_Studios_List (
    Film_Studio_ID TINYINT(3) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    /*range is 0 to 255. so max 255, more than enough*/
    Film_Studio_Name varchar(75) NOT NULL,
    /* more than enough max length*/
    Country_ID TINYINT(3) UNSIGNED,
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID) ON DELETE SET NULL
    /*IF COUNTRY DELETED, SET TO NULL*/
);

CREATE TABLE CD (
    Resource_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Resource_ID) REFERENCES Resource(Resource_ID) ON DELETE CASCADE ,
    CD_Name_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (CD_Name_ID) REFERENCES CD_Name(CD_Name_ID) ON DELETE CASCADE
    /*ROW DELETED IF FK DELETED */
);

CREATE TABLE DVD_Video (
    Resource_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Resource_ID) REFERENCES Resource(Resource_ID) ON DELETE CASCADE,
    /*ROW DELETED IF FK DELETED */
    `DVD/Video?` VARCHAR(6) NOT NULL,
    /* more than enough max length*/
    Film_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Film_ID) REFERENCES Film(Film_ID) ON DELETE CASCADE,
    /*ROW DELETED IF FK DELETED */
    CHECK(`DVD/VIDEO?` IN ('DVD', 'VIDEO'))
);

CREATE TABLE Book (
    Resource_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Resource_ID) REFERENCES Resource(Resource_ID) ON DELETE CASCADE,
    /*ROW DELETED IF FK DELETED */
    ISBN VARCHAR(13) NOT NULL,
    FOREIGN KEY (ISBN) REFERENCES ISBN(ISBN) ON UPDATE CASCADE ON DELETE CASCADE
    /* IF ISBN UPDATED OR DELETED THE ROW WILL CHANGE OR BE DELETED*/
);

CREATE TABLE Film_Studios_List_Film (
    Film_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Film_ID) REFERENCES Film(Film_ID) ON DELETE CASCADE,
    /*ROW DELETED IF FK DELETED */
    Film_Studio_ID TINYINT(3) UNSIGNED NOT NULL,
    FOREIGN KEY (Film_Studio_ID) REFERENCES Film_Studios_List(Film_Studio_ID) ON DELETE CASCADE
    /*ROW DELETED IF FK DELETED */
);

CREATE TABLE Author_ISBN (
    ISBN VARCHAR(13) NOT NULL,
    FOREIGN KEY (ISBN) REFERENCES ISBN(ISBN) ON UPDATE CASCADE ON DELETE CASCADE,
    Author_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID) ON DELETE CASCADE
    /*ROW DELETED IF FK DELETED */
);

CREATE TABLE Artist_CD_Name (
    CD_Name_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (CD_Name_ID) REFERENCES CD_Name(CD_Name_ID) ON DELETE CASCADE,
    /*ROW DELETED IF FK DELETED */
    Artist_ID SMALLINT(5) UNSIGNED NOT NULL,
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID) ON DELETE CASCADE
    /*ROW DELETED IF FK DELETED */
);
/*Batch 1*/
INSERT INTO CD_Name (Album_Name, Date_Released, Parental_Advisory) VALUES
    ('Legend: The Best of Bob Marley and The Wailers','1979-12-15','Y'),
    ('Born to Run','1998-06-25','Y'),
    ('Tapestry','1966-10-05','N'),
    ('The Great Twenty_Eight','1980-12-03','Y'),
    ('The Rise and Fall of Ziggy Stardust and the Spiders From Mars','1971-08-27','Y'),
    ('Hotel California', '1981-07-03', 'Y'),
    ('The Sun Sessions', '1968-11-01', 'Y'),
    ('Rumours', '1996-12-27', 'Y'),
    ('Live at the Apollo, 1962', '1986-05-05', 'Y'),
    ('A Love Supreme', '1972-07-15', 'N'),
    ('John Lennon/Plastic Ono Band','1991-02-24','Y'),
    ('Blue', '1999-01-31', 'Y'),
    ('Led Zeppelin', '1965-08-17', 'N'),
    ('Forever Changes', '1971-02-17', 'Y'),
    ('What''s Going On', '1999-08-21', 'Y'),
    ('Thriller', '1981-02-27', 'Y'),
    ('Kind of Blue', '1964-12-13', 'Y'),
    ('The Anthology', '1972-03-05', 'N'),
    ('Nevermind', '1969-10-26', 'N'),
    ('Horses', '1972-03-30', 'Y'),
    ('The Dark Side of the Moon', '1992-05-31', 'N'),
    ('It Takes a Nation of Millions to Hold Us Back','1973-11-24','Y'),
    ('Ramones', '1992-01-22', 'Y'),
    ('The Complete Recordings', '1970-08-11', 'N'),
    ('Never Mind the Bollocks Here''s the Sex Pistols','1990-01-26','Y'),
    ('Innervisions', '1968-01-11', 'N'),
    ('At Fillmore East', '1980-07-08', 'Y'),
    ('Music From Big Pink', '1987-03-11', 'Y'),
    ('Pet Sounds', '1988-09-12', 'N'),
    ('London Calling', '1990-09-11', 'N'),
    ('The Doors', '1990-12-10', 'N'),
    ('Are You Experienced', '1984-06-11', 'Y'),
    ('Exile on Main St.', '1999-05-19', 'N'),
    ('The Velvet Underground & Nico','1973-05-25','N'),
    ('Who''s Next', '1971-10-16', 'N'),
    ('The Joshua Tree', '1976-08-09', 'Y'),
    ('Astral Weeks', '1984-05-29', 'N'),
    ('Highway 61 Revisited', '1993-08-06', 'Y'),
    ('Blonde on Blonde', '1997-06-10', 'Y'),
    ('Blood on the Tracks', '1981-06-02', 'Y'),
    ('Bringing It All Back Home', '1984-09-11', 'Y'),
    ('Sgt. Pepper''s Lonely Hearts Club Band','1965-07-01','N'),
    ('Revolver', '1992-08-29', 'N'),
    ('Rubber Soul', '1980-12-04', 'Y'),
    ('The Beatles ("The White Album")','1980-05-01','Y'),
    ('Abbey Road', '1985-09-18', 'N'),
    ('Please Please Me', '1971-05-08', 'N');

INSERT INTO Country (Country_Name) VALUES
    ('Afghanistan'),('Åland Islands'),('Albania'),('Algeria'),('American Samoa'),('Andorra'),
    ('Angola'),('Anguilla'),('Antarctica'),('Antigua and Barbuda'),('Argentina'),('Armenia'),
    ('Aruba'),('Australia'),('Austria'),('Azerbaijan'),('Bahamas'),('Bahrain'),('Bangladesh'),
    ('Barbados'),('Belarus'),('Belgium'),('Belize'),('Benin'),('Bermuda'),('Bhutan'),('Bolivia, Plurinational State of'),
    ('Bonaire, Sint Eustatius and Saba'),('Bosnia and Herzegovina'),('Botswana'),('Bouvet Island'),('Brazil'),
    ('British Indian Ocean Territory'),('Brunei Darussalam'),('Bulgaria'),('Burkina Faso'),('Burundi'),
    ('Cambodia'),('Cameroon'),('Canada'),('Cape Verde'),('Cayman Islands'),('Central African Republic'),
    ('Chad'),('Chile'),('China'),('Christmas Island'),('Cocos (Keeling) Islands'),('Colombia'),
    ('Comoros'),('Congo'),('Congo, the Democratic Republic of the'),('Cook Islands'),('Costa Rica'),
    ("Côte d'Ivoire"),('Croatia'),('Cuba'),('Curaçao'),('Cyprus'),('Czech Republic'),('Denmark'),('Djibouti'),
    ('Dominica'),('Dominican Republic'),('Ecuador'),('Egypt'),('El Salvador'),('Equatorial Guinea'),
    ('Eritrea'),('Estonia'),('Ethiopia'),('Falkland Islands (Malvinas)'),('Faroe Islands'),('Fiji'),
    ('Finland'),('France'),('French Guiana'),('French Polynesia'),('French Southern Territories'),('Gabon'),
    ('Gambia'),('Georgia'),('Germany'),('Ghana'),('Gibraltar'),('Greece'),('Greenland'),('Grenada'),('Guadeloupe'),
    ('Guam'),('Guatemala'),('Guernsey'),('Guinea'),('Guinea-Bissau'),('Guyana'),('Haiti'),
    ('Heard Island and McDonald Islands'),('Holy See (Vatican City State)'),('Honduras'),('Hong Kong'),
    ('Hungary'),('Iceland'),('India'),('Indonesia'),('Iran, Islamic Republic of'),('Iraq'),('Ireland'),
    ('Isle of Man'),('Israel'),('Italy'),('Jamaica'),('Japan'),('Jersey'),('Jordan'),('Kazakhstan'),('Kenya'),
    ('Kiribati'),("Democratic People's Republic of North Korea"),('South Korea'),('Kuwait'),('Kyrgyzstan'),
    ("Lao People's Democratic Republic"),('Latvia'),('Lebanon'),('Lesotho'),('Liberia'),('Libya'),('Liechtenstein'),
    ('Lithuania'),('Luxembourg'),('Macao'),('Macedonia, the Former Yugoslav Republic of'),('Madagascar'),('Malawi'),
    ('Malaysia'),('Maldives'),('Mali'),('Malta'),('Marshall Islands'),('Martinique'),('Mauritania'),('Mauritius'),
    ('Mayotte'),('Mexico'),('Micronesia, Federated States of'),('Moldova, Republic of'),('Monaco'),('Mongolia'),
    ('Montenegro'),('Montserrat'),('Morocco'),('Mozambique'),('Myanmar'),('Namibia'),('Nauru'),('Nepal'),
    ('Netherlands'),('New Caledonia'),('New Zealand'),('Nicaragua'),('Niger'),('Nigeria'),('Niue'),('Norfolk Island'),
    ('Northern Mariana Islands'),('Norway'),('Oman'),('Pakistan'),('Palau'),('Palestine, State of'),('Panama'),
    ('Papua New Guinea'),('Paraguay'),('Peru'),('Philippines'),('Pitcairn'),('Poland'),('Portugal'),('Puerto Rico'),
    ('Qatar'),('Réunion'),('Romania'),('Russian Federation'),('Rwanda'),('Saint Barthélemy'),
    ('Saint Helena, Ascension and Tristan da Cunha'),('Saint Kitts and Nevis'),('Saint Lucia'),
    ('Saint Martin (French part)'),('Saint Pierre and Miquelon'),('Saint Vincent and the Grenadines'),
    ('Samoa'),('San Marino'),('Sao Tome and Principe'),('Saudi Arabia'),('Senegal'),('Serbia'),('Seychelles'),
    ('Sierra Leone'),('Singapore'),('Sint Maarten (Dutch part)'),('Slovakia'),('Slovenia'),('Solomon Islands'),
    ('Somalia'),('South Africa'),('South Georgia and the South Sandwich Islands'),('South Sudan'),('Spain'),
    ('Sri Lanka'),('Sudan'),('Suriname'),('Svalbard and Jan Mayen'),('Swaziland'),('Sweden'),('Switzerland'),
    ('Syrian Arab Republic'),('Taiwan, Province of China'),('Tajikistan'),('Tanzania, United Republic of'),
    ('Thailand'),('Timor-Leste'),('Togo'),('Tokelau'),('Tonga'),('Trinidad and Tobago'),('Tunisia'),('Turkey'),
    ('Turkmenistan'),('Turks and Caicos Islands'),('Tuvalu'),('Uganda'),('Ukraine'),('United Arab Emirates'),
    ('United Kingdom'),('United States'),('United States Minor Outlying Islands'),('Uruguay'),('Uzbekistan'),
    ('Vanuatu'),('Venezuela, Bolivarian Republic of'),('Viet Nam'),('Virgin Islands, British'),
    ('Virgin Islands, U.S.'),('Wallis and Futuna'),('Western Sahara'),('Yemen'),('Zambia'),('Zimbabwe');

INSERT INTO Department_Number (Dept_No, Department_Name) VALUES
    (1, 'English Literature'),
    (2, 'Film Studies'),
    (3, 'Music Studies'),
    (4, 'Computer Science'),
    (5, 'Philosophy'),
    (6, 'Geography'),
    (7, 'Psychology'),
    (8, 'History');

INSERT INTO Film (Film_Name, Date_Released, Genre, Age_Rating) VALUES
    ('The Shawshank Redemption','1995-02-17','Drama','15'),
    ('The Dark Knight', '2008-07-24', 'Action', '15'),
    ('Forrest Gump', '1994-10-07', 'Drama', '12'),
    ('Inception','2010-07-16','Action and Adventure','12'),
    ('The Matrix', '1999-06-11', 'Sci-fi', '15'),
    ('The Green Mile', '2000-03-03', 'Crime', '18'),
    ('Interstellar', '2014-11-07', 'Sci-fi', '12'),
    ('Parasite', '2020-02-07', 'Foreign', '15'),
    ('Gladiator', '2000-05-12', 'Action', '15'),
    ('Alien', '1979-09-06', 'Horror', '18'),
    ('Coco', '2018-01-19', 'Animation', 'PG');

INSERT INTO ISBN (ISBN, Book_Name, Date_Published) VALUES
    (0872204642, 'Nicomachean Ethics', '2009-06-11'),
    (0552997048,'A Short History of Nearly Everything','2016-06-16'),
    (0805012469, 'The Glass Bead Game', '2000-07-06'),
    (0140449132, 'Crime and Punishment', '2003-01-30'),
    (1686705026,'The Picture of Dorian Gray','2019-08-19'),
    (1505297052, 'The Metamorphosis', '2014-11-30'),
    (1408845660,'Harry Potter and the Prisoner of Azkaban','2017-10-03'),
    (0613922670, 'Man and His Symbols', '1968-08-15'),
    (0091906350,'How to Win Friends and Influence People','2004-10-01'),
    (0722532938, 'The Alchemist', '1995-01-01'),
    (0261103571,'The Fellowship of the Ring ','2011-10-27'),
    (0007461216, 'Mere Christianity', '2012-04-01'),
    (9352230760, '1984', '2017-04-03'),
    (0586090452, 'Galapagos', '2019-07-11'),
    (3425048570, 'Brave New World ', '2010-01-01'),
    (0140449531, 'Selected Poems', '2014-06-24'),
    (0141315180,'The Diary of a Young Girl','2008-06-28'),
    (0099448823, 'Norwegian Wood', '2003-01-01'),
    (0860685119,'I Know Why The Caged Bird Sings','1986-01-26'),
    (0099590085,'Sapiens: A Brief History of Humankind','2015-04-01'),
    (1107186129,'Principles of Database Management: The Practical Guide to Storing, Managing and Analyzing Big and Small Data','2018-06-12');

insert into Location (Shelf_No, Floor_No) values
    (0, 0),(1, 0),(2, 0),(3, 0),(4, 0),(5, 0),(6, 0),(7, 0),(8, 0),(9, 0),
    (10, 0),(11, 0),(12, 0),(13, 0),(14, 0),(15, 0),(16, 0),(17, 0),(18, 0),(19, 0),
    (20, 0),(21, 0),(22, 0),(23, 0),(24, 0),(25, 0),(26, 0),(27, 0),(28, 0),(29, 0),
    (30, 0),(31, 0),(32, 0),(33, 0),(34, 0),(35, 0),(36, 0),(37, 0),(38, 0),(39, 0),
    (40, 0),(41, 0),(42, 0),(43, 0),(44, 0),(45, 0),(46, 0),(47, 0),(48, 0),(49, 0),
    (0, 1),(1, 1),(2, 1),(3, 1),(4, 1),(5, 1),(6, 1),(7, 1),(8, 1),(9, 1),
    (10, 1),(11, 1),(12, 1),(13, 1),(14, 1),(15, 1),(16, 1),(17, 1),(18, 1),(19, 1),
    (20, 1),(21, 1),(22, 1),(23, 1),(24, 1),(25, 1),(26, 1),(27, 1),(28, 1),(29, 1),
    (30, 1),(31, 1),(32, 1),(33, 1),(34, 1),(35, 1),(36, 1),(37, 1),(38, 1),(39, 1),
    (40, 1),(41, 1),(42, 1),(43, 1),(44, 1),(45, 1),(46, 1),(47, 1),(48, 1),(49, 1),
    (0, 2),(1, 2),(2, 2),(3, 2),(4, 2),(5, 2),(6, 2),(7, 2),(8, 2),(9, 2),
    (10, 2),(11, 2),(12, 2),(13, 2),(14, 2),(15, 2),(16, 2),(17, 2),(18, 2),(19, 2),
    (20, 2),(21, 2),(22, 2),(23, 2),(24, 2),(25, 2),(26, 2),(27, 2),(28, 2),(29, 2),
    (30, 2),(31, 2),(32, 2),(33, 2),(34, 2),(35, 2),(36, 2),(37, 2),(38, 2),(39, 2),
    (40, 2),(41, 2),(42, 2),(43, 2),(44, 2),(45, 2),(46, 2),(47, 2),(48, 2),(49, 2);

INSERT INTO Member (First_Name, Last_Name, Email_Address, House_Number_or_Name, Postcode, Phone_Number, Member_Type, DOB)
VALUES
    (
        'John',
        'Smith',
        'john.smith@qmul.ac.uk',
        '9',
        'HA5 1SX',
        '+447700900744',
        'Staff',
        '1961-07-08'
    ),
    (
        'David',
        'Hauni',
        'davidh@qmul.ac.uk',
        '17',
        'DN1 9ST',
        '+447700900137 ', 
        'Student',
        '1994-09-13'
    ),
    (
        'Tom',
        'Cruise',
        'cruise@qmul.ac.uk',
        '61',
        'LL77 7PH',
        '+447700900523',
        'Student',
        '1992-07-18'
    ),
    (
        'Logan',
        'Dev',
        'logdev@qmul.ac.uk',
        '74',
        'BL8 2JP',
        '+447700900877 ',
        'Student',
        '1996-10-20'
    ),
    (
        'Frank',
        'Barker',
        'f.barker@qmul.ac.uk',
        'Buckingham Palace',
        'SW1A 1AA',
        '+447266986247',
        'Staff',
        '1963-07-09'
    ),
    (
        'Dewey',
        'Parsons',
        'dewey.parsons@qmul.ac.uk',
        '86',
        'SO14 5BR',
        '+447881734090',
        'Student',
        '1987-05-23'
    ),
    (
        'Carlos',
        'Gomez',
        'carlosgomez@qmul.ac.uk',
        '99',
        'PA64 6AP',
        '+447484740395',
        'Student',
        '1992-10-11'
    ),
    (
        'Joel',
        'Santos',
        'j.santos@qmul.ac.uk',
        '34',
        'NG23 5DH',
        '+447593909550',
        'Student',
        '1995-05-10'
    ),
    (
        'Tanya',
        'Stewart',
        'tanya.stewart@qmul.ac.uk',
        '67',
        'KT11 2NF',
        '+447666492455',
        'Student',
        '1992-03-20'
    ),
    (
        'Rafael',
        'Castro',
        'r.castro@qmul.ac.uk',
        '54',
        'CW12 1JD',
        '+447092177480',
        'Staff',
        '1968-05-17'
    ),
    (
        'Jackson',
        'Russell',
        'jr@qmul.ac.uk',
        '29',
        'E1 2BP',
        '+447779404025',
        'Student',
        '1998-01-09'
    ),
    (
        'Ed',
        'Bossman',
        'ed.bossman@qmul.ac.uk',
        '12',
        'DN10 4DG',
        '+447135519680',
        'Student',
        '1993-06-12'
    ),
    (
        'Bryan',
        'Goodwin',
        'b.goodiwn@qmul.ac.uk',
        '38',
        'NE5 2UY',
        '+447958097035',
        'Staff',
        '1971-02-26'
    ),
    (
        'Anita',
        'Taylor',
        'anita.taylor@qmul.ac.uk',
        '71',
        'PO41 0YB',
        '+447670390660',
        'Student',
        '1999-10-16'
    ),
    (
        'Leonardo',
        'French',
        'leo.french@qmul.ac.uk',
        '42',
        'NE66 3ND',
        '+447424641475',
        'Student',
        '1993-01-20'
    ),
    (
        'Lucas',
        'Armstrong',
        'lucasarmstrong@qmul.ac.uk',
        '33',
        'TW9 3JJ',
        '+447294885050',
        'Student',
        '1995-07-13'
    ),
    (
        'Alfred',
        'Gilbert',
        'a.gilbert@qmul.ac.uk',
        '59',
        'M6 7LS',
        '+447625608325',
        'Staff',
        '1978-04-21'
    ),
    (
        'Ryan',
        'Ward',
        'rward@qmul.ac.uk',
        '78',
        'EH20 9JS',
        '+447164057510',
        'Student',
        '1999-11-29'
    ),
    (
        'Franklin',
        'Thompson',
        'f.thompson@qmul.ac.uk',
        '10',
        'SK13 7RS',
        '+447068647165',
        'Staff',
        '1965-06-16'
    ),
    (
        'Aiden',
        'Cole',
        'aiden.cole@qmul.ac.uk',
        '2',
        'PL13 2LY',
        '+447898625580',
        'Student',
        '1997-04-09'
    );
    
/*Batch 2*/
INSERT INTO Artist (Artist_Name, Country_ID) VALUES
    ('Bob Marley & The Wailers', 111),
    ('Bruce Springsteen', 236),
    ('Carole King', 236),
    ('Chuck Berry', 236),
    ('David Bowie', 235),
    ('Eagles', 236),
    ('Elvis Presley', 236),
    ('Fleetwood Mac', 236),
    ('James Brown', 236),
    ('John Coltrane', 236),
    ('John Lennon', 235),
    ('Joni Mitchell', 40),
    ('Led Zeppelin', 236),
    ('Love', 236),
    ('Marvin Gaye', 236),
    ('Michael Jackson', 236),
    ('Miles Davis', 236),
    ('Muddy Waters', 236),
    ('Nirvana', 236),
    ('Patti Smith', 236),
    ('Pink Floyd', 235),
    ('Public Enemy', 15),
    ('Ramones', 64),
    ('Robert Johnson', 236),
    ('Sex Pistols', 235),
    ('Stevie Wonder', 236),
    ('The Allman Brothers Band', 236),
    ('The Band', 236),
    ('The Beach Boys', 236),
    ('The Clash', 235),
    ('The Doors', 236),
    ('The Jimi Hendrix Experience', 236),
    ('The Rolling Stones', 235),
    ('The Velvet Underground', 236),
    ('The Who', 235),
    ('U2', 107),
    ('Van Morrison', 236),
    ('Bob Dylan', 236),
    ('The Beatles', 235),
    ('Plastic Ono Band', 235);


INSERT INTO Author (Author_First_Name, Author_Last_Name, Country_ID) VALUES
    (NULL, 'Aristotle', 86),
    ('Bill', 'Bryson', 236),
    ('Herman', 'Hesse', 83),
    ('Fyodor', 'Dostoevsky', 183),
    ('Oscar', 'Wilde', 107),
    ('Franz', 'Kafka', 60),
    ('J.K', 'Rowling', 235),
    ('Carl', 'Jung', 216),
    ('Dale', 'Carnegie', 236),
    ('Paulo', 'Coelho', 32),
    ('J.R.R', 'Tolkein', 235),
    ('C.S', 'Lewis', 235),
    ('George', 'Orwell', 235),
    ('Kurt', 'Vonnegut', 236),
    ('Aldous', 'Huxley', 235),
    (NULL, 'Rumi', 219),
    ('Anne', 'Frank', 83),
    ('Haruki', 'Murakami', 112),
    ('Maya', 'Angelou', 236),
    ('Yuval Noah', 'Harari', 109),
    ('Wilfried', 'Lemahieu', 22),
    ('Seppe', 'vanden Broucke', 22),
    ('Bart', 'Baesens ', 22);

INSERT INTO Class_Number (Subject, Dept_No) VALUES
    ('Poetry', 1),
    ('Classics', 1),
    ('Database Systems', 4),
    ('Old School Hip-Hop', 3),
    ('Action Films', 2),
    ('Ethics', 5),
    ('Novels', 1),
    ('Geology', 6),
    ('Symbolism', 7),
    ('Self Help', 7),
    ('Miscellaneous', null),
    ('Jazz', 3),
    ('World War 2', 8),
    ('Pop Science', null),
    ('Reggae',3), /*15*/
    ('Rock',3),
    ('Soul', 3),
    ('Pop',3),
    ('Blues',3);
    

INSERT INTO Film_Studios_List (Film_Studio_Name, Country_ID) VALUES
    ('Castle Rock Entertainment', 236),
    ('Warner Bros. Pictures', 236),
    ('Paramount Pictures', 236),
    ('Legendary Entertainment', 236),
    ('Village Roadshow Pictures', 236),
    ('Barunson E&A', 119),
    ('DreamWorks Pictures', 236),
    ('20th Century Studios', 236),
    ('Walt Disney Pictures', 236);
    
    
/*Batch 3*/
INSERT INTO Artist_CD_Name VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10),
    (11, 11),
    (11, 40),
    (12, 12),
    (13, 13),
    (14, 14),
    (15, 15),
    (16, 16),
    (17, 17),
    (18, 18),
    (19, 19),
    (20, 20),
    (21, 21),
    (22, 22),
    (23, 23),
    (24, 24),
    (25, 25),
    (26, 26),
    (27, 27),
    (28, 28),
    (28, 38),
    (29, 29),
    (30, 30),
    (31, 31),
    (32, 32),
    (33, 33),
    (34, 34),
    (35, 35),
    (36, 36),
    (37, 37),
    (38, 38),
    (39, 38),
    (40, 38),
    (41, 38),
    (42, 11),
    (42, 39),
    (43, 11),
    (43, 39),
    (44, 11),
    (44, 39),
    (45, 11),
    (45, 39),
    (46, 11),
    (46, 39),
    (47, 11),
    (47, 39);

/*John Lennon is stored as solo artist so is an artist for Beatles albums as well, 
Bob Dylan is stored as a solo artist and is also part of The Band*/



INSERT INTO
    Author_ISBN
VALUES
    (0872204642, 1),
    (0552997048, 2),
    (0805012469, 3),
    (0140449132, 4),
    (1686705026, 5),
    (1505297052, 6),
    (1408845660, 7),
    (0613922670, 8),
    (0091906350, 9),
    (0722532938, 10),
    (0261103571, 11),
    (0007461216, 12),
    (9352230760, 13),
    (0586090452, 14),
    (3425048570, 15),
    (0140449531, 16),
    (0141315180, 17),
    (0099448823, 18),
    (0860685119, 19),
    (0099590085, 20),
    (1107186129, 21),
    (1107186129, 22),
    (1107186129, 23);

INSERT INTO
    Resource (
        Borrowable_Time,
        `Type`,
        No_of_Total_Copies,
        Location_ID,
        Class_ID
    )
VALUES
    (14, 'Book', 4, 3, 6),
    (14, 'Book', 2, 43, 14),
    (14, 'Book', 6, 24, 7),
    (14, 'Book', 8, 15, 2),
    (14, 'Book', 10, 15, 7),
    (14, 'Book', 7, 14, 2),
    (14, 'Book', 5, 32, 7),
    (14, 'Book', 1, 52, 9),
    (14, 'Book', 8, 100, 10),
    (14, 'Book', 12, 102, 7),
    (14, 'Book', 6, 32, 7),
    (14, 'Book', 3, 1, 1),
    (14, 'Book', 10, 56, 2),
    (14, 'Book', 5, 62, 7),
    (14, 'Book', 8, 2, 7),
    (0, 'Book', 3, 107, 1),
    (14, 'Book', 4, 136, 13),
    (14, 'Book', 2, 130, 7),
    (14, 'Book', 2, 86, 1),
    (2, 'Book', 10, 96, 14),
    (2, 'Book', 16, 30, 3),
    (14, 'DVD/Video', 3, 81, null),
    (14, 'DVD/Video', 2, 72, null),
    (14, 'DVD/Video', 7, 54, null),
    (14, 'DVD/Video', 2, 41, null),
    (14, 'DVD/Video', 6, 90, null),
    (14, 'DVD/Video', 8, 111, null),
    (14, 'DVD/Video', 3, 4, null),
    (14, 'DVD/Video', 7, 78, null),
    (14, 'DVD/Video', 3, 98, null),
    (14, 'DVD/Video', 5, 124, null),
    (14, 'DVD/Video', 4, 23, null),
    (14, 'CD', 10, 123, 15),
    (14, 'CD', 10, 41, 16),
    (14, 'CD', 5, 24, 18),
    (14, 'CD', 10, 25, 16),
    (14, 'CD', 2, 14, 16),
    (14, 'CD', 36, 5, 16),
    (2, 'CD', 10, 13, 16),
    (14, 'CD', 10, 52, 18),
    (14, 'CD', 36, 6, 17),
    (14, 'CD', 10, 43, 12),
    (14, 'CD', 21, 5, 16),
    (14, 'CD', 10, 73, 16),
    (14, 'CD', 2, 28, 16),
    (14, 'CD', 12, 34, 16),
    (14, 'CD', 10, 86, 17),
    (14, 'CD', 1, 9, 18),
    (14, 'CD', 10, 6, 19), 
    (14, 'CD', 1, 3, null),
    (2, 'CD', 2, 143, null),
    (14, 'CD', 10, 5, null),
    (0, 'CD', 2, 45, null),
    (14, 'CD', 2, 6, 4),
    (14, 'CD', 10, 34, null),
    (14, 'CD', 6, 35, null),
    (14, 'CD', 2, 146, null),
    (14, 'CD', 10, 35, null),
    (14, 'CD', 1, 2, null),
    (14, 'CD', 10, 14, null),
    (2, 'CD', 1, 36, null),
    (14, 'CD', 1, 14, null),
    (14, 'CD', 2, 47, null),
    (14, 'CD', 21, 85, null),
    (14, 'CD', 10, 56, null),
    (14, 'CD', 1, 47, null),
    (14, 'CD', 2, 77, null),
    (14, 'CD', 1, 75, null),
    (14, 'CD', 12, 13, null),
    (14, 'CD', 6, 2, null),
    (14, 'CD', 2, 2, null),
    (0, 'CD', 12, 2, null),
    (14, 'CD', 1, 2, null),
    (14, 'CD', 2, 1, null),
    (14, 'CD', 10, 1, null),
    (14, 'CD', 10, 1, null),
    (14, 'CD', 12, 1, null),
    (14, 'CD', 12, 1, null),
    (14, 'CD', 1, 1, null);

/*for database testing purposes,it was not deemed necessary to assign class ids to all resources. 
class id can be added later if required*/

INSERT INTO
    Film_Studios_List_Film (Film_ID, Film_Studio_ID)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 1),
    (7, 3),
    (8, 6),
    (9, 7),
    (10, 8),
    (11, 9);
    /*Batch 4*/

INSERT INTO
    CD
VALUES
    (33, 1),
    (34, 2),
    (35, 3),
    (36, 4),
    (37, 5),
    (38, 6),
    (39, 7),
    (40, 8),
    (41, 9),
    (42, 10),
    (43, 11),
    (44, 12),
    (45, 13),
    (46, 14),
    (47, 15),
    (48, 16),
    (49, 17),
    (50, 18),
    (51, 19),
    (52, 20),
    (53, 21),
    (54, 22),
    (55, 23),
    (56, 24),
    (57, 25),
    (58, 26),
    (59, 27),
    (60, 28),
    (61, 29),
    (62, 30),
    (63, 31),
    (64, 32),
    (65, 33),
    (66, 34),
    (67, 35),
    (68, 36),
    (69, 37),
    (70, 38),
    (71, 39),
    (72, 40),
    (73, 41),
    (74, 42),
    (75, 43),
    (76, 44),
    (77, 45),
    (78, 46),
    (79, 47);

INSERT INTO Book VALUES
    (1, 872204642),
    (2, 552997048),
    (3, 805012469),
    (4, 140449132),
    (5, 1686705026),
    (6, 1505297052),
    (7, 1408845660),
    (8, 613922670),
    (9, 91906350),
    (10, 722532938),
    (11, 261103571),
    (12, 7461216),
    (14, 586090452),
    (13, 9352230760),
    (15, 3425048570),
    (16, 140449531),
    (17, 141315180),
    (18, 99448823),
    (19, 860685119),
    (20, 99590085),
    (21, 1107186129);

INSERT INTO DVD_Video (Resource_ID, `DVD/Video?`, Film_ID) VALUES
    (22, 'Video', 1),
    (23, 'DVD', 2),
    (24, 'Video', 3),
    (25, 'DVD', 4),
    (26, 'Video', 5),
    (27, 'DVD', 6),
    (28, 'DVD', 7),
    (29, 'DVD', 8),
    (30, 'DVD', 9),
    (31, 'Video', 10),
    (32, 'DVD', 11);

INSERT INTO Loan (
        Date_Taken_Out,
        Date_Returned,
        Date_Paid,
        Member_ID,
        Resource_ID
    )
VALUES
('2020-11-1', '2020-11-6', null,  1, 17 ),
('2020-11-1', '2020-11-7', null,  2, 24 ),
('2020-11-1', '2020-11-8', null,  3, 42 ),
('2020-11-1', '2020-11-9', null,  4, 18 ),
('2020-11-1', '2020-11-10', null,  5, 30 ),
('2020-11-1', '2020-11-11', null,  6, 56 ),
('2020-11-1', '2020-11-12', null,  7, 70 ),
('2020-11-1', '2020-11-13', null,  8, 76 ),
('2020-11-1', '2020-11-14', null,  9, 70 ),
('2020-11-1', '2020-11-15', null,  10, 47 ),
('2020-11-1', '2020-11-16', null,  11, 49 ),
('2020-11-1', '2020-11-17', null,  12, 29 ),
('2020-11-1', '2020-11-18', null,  13, 53 ),
('2020-11-5', '2020-11-10', null,  14, 34 ),
('2020-11-5', '2020-11-11', null,  15, 29 ),
('2020-11-5', '2020-11-12', null,  16, 62 ),
('2020-11-5', '2020-11-13', null,  17, 75 ),
('2020-11-5', '2020-11-14', null,  18, 61 ),
('2020-11-5', '2020-11-15', null,  19, 13 ),
('2020-11-5', '2020-11-16', null,  20, 13 ),
('2020-11-5', '2020-11-17', null,  1, 67 ),
('2020-11-5', '2020-11-18', null,  2, 2 ),
('2020-11-5', '2020-11-19', null,  3, 75 ),
('2020-11-5', '2020-11-20', null,  4, 11 ),
('2020-11-5', '2020-11-21', null,  5, 27 ),
('2020-11-5', '2020-11-22', null,  6, 52 ),
('2020-11-9', '2020-11-14', null,  7, 52 ),
('2020-11-9', '2020-11-15', null,  8, 13 ),
('2020-11-9', '2020-11-16', null,  9, 61 ),
('2020-11-9', '2020-11-17', null,  10, 31 ),
('2020-11-9', '2020-11-18', null,  11, 64 ),
('2020-11-9', '2020-11-19', null,  12, 9 ),
('2020-11-9', '2020-11-20', null,  13, 60 ),
('2020-11-9', '2020-11-21', null,  14, 69 ),
('2020-11-9', '2020-11-22', null,  15, 72 ),
('2020-11-9', '2020-11-23', null,  16, 71 ),
('2020-11-9', '2020-11-24', null,  17, 65 ),
('2020-11-9', '2020-11-25', null,  18, 50 ),
('2020-11-9', '2020-11-26', null,  19, 54 ),
('2020-11-13', '2020-11-18', null,  20, 37 ),
('2020-11-13', '2020-11-19', null,  1, 60 ),
('2020-11-13', '2020-11-20', null,  2, 47 ),
('2020-11-13', '2020-11-21', null,  3, 40 ),
('2020-11-13', '2020-11-22', null,  4, 58 ),
('2020-11-13', '2020-11-23', null,  5, 24 ),
('2020-11-13', '2020-11-24', null,  6, 22 ),
('2020-11-13', '2020-11-25', null,  7, 48 ),
('2020-11-13', '2020-11-26', null,  8, 15 ),
('2020-11-13', '2020-11-27', null,  9, 77 ),
('2020-11-13', '2020-11-28', null,  10, 29 ),
('2020-11-13', '2020-11-29', null,  11, 77 ),
('2020-11-17', '2020-11-22', null,  12, 4 ),
('2020-11-17', '2020-11-23', null,  13, 37 ),
('2020-11-17', '2020-11-24', null,  14, 6 ),
('2020-11-17', '2020-11-25', null,  15, 21 ),
('2020-11-17', '2020-11-26', null,  16, 33 ),
('2020-11-17', '2020-11-27', null,  17, 47 ),
('2020-11-17', '2020-11-28', null,  18, 24 ),
('2020-11-17', '2020-11-29', null,  19, 4 ),
('2020-11-21', '2020-11-27', null,  1, 73 ),
('2020-11-21', '2020-11-29', null,  3, 34 ),
('2020-11-25', '2020-12-1', null, 4, 5 ),
('2020-11-25', '2020-12-2', null, 5, 43 ),
('2020-11-25', '2020-12-3', null, 6, 14 ),
('2020-11-25', '2020-12-4', null, 7, 32 ),
('2020-11-25', '2020-12-5', null, 8, 49 ),
('2020-11-25', '2020-12-6', null, 9, 27 ),
('2020-11-25', '2020-12-7', null, 10, 12 ),
('2020-12-1', null, null, 19, 47 ),
('2020-12-1', null, null, 3, 34 ),
('2020-12-1', null, null, 8, 25 ),
('2020-12-1', null, null, 2, 69 ),
('2020-12-1', null, null, 19, 75 ),
('2020-12-1', null, null, 6, 49 ),
('2020-12-4', null, null, 18, 58 ),
('2020-12-4', null, null, 18, 24 ),
('2020-12-4', null, null, 17, 39 ),
('2020-12-4', null, null, 15, 36 ),
('2020-12-4', null, null, 2, 64 ),
('2020-12-4', null, null, 16, 69 ),
('2020-12-4', null, null, 16, 11 ),
('2020-12-7', null, null, 11, 69 ),
('2020-12-7', null, null, 17, 9 ),
('2020-12-7', null, null, 13, 8 ),
('2020-12-7', null, null, 7, 70 ),
('2020-12-7', null, null, 19, 75 ),
('2020-12-7', null, null, 20, 60 ),
('2020-12-7', null, null, 19, 28 ),
('2020-12-7', null, null, 17, 7 );

CREATE VIEW Member_Fines AS
SELECT A.MEMBER_ID AS `Member No.`, A.FIRST_NAME AS Name, A.LAST_NAME AS Surname, A.EMAIL_ADDRESS AS Email, 
A.PHONE_NUMBER AS `Phone Number`, SUM(A.FINE_AMOUNT) AS `Total Fine`
FROM
(
	SELECT l.Loan_ID, l.Date_Taken_Out, l.Date_Returned, l.Date_Paid, m.MEMBER_ID, m.First_Name, m.Last_Name,
    m.Email_Address, m.Phone_Number, r.Borrowable_Time
			, CASE WHEN DATE_RETURNED IS NULL THEN  
					DATEDIFF(CURDATE(), DATE_ADD(Date_Taken_Out, INTERVAL r.Borrowable_Time Day)) -- IF NOT RETUREND
					ELSE DATEDIFF(l.DATE_RETURNED, DATE_ADD(Date_Taken_Out, INTERVAL r.Borrowable_Time Day)) -- IF RETURNED, ONLY OWE OVERDUE FINE UP UNTIL RETURN
					END AS FINE_AMOUNT 
	FROM Loan l
	INNER JOIN Resource r
	ON l.Resource_ID = r.Resource_ID
	INNER JOIN Member m
	ON l.Member_ID = m.Member_ID
	WHERE l.Date_Paid is NULL AND ((l.Date_Returned is NULL AND ADDDATE(l.Date_Taken_Out, INTERVAL r.borrowable_time DAY) < CURDATE()) 
    OR (ADDDATE(l.Date_Taken_Out, INTERVAL r.borrowable_time DAY) < l.Date_Returned)) -- all overdue items
) A
GROUP BY A.MEMBER_ID;

create view `Overdue Items with Contact Details` as 
select
L.Loan_ID, L.Member_ID, 
M.First_Name, M.Last_Name, 
M.Email_Address, M.Phone_Number,
R.Resource_ID, L.Date_Taken_Out, R.Borrowable_Time,  
DATEDIFF(CURDATE(),Date_Taken_Out) AS `Days_Out`,
DATE_ADD(Date_Taken_Out, INTERVAL R.Borrowable_Time Day) as `Date Due`,
cast(R.Borrowable_Time as signed) 
- DATEDIFF(CURDATE(),Date_Taken_Out) as `Days Before Due Date`
from
(Loan L join Resource R on L.Resource_ID = R.Resource_ID) 
join Member M on L.Member_ID = M.Member_ID 

where 
L.Date_Returned IS null and  
cast(R.Borrowable_Time as signed) 
- DATEDIFF(CURDATE(),Date_Taken_Out)<0  

order by L.Member_ID asc, `Days Before Due Date` asc;

create view `Outstanding Loans with due date` 
as
select L.Loan_ID, L.Member_ID, 
R.Resource_ID, R.Borrowable_Time,  
DATEDIFF(CURDATE(),Date_Taken_Out) AS `Days_Out`,
cast(R.Borrowable_Time as signed) - DATEDIFF(CURDATE(),Date_Taken_Out) as `Days Before Due Date`
from
Loan L 
left join 
Resource R on  
L.Resource_ID = R.Resource_ID where L.Date_Returned IS  null;

create view `Number of copies of resource available` as 

select R.Resource_ID, IFNULL(`Number Out On Loan`,0) as `Out on Loan` , R.No_of_Total_Copies, 
R.No_of_Total_Copies - IFNULL(`Number Out On Loan`,0) as `Number of Copies Left` 
from 
Resource R left join
(select Resource_ID, Count(Resource_ID) as `Number Out On Loan` 
from `Outstanding Loans with due date` group by Resource_ID) as t3
 on R.Resource_ID = t3.Resource_ID;

CREATE VIEW Popular_Items AS

SELECT R.Resource_ID, R.Location_ID, COUNT(L.Loan_ID) LOANS, 
CONCAT( COALESCE(C2.Album_Name,''), COALESCE(I.Book_Name,''), COALESCE(F.Film_Name,'')) ITEM_NAME,
CONCAT( COALESCE(A2.Artist_Name,''), COALESCE(CONCAT( A4.Author_First_Name," ", A4.Author_Last_Name),'') , COALESCE(F3.Film_Studio_Name,'')) 'BY',
R.Type
FROM Resource R
	LEFT JOIN CD C ON C.RESOURCE_ID=R.Resource_ID
    LEFT JOIN CD_Name C2 ON C2.CD_Name_Id=C.CD_Name_ID
    LEFT JOIN Artist_CD_Name A ON A.CD_Name_ID=C.CD_Name_ID
    LEFT JOIN Artist A2 ON A.Artist_ID=A2.Artist_ID
    LEFT JOIN Book B ON B.Resource_ID=R.Resource_ID
    LEFT JOIN ISBN I ON I.ISBN=B.ISBN
    LEFT JOIN Author_ISBN A3 ON A3.ISBN=B.ISBN
    LEFT JOIN Author A4 ON A4.Author_ID=A3.Author_ID
    LEFT JOIN DVD_Video D on D.Resource_ID=R.Resource_Id
    LEFT JOIN Film F on F.Film_ID=D.Film_ID
    LEFT JOIN Film_Studios_List_Film F2 ON F2.Film_ID=F.Film_ID
    LEFT JOIN Film_Studios_List F3 ON F3.Film_Studio_ID=F2.Film_Studio_ID
	LEFT JOIN Loan L ON L.Resource_ID=R.Resource_ID
    GROUP BY R.Resource_ID, C.CD_Name_ID, B.ISBN, D.FIlm_ID, A2.Artist_Name, A2.Artist_Name, A4.Author_First_Name, A4.Author_Last_Name, F3.Film_Studio_Name
    ORDER BY LOANS DESC
;

/*in this view, resources with multiple artists/authors etc will be shown twice. 
If only the number of loans vs resource id is necessary  can ignore the second row  */

create view  `number of loans by member` as
select Member.Member_ID, 
Member.Member_Type, t5.`Number of Loans`,
case when Member_Type = 'Student' then 5 
when Member_Type = 'Staff' then 10 
end  as `Max loanable items`
from Member  
join 
(select Member_ID, Count(Loan_ID) 
as `Number of Loans`
from `Outstanding Loans with due date`
group by Member_ID order by Member_ID) as t5 on Member.Member_ID = t5.Member_ID ;

create view `Max loan ability` as 
select Member_ID,
case when Member_Type = 'Student' then 5 
when Member_Type = 'Staff' then 10 
end  as `Max loanable items`
from Member  ;

DELIMITER $$

CREATE TRIGGER check_member_suspended
BEFORE INSERT ON Loan 
FOR EACH ROW  
BEGIN
    DECLARE totalfine int;
    SELECT `Total Fine` INTO totalfine
    FROM member_fines 
    WHERE `Member No.` = new.Member_ID;
    
    IF totalfine >= 10 THEN
        signal sqlstate '45000' 
set message_text = 'Member suspended';
    END IF; 

END $$
DELIMITER ;

DELIMITER $$

create trigger check_resource_available before insert on Loan for each row

BEGIN 

declare copies_left int;
select `Number of Copies Left` into copies_left
from `Number of copies of resource available` 
where Resource_ID = new.Resource_ID;

if copies_left = 0 then signal sqlstate '45000' 
set message_text = 'No copies of resource available';
END IF;


END $$

DELIMITER ;

DELIMITER $$

create trigger check_loan_capacity_available before insert on Loan for each row

BEGIN 

declare number_of_loans int;
declare max_loans int;
select ifnull(`Number of Loans`,0) into number_of_loans
from `number of loans by member` 
where Member_ID = new.Member_ID;



select `Max loanable items` into max_loans from `max loan ability`
where  Member_ID = new.Member_ID  ;


if max_loans - number_of_loans = 0 then signal sqlstate '45000' 
set message_text = 'Max loan amount reached';
END IF;


END $$

DELIMITER ;

DELIMITER $$

create trigger check_resource_not_already_loaned_by_member 
before insert on Loan for each row

BEGIN 

declare number_of_loans_of_resource int;

select count(Loan_ID) into number_of_loans_of_resource
 from `outstanding loans with due date` 
 where Member_ID=new.Member_ID and Resource_ID = new.Resource_ID;



if number_of_loans_of_resource > 0 then signal sqlstate '45000' 
set message_text = 'Item already loaned out by member';
END IF;


END $$

DELIMITER ;

DELIMITER $$

create trigger check_resource_not_reference 
before insert on Loan for each row

BEGIN 

declare resource_borrowable_time int;

select Borrowable_time into resource_borrowable_time 
from Resource 
where Resource_ID = new.Resource_ID;


if resource_borrowable_time = 0 then signal sqlstate '45000' 
set message_text = 'Item is reference item';
END IF;


END $$

DELIMITER ;

CREATE TABLE Paid_Fines_Record
(LOAN_ID MEDIUMINT(10) NOT NULL,
Member_ID SMALLINT(5) NOT NULL,
Amount_Paid SMALLINT(6) NOT NULL,
Date_Paid date NOT NULL);

CREATE VIEW FINES AS
SELECT l.Loan_ID, m.Member_ID
			, CASE WHEN Date_Returned IS NULL THEN
					DATEDIFF(CURDATE(), DATE_ADD(Date_Taken_Out, INTERVAL Borrowable_Time Day)) -- IF NOT RETUREND
					ELSE DATEDIFF(Date_Returned, DATE_ADD(Date_Taken_Out, INTERVAL Borrowable_Time Day)) -- IF RETURNED, ONLY OWE OVERDUE FINE UP UNTIL RETURN
					END AS FINE_AMOUNT 
	FROM Loan l
	INNER JOIN Resource r
	ON l.Resource_ID = r.Resource_ID
	INNER JOIN Member m
	ON l.Member_ID = m.Member_ID
	WHERE l.Date_Paid is NULL AND ((Date_Returned is NULL AND ADDDATE(l.Date_Taken_Out, INTERVAL r.borrowable_time DAY) < CURDATE())
    OR (ADDDATE(l.Date_Taken_Out, INTERVAL r.borrowable_time DAY) < Date_Returned)); -- all overdue items

delimiter //
Create Trigger fine_paid
Before Update On Loan
For Each Row
Begin
	Declare FINE int;
    SELECT FINE_AMOUNT into FINE
    FROM FINES
    where Loan_ID=new.Loan_ID;

	IF ((FINE IS NOT NULL) AND (NEW.DATE_PAID IS NOT NULL))
    THEN
		BEGIN
		INSERT INTO Paid_Fines_Record
        VALUES(New.Loan_ID,New.Member_ID,FINE,NEW.DATE_PAID);
		END;
	
		ELSEIF ((FINE>0) AND (NEW.DATE_PAID IS NULL))
		THEN
		signal sqlstate '45000' set message_text = 'Fine needs to be paid';
        
	END IF;
END// 

delimiter ;