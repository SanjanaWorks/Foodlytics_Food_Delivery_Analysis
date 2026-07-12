--Exploring Customer Behavior Through Database Analysis
--Title: Foodlytics: SQL-Based Food Delivery Customer & Revenue Analysis

/* Objective: Analyze customer purchasing behavior, product performance
and Gold Membership effectiveness using SQL.

Business Goals:
		Find top-selling products
		Identify high-value customers
		Analyze Gold Membership impact
		Track revenue trends
		Understand customer ordering behavior 
*/


/* Create your own records?
The provided case study PDF contained incomplete dataset pages. 
The table structures and business requirements were available, but some records were missing. 
Therefore, I designed a realistic sample dataset aligned with the ER diagram and business 
rules to perform the complete SQL analysis and demonstrate data analyst problem-solving skills.
*/

--Phase 1: Database Design
--Database Name:
Create Database FoodDelivery_db;
Use FoodDelivery_db;

--Table 1: Product: Stores product details and prices.
Create Table Product
(
	Product_id int Primary Key,
	Product_Name varchar(100),
	Price int
);
Select * from Product;

--Table 2: Users: Stores customer registration information.
Create Table Users 
(
	User_id int Primary Key,
	Signup_date Date
);
Select * from Users;

--Table 3: User_Name: Stores customer names.
Create Table User_Name
(
	User_id int Primary Key,
	Names varchar(100)
);
Select * from User_Name;

--Table 4: Goldusers_signup: Stores premium membership details.
Create Table GoldUsers_Signup
(
	User_id int Primary Key,
	Gold_Signup_Date Date
);
Select * from GoldUsers_Signup;

--Table 5: Sales: Stores every order transaction.
Create Table Sales
(
	Sale_id int identity(1,1) Primary Key,
	User_id int,
	Created_Date Date,
	Product_id int,
	Foreign Key(User_id)
	references Users(User_id),
	Foreign Key(Product_id)
	references Product(Product_id)
);
Select * from Sales;


--Phase 3: Insert Data
--1.Product Table
Insert into Product values
(1,'Dal Makani',160),
(2,'Shahi Panner',170),
(3,'Butter Chicken',340),
(4,'Aloo Gobi',150),
(5,'Chole Bhature',100),
(6,'Fish Curry',380),
(7,'Chicken Tikka',300),
(8,'Mutton Biryani',450),
(9,'Veg Pulao',200),
(10,'Mango Lassi',80),
(11,'Gulab Jamun',100);
Select * from Product;

--2.User_Name
Insert into User_Name values
(1,'Anshul'),
(2,'Rohan'),
(3,'Shreya'),
(4,'Priya'),
(5,'Aryan'),
(6,'Sara'),
(7,'Sahil'),
(8,'Tanvi'),
(9,'Ritika'),
(10,'Gaurav');
Select * from User_Name;

