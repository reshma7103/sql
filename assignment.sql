'''
Question 1: Explain the fundamental differences between DDL, DML, and DQL commands in SQL. Provide one example for each type of command.
'''

Answer

Definition:
DDL commands are used to define, create, and modify the structure of database objects such as tables, schemas, or indexes.
These commands affect the database schema and are auto-committed — meaning changes are permanent immediately.

Common Commands: CREATE, ALTER, DROP, TRUNCATE, RENAME

Example (Using World Dataset):
Create a new table to store details of high-population cities from the City table.


use world;

DROP TABLE IF EXISTS HighPopulationCities;

CREATE TABLE HighPopulationCities (
    CityID INT PRIMARY KEY,
    CityName VARCHAR(100),
    CountryCode CHAR(3),
    Population INT
);

DML (Data Manipulation Language)
Definition:
DML commands are used to manipulate or modify data stored inside tables.
They handle insertion, updating, and deletion of records.

Common Commands: INSERT, UPDATE, DELETE

Example (Using World Dataset):

-- insert data from City table where population > 1,000,000 (DML)

INSERT INTO HighPopulationCities (CityID, CityName, CountryCode, Population)
SELECT ID, Name, CountryCode, Population
FROM City
WHERE Population > 1000000;

DQL (Data Query Language)

Definition:
DQL commands are used to query or retrieve data from the database.
They do not modify the data but display it based on certain conditions.

Common Command: SELECT

Example (Using World Dataset):

-- query the results for India (DQL)

SELECT CityName, Population
FROM HighPopulationCities
WHERE CountryCode = 'IND'
ORDER BY Population DESC;

--------------------------------------------------------------------------------------------------
'''
Question 2: What is the purpose of SQL constraints? Name and describe three common types of constraints, providing a simple scenario where each would be useful.
'''

Purpose of SQL Constraints:
SQL constraints are rules enforced on data in a table to maintain data integrity, accuracy, and reliability.
They ensure that the data entered into a database follows defined business rules — for example, preventing duplicate IDs, null values in mandatory fields, or invalid foreign references.

Three Common Types of SQL Constraints

PRIMARY KEY Constraint

Definition:
A Primary Key uniquely identifies each record in a table.
No two rows can have the same key value, and it cannot be NULL.

USE sakila;

-- Creating a simple demo table with PRIMARY KEY
CREATE TABLE CustomerDemo (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

-- Inserting records
INSERT INTO CustomerDemo VALUES (1, 'Alice', 'Kumar');
INSERT INTO CustomerDemo VALUES (2, 'Bob', 'Rao');





FOREIGN KEY Constraint

Definition:
A Foreign Key links data between two tables — it enforces referential integrity by ensuring that a value in one table corresponds to a valid entry in another.

-- Creating a Rental table referencing CustomerDemo
CREATE TABLE RentalDemo (
    rental_id INT PRIMARY KEY,
    rental_date DATE,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES CustomerDemo(customer_id)
);

-- Insert valid record (customer_id exists)
INSERT INTO RentalDemo VALUES (1, '2025-11-12', 1);




CHECK Constraint

Definition:
A Check constraint ensures that a column’s value meets a specific condition.


-- Creating a table with a CHECK constraint
CREATE TABLE RentalPeriodDemo (
    rental_id INT PRIMARY KEY,
    rental_days INT CHECK (rental_days <= 7)
);

-- Valid record
INSERT INTO RentalPeriodDemo VALUES (1, 5);



---------------------------------------------------------
'''
Question 3: Explain the difference between LIMIT and OFFSET clauses in SQL. How would you use them together to retrieve the third page of results, assuming each page has 10 records?
'''

The LIMIT and OFFSET clauses in SQL are used together to control how many rows are displayed from a query result — especially useful when implementing pagination.

LIMIT Clause

The LIMIT clause restricts the number of rows returned by the query.

It specifies how many records should appear in the output.


SELECT Name, Continent, Population
FROM Country
LIMIT 10;


OFFSET Clause

The OFFSET clause tells SQL how many rows to skip before starting to show the results.

It is often used along with LIMIT to view results page by page.

SELECT Name, Continent, Population
FROM Country
LIMIT 10 OFFSET 10;

 Using LIMIT and OFFSET Together (Pagination Example)

To show the third page of results, where each page has 10 records:

Each page has 10 rows.

Page 1 → OFFSET 0

Page 2 → OFFSET 10

Page 3 → OFFSET 20

USE world;

SELECT Code, Name, Continent, Population
FROM Country
ORDER BY Name
LIMIT 10 OFFSET 20;

---------------------------------------------------------------------------------
'''
Question 4: What is a Common Table Expression (CTE) in SQL, and what are its main benefits? Provide a simple SQL example demonstrating its usage.
'''

A Common Table Expression (CTE) is a temporary result set in SQL that exists only for the duration of a single query.
It allows you to write modular, readable, and reusable SQL code by defining a temporary “virtual table” using the WITH keyword.

Main Benefits of a CTE:

 Improves Readability:
Makes complex SQL queries easier to read and maintain.

Simplifies Reuse:
The CTE can be referenced multiple times in the same query.

Useful for Recursive Queries:
Allows you to perform operations like hierarchical or tree-based queries.

 Temporary & Memory Efficient:
The CTE is not stored as a table — it only exists during query execution.

USE world;

WITH AvgPopulation AS (
    SELECT AVG(Population) AS AvgPop
    FROM Country
)
SELECT Name, Continent, Population
FROM Country, AvgPopulation
WHERE Country.Population > AvgPopulation.AvgPop
ORDER BY Population DESC;

--------------------------------------------------------------------------
'''
Question 5: Describe the concept of SQL Normalization and its primary goals. Briefly explain the first three normal forms (1NF, 2NF, 3NF).
'''

SQL Normalization is the process of organizing data in a database to reduce redundancy and improve data integrity. It ensures that data is stored efficiently and consistently by dividing large tables into smaller related tables.
The primary goals of normalization are:
•	To eliminate duplicate data.
•	To reduce update, insert, and delete anomalies.
•	To ensure data is stored in a logical and consistent way.
First Normal Form (1NF):
A table is in 1NF when each column contains atomic (indivisible) values, and there are no repeating groups or arrays.

USE sakila;

DROP TABLE IF EXISTS FilmsRaw;
CREATE TABLE FilmsRaw (
  film_id INT,
  title VARCHAR(128),
  ActorsList VARCHAR(255)   -- comma-separated actor names (violates 1NF)
);

INSERT INTO FilmsRaw VALUES
(1, 'Some Movie', 'Tom Hanks, Meg Ryan'),
(2, 'Another Film', 'Brad Pitt, Angelina Jolie, Morgan Freeman');

DROP TABLE IF EXISTS FilmActor_1NF;
CREATE TABLE FilmActor_1NF (
  film_id INT,
  title VARCHAR(128),
  actor_name VARCHAR(100)
);

-- Split up to 5 actors (adjust if you need more)
INSERT INTO FilmActor_1NF (film_id, title, actor_name)
SELECT film_id, title,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ActorsList, ',', n.n), ',', -1)) AS actor_name
FROM FilmsRaw
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
  ON CHAR_LENGTH(ActorsList) - CHAR_LENGTH(REPLACE(ActorsList, ',', '')) + 1 >= n.n;





Second Normal Form (2NF):
A table is in 2NF when it is already in 1NF and every non-key attribute depends on the whole primary key, not just part of it. This applies when the table has a composite primary key.

USE sakila;

DROP TABLE IF EXISTS FilmLang_1NF;
CREATE TABLE FilmLang_1NF (
  film_id INT,
  film_title VARCHAR(128),
  language_name VARCHAR(50),
  PRIMARY KEY (film_id, language_name)
);

INSERT INTO FilmLang_1NF VALUES
(1, 'Some Movie', 'English'),
(1, 'Some Movie', 'French'),
(2, 'Another Film', 'English');

-- Convert to 2NF: film_title depends only on film_id (partial dependency removed)
DROP TABLE IF EXISTS FilmDetails;
CREATE TABLE FilmDetails (
  film_id INT PRIMARY KEY,
  film_title VARCHAR(128)
);

DROP TABLE IF EXISTS FilmLanguages;
CREATE TABLE FilmLanguages (
  film_id INT,
  language_name VARCHAR(50),
  PRIMARY KEY (film_id, language_name),
  FOREIGN KEY (film_id) REFERENCES FilmDetails(film_id)
);

INSERT INTO FilmDetails (film_id, film_title)
SELECT DISTINCT film_id, film_title FROM FilmLang_1NF;

INSERT INTO FilmLanguages (film_id, language_name)
SELECT film_id, language_name FROM FilmLang_1NF;

Third Normal Form (3NF):
A table is in 3NF when it is already in 2NF and has no transitive dependencies. This means non-key attributes must depend only on the primary key and not on other non-key attributes.

USE sakila;

DROP TABLE IF EXISTS CustomerRaw;
CREATE TABLE CustomerRaw (
  customer_id INT,
  customer_name VARCHAR(100),
  phone VARCHAR(20),
  city_name VARCHAR(100),
  country_name VARCHAR(100)
);