--3. Users
Insert into Users values
(1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11'),
(4,'2015-11-17'),
(5,'2015-09-08'),
(6,'2014-07-13'),
(7,'2013-04-02'),
(8,'2013-12-15'),
(9,'2016-01-02'),
(10,'2016-01-02');
Select * from Users;

--4.Gold Members
Insert into Goldusers_signup values
(1,'2017-09-22'),
(3,'2018-04-21'),
(4,'2017-01-15'),
(7,'2019-03-10'),
(9,'2018-11-25');
Select * from GoldUsers_Signup;

--5.Sales
Insert into Sales(User_id, Created_Date, Product_id)
values
(1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3),
(4,'2019-05-01',1),
(5,'2018-11-23',3),
(6,'2017-06-30',9),
(7,'2018-08-12',8),
(8,'2019-03-19',7),
(9,'2017-12-04',6),
(10,'2018-09-22',2),
(4,'2020-08-17',1),
(5,'2017-05-12',10),
(6,'2014-01-27',11),
(7,'2014-04-02',7),
(8,'2020-12-15',8),
(9,'2017-09-08',8);
Select * from Sales;


--Q1. What is the total amount each customer spent on food?
--Query:
SELECT
    s.User_ID,
    un.Names,
    SUM(p.Price) AS Total_Spent
FROM Sales s
JOIN Product p
ON s.Product_ID = p.Product_ID
JOIN User_Name un
ON s.User_ID = un.User_ID
GROUP BY s.User_ID, un.Names
ORDER BY Total_Spent DESC;
--Business Insight: Anshul is the highest spending customer.


--Q2. How many days has each customer visited?
--Query:
SELECT
User_ID,
COUNT(DISTINCT Created_Date) AS Visit_Days
FROM Sales
GROUP BY User_ID;
--Business Insight: User 1 is the most active customer.

--Q3. What was the first product purchased by each customer?
--Query: ROW_NUMBER finds the earliest order.
WITH CTE AS
(
SELECT *,
ROW_NUMBER() OVER
(
PARTITION BY User_ID
ORDER BY Created_Date
) rn
FROM Sales
)

SELECT
c.User_ID,
u.Names,
p.Product_Name,
c.Created_Date
FROM CTE c
JOIN Product p
ON c.Product_ID=p.Product_ID
JOIN User_Name u
ON c.User_ID=u.User_ID
WHERE rn=1;
--Business Insight: Several customers started with Dal Makani.

--Q4. What is the most purchased item?
--Query:
SELECT
TOP 1
p.Product_Name,
COUNT(*) AS Purchase_Count
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
GROUP BY p.Product_Name
ORDER BY Purchase_Count DESC;
--Business Insight: Shahi Panner is the menu bestseller.

--Q5. Which item was most popular for each customer?
--Query:
WITH CTE AS
(
SELECT
User_ID,
Product_ID,
COUNT(*) Orders_Count,
RANK() OVER
(
PARTITION BY User_ID
ORDER BY COUNT(*) DESC
) rnk
FROM Sales
GROUP BY User_ID, Product_ID
)

SELECT
c.User_ID,
u.Names,
p.Product_Name,
Orders_Count
FROM CTE c
JOIN Product p
ON c.Product_ID=p.Product_ID
JOIN User_Name u
ON c.User_ID=u.User_ID
WHERE rnk=1;
-- Business Insight: Shahi Panner dominates customer preferences.

--Q6. Which item was purchased first after becoming a Gold Member?
--Query:
WITH CTE AS
(
SELECT
s.User_ID,
s.Product_ID,
s.Created_Date,
ROW_NUMBER() OVER
(
PARTITION BY s.User_ID
ORDER BY s.Created_Date
) rn
FROM Sales s
JOIN GoldUsers_Signup g
ON s.User_ID=g.User_ID
WHERE s.Created_Date >= g.Gold_Signup_Date
)
SELECT
c.User_ID,
u.Names,
p.Product_Name,
c.Created_Date
FROM CTE c
JOIN Product p
ON c.Product_ID=p.Product_ID
JOIN User_Name u
ON c.User_ID=u.User_ID
WHERE rn=1;
-- Business Insight: Shows what customers bought immediately after upgrading.

--Q7. Which item was purchased just before becoming a Gold Member?
--Query:
WITH CTE AS
(
SELECT
s.User_ID,
s.Product_ID,
s.Created_Date,
ROW_NUMBER() OVER
(
PARTITION BY s.User_ID
ORDER BY s.Created_Date DESC
) rn
FROM Sales s
JOIN GoldUsers_Signup g
ON s.User_ID=g.User_ID
WHERE s.Created_Date < g.Gold_Signup_Date
)
SELECT
c.User_ID,
u.Names,
p.Product_Name,
c.Created_Date
FROM CTE c
JOIN Product p
ON c.Product_ID=p.Product_ID
JOIN User_Name u
ON c.User_ID=u.User_ID
WHERE rn=1;
--Business Insight: Shows customer behavior before upgrading.

--Q8. Total Orders and Amount Spent Before Gold Membership
--Query:
SELECT
s.User_ID,
u.Names,
COUNT(*) Total_Orders,
SUM(p.Price) Total_Spent
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN GoldUsers_Signup g
ON s.User_ID=g.User_ID
JOIN User_Name u
ON s.User_ID=u.User_ID
WHERE s.Created_Date < g.Gold_Signup_Date
GROUP BY s.User_ID,u.Names;
--Business Insight: Measures spending before premium membership.

--Q9. Calculate Reward Points Earned By Each Customer
--Assumption: ₹100 = 10 Points
--Query:
SELECT
s.User_ID,
u.Names,
SUM(p.Price)/100*10 AS Reward_Points
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN User_Name u
ON s.User_ID=u.User_ID
GROUP BY s.User_ID,u.Names
ORDER BY Reward_Points DESC;

--Q10. Which Product Generated Highest Revenue?
--Query:
SELECT TOP 1
p.Product_Name,
SUM(p.Price) Revenue
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
GROUP BY p.Product_Name
ORDER BY Revenue DESC;
--Business Insight: Best revenue generating product.

--Q11. Revenue Generated By Each Product
--Query:
SELECT
p.Product_Name,
SUM(p.Price) Revenue
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
GROUP BY p.Product_Name
ORDER BY Revenue DESC;
--Business Insight: Useful for menu optimization.

--Q12. Which Customer Spent Most Money?
--Query:
SELECT TOP 1
u.Names,
SUM(p.Price) TotalSpent
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN User_Name u
ON s.User_ID=u.User_ID
GROUP BY u.Names
ORDER BY TotalSpent DESC;
--Business Insight: Highest value customer.

--Q13. Which Year Generated Highest Revenue?
--Query:
SELECT
YEAR(Created_Date) Sales_Year,
SUM(p.Price) Revenue
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
GROUP BY YEAR(Created_Date)
ORDER BY Revenue DESC;
--Business Insight: Best performing year.

--Q14. Number of Gold Members
--Query:
SELECT COUNT(*) AS GoldMembers FROM GoldUsers_Signup;
--Business Insight: 5 of 10 users upgraded.

--Q15. Percentage of Users Who Became Gold Members
--Query:
SELECT
COUNT(*)*100.0/
(SELECT COUNT(*) FROM Users)
AS Gold_Percentage
FROM GoldUsers_Signup;
--Business Insight: Half of customers converted.

--Q16. Revenue Generated By Gold Members
--Query:
SELECT
SUM(p.Price) AS Gold_Revenue
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN GoldUsers_Signup g
ON s.User_ID=g.User_ID;
--Business Insight: Gold members contribute major revenue.

--Q17. Which Gold Member Spent Most?
--Query:
SELECT TOP 1
u.Names,
SUM(p.Price) TotalSpent
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN GoldUsers_Signup g
ON s.User_ID=g.User_ID
JOIN User_Name u
ON s.User_ID=u.User_ID
GROUP BY u.Names
ORDER BY TotalSpent DESC;
--Business Insight: Most valuable premium customer.

--Q18. Average Order Value
--Query:
SELECT
AVG(CAST(p.Price AS DECIMAL(10,2))) Avg_Order_Value
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID;
--Business Insight: Average customer spends around ₹290 per order.

--Q19. Rank Customers Based On Spending
--Query:
SELECT
u.Names,
SUM(p.Price) TotalSpent,
RANK() OVER
(
ORDER BY SUM(p.Price) DESC
) Spending_Rank
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN User_Name u
ON s.User_ID=u.User_ID
GROUP BY u.Names;
--Business Insight: Customer value segmentation.

--Q20. Rank Transactions Of Gold Members
--Query:
SELECT
s.User_ID,
u.Names,
s.Created_Date,
p.Product_Name,
RANK() OVER
(
PARTITION BY s.User_ID
ORDER BY s.Created_Date
) Transaction_Rank
FROM Sales s
JOIN Product p
ON s.Product_ID=p.Product_ID
JOIN GoldUsers_Signup g
ON s.User_ID=g.User_ID
JOIN User_Name u
ON s.User_ID=u.User_ID;
--Business Insight: Tracks purchase sequence and loyalty behavior.