INSERT INTO CustomerRaw VALUES
(1, 'Alice Kumar', '111-222-3333', 'Mumbai', 'India'),
(2, 'Bob Rao', '222-333-4444', 'Pune', 'India'),
(3, 'Carol Chen', '333-444-5555', 'Beijing', 'China');

-- Create normalized tables
DROP TABLE IF EXISTS CountryDemo;
CREATE TABLE CountryDemo (
  country_id INT AUTO_INCREMENT PRIMARY KEY,
  country_name VARCHAR(100) UNIQUE
);

DROP TABLE IF EXISTS CityDemo;
CREATE TABLE CityDemo (
  city_id INT AUTO_INCREMENT PRIMARY KEY,
  city_name VARCHAR(100),
  country_id INT,
  FOREIGN KEY (country_id) REFERENCES CountryDemo(country_id)
);

DROP TABLE IF EXISTS AddressDemo;
CREATE TABLE AddressDemo (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  phone VARCHAR(20),
  city_id INT,
  FOREIGN KEY (city_id) REFERENCES CityDemo(city_id)
);

DROP TABLE IF EXISTS CustomerDemo;
CREATE TABLE CustomerDemo (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  address_id INT,
  FOREIGN KEY (address_id) REFERENCES AddressDemo(address_id)
);

-- Populate CountryDemo (unique countries)
INSERT IGNORE INTO CountryDemo (country_name)
SELECT DISTINCT country_name FROM CustomerRaw;

-- Populate CityDemo and link to CountryDemo
INSERT INTO CityDemo (city_name, country_id)
SELECT DISTINCT cr.city_name, cd.country_id
FROM CustomerRaw cr
JOIN CountryDemo cd ON cd.country_name = cr.country_name
-- ignore duplicates by selecting distinct pairs

ON DUPLICATE KEY UPDATE city_id = city_id; -- harmless no-op for duplicates

-- Populate AddressDemo
INSERT INTO AddressDemo (phone, city_id)
SELECT cr.phone, c.city_id
FROM CustomerRaw cr
JOIN CityDemo c ON c.city_name = cr.city_name
  AND c.country_id = (SELECT country_id FROM CountryDemo WHERE country_name = cr.country_name);

-- Populate CustomerDemo linking to address_id (assumes insertion order: addresses inserted in same order as customers; safer would be to MATCH by phone)
INSERT INTO CustomerDemo (customer_id, customer_name, address_id)
SELECT cr.customer_id, cr.customer_name, a.address_id
FROM CustomerRaw cr
JOIN AddressDemo a ON a.phone = cr.phone;


-------------------------------------------------------------------------------------------------------
'''
Question 6 : Create a database named ECommerceDB and perform the following tasks:
'''

-- 0) Create and select the database
CREATE DATABASE IF NOT EXISTS ECommerceDB
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE ECommerceDB;

-- 1) Create tables (order matters because of foreign keys)
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Categories;


CREATE TABLE Categories (
  CategoryID   INT PRIMARY KEY,
  CategoryName VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Customers (
  CustomerID   INT PRIMARY KEY,
  CustomerName VARCHAR(100) NOT NULL,
  Email        VARCHAR(100) UNIQUE,
  JoinDate     DATE
) ENGINE=InnoDB;

CREATE TABLE Products (
  ProductID     INT PRIMARY KEY,
  ProductName   VARCHAR(100) NOT NULL UNIQUE,
  CategoryID    INT,
  Price         DECIMAL(10,2) NOT NULL,
  StockQuantity INT,
  CONSTRAINT fk_products_category
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Orders (
  OrderID     INT PRIMARY KEY,
  CustomerID  INT,
  OrderDate   DATE NOT NULL,
  TotalAmount DECIMAL(10,2),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2) Insert data

-- Categories
INSERT INTO Categories (CategoryID, CategoryName) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Home Goods'),
(4, 'Apparel');

-- Products
INSERT INTO Products (ProductID, ProductName, CategoryID, Price, StockQuantity) VALUES
(101, 'Laptop Pro', 1, 1200.00, 50),
(102, 'SQL Handbook', 2, 45.50, 200),
(103, 'Smart Speaker', 1, 99.99, 150),
(104, 'Coffee Maker', 3, 75.00, 80),
(105, 'Novel : The Great SQL', 2, 25.00, 120),
(106, 'Wireless Earbuds', 1, 150.00, 100),
(107, 'Blender X', 3, 120.00, 60),
(108, 'T-Shirt Casual', 4, 20.00, 300);

-- Customers
INSERT INTO Customers (CustomerID, CustomerName, Email, JoinDate) VALUES
(1, 'Alice Wonderland', 'alice@example.com', '2023-01-10'),
(2, 'Bob the Builder',  'bob@example.com',   '2022-11-25'),
(3, 'Charlie Chaplin',  'charlie@example.com','2023-03-01'),
(4, 'Diana Prince',     'diana@example.com',  '2021-04-26');

-- Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(1001, 1, '2023-04-26', 1245.50),
(1002, 2, '2023-10-12', 99.99),
(1003, 1, '2023-07-01', 145.00),
(1004, 3, '2023-01-14', 150.00),
(1005, 2, '2023-09-24', 120.00),
(1006, 1, '2023-06-19', 20.00);


select * from Products;
-------------------------------------------------------------------------------------------------
'''
Question 7 : Generate a report showing CustomerName, Email, and the
TotalNumberofOrders for each customer. Include customers who have not placed
any orders, in which case their TotalNumberofOrders should be 0. Order the results
by CustomerName
'''

SELECT 
    c.CustomerName,
    c.Email,
    COUNT(o.OrderID) AS TotalNumberOfOrders
FROM 
    Customers c
LEFT JOIN 
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName, c.Email
ORDER BY 
    c.CustomerName;
    
--------------------------------------------------------------------------------------------------------------

'''
Question 8 : Retrieve Product Information with Category: Write a SQL query to
display the ProductName, Price, StockQuantity, and CategoryName for all
products. Order the results by CategoryName and then ProductName alphabetically.
'''

SELECT 
    p.ProductName,
    p.Price,
    p.StockQuantity,
    c.CategoryName
FROM 
    Products p
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    c.CategoryName,
    p.ProductName;
------------------------------------------------------------------------------------------------------------
    
    '''
    Question 9 : Write a SQL query that uses a Common Table Expression (CTE) and a
Window Function (specifically ROW_NUMBER() or RANK()) to display the
CategoryName, ProductName, and Price for the top 2 most expensive products in
each CategoryName.
'''

USE ECommerceDB;

WITH ranked AS (
  SELECT
    ca.CategoryName,
    p.ProductName,
    p.Price,
    ROW_NUMBER() OVER (
      PARTITION BY ca.CategoryID
      ORDER BY p.Price DESC, p.ProductName
    ) AS rn
  FROM Products AS p
  JOIN Categories AS ca
    ON ca.CategoryID = p.CategoryID
)
SELECT CategoryName, ProductName, Price
FROM ranked
WHERE rn <= 2
ORDER BY CategoryName, Price DESC, ProductName;

---------------------------------------------------------------------------------------------------------
'''
Question 10 : You are hired as a data analyst by Sakila Video Rentals, a global movie
rental company. The management team is looking to improve decision-making by
analyzing existing customer, rental, and inventory data.
Using the Sakila database, answer the following business questions to support key strategic
initiatives
'''

'''
10(1). Identify the top 5 customers based on the total amount they’ve spent. Include customer
'''
USE sakila;
SELECT 
    c.first_name AS CustomerName,
    c.last_name AS LastName,
    c.email,
    SUM(p.amount) AS TotalSpent
FROM customer c
JOIN payment p 
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY TotalSpent DESC
LIMIT 5;

'''
10(2). Which 3 movie categories have the highest rental counts? Display the category name
and number of times movies from that category were rented.
'''

SELECT 
    cat.name AS CategoryName,
    COUNT(r.rental_id) AS RentalCount
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
GROUP BY cat.category_id
ORDER BY RentalCount DESC
LIMIT 3;


'''
10(3). Calculate how many films are available at each store and how many of those have
never been rented.
'''

SELECT 
    s.store_id,
    COUNT(i.inventory_id) AS TotalFilmsAvailable
FROM store s
JOIN inventory i ON s.store_id = i.store_id
GROUP BY s.store_id;

SELECT 
    s.store_id,
    COUNT(i.inventory_id) AS NeverRentedFilms
FROM store s
JOIN inventory i ON s.store_id = i.store_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.rental_id IS NULL
GROUP BY s.store_id;

'''
10(4). Show the total revenue per month for the year 2023 to analyze business seasonality
'''



SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(amount) AS total_revenue
FROM payment
WHERE payment_date >= '2023-01-01'
  AND payment_date <  '2024-01-01'
GROUP BY 
    DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY 
    month;



'''
10(5). Identify customers who have rented more than 10 times in the last 6 months.
'''

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS RentalsLast6Months
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.customer_id
HAVING RentalsLast6Months > 10
ORDER BY RentalsLast6Months DESC;





