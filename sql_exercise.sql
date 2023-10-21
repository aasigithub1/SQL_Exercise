

create table cust1
(c_id int primary key,
cname varchar(30) not null,
country varchar(25)
);

insert into cust1 values
(11,'Mark','Germany'),
(12,'Vikrant','India'),
(13,'Jacob','Spain'),
(14,'Victor','Germany'),
(15,'Emily','France'),
(16,'Vicent','Italy'),
(17,'Shashank','India'),
(18,'Anupam','India'),
(19,'Dustin','France'),
(20,'Claudia','Spain'),
(21,'Mark','Spain'),
(22,'Zoe','Spain'),
(23,'Anisha','India'),
(24,'Morata','Italy'),
(25,'Antonie','Germany');

drop table prod1;
create table prod1
(p_id int primary key,
pdesc varchar(50), 
price int);

insert into prod1 values
(101,'Book', 110),
(102,'Wallet', 210),
(103,'T-Shirt', 310),
(104,'Slippers', 180),
(105,'Sports_Shoe', 450),
(106,'Bottle', 150),
(107,'Football', 570),
(108,'KeyChain', 45),
(109,'Adapter', 160),
(110,'SmartWatch', 950);

drop table orders1;
create table orders1
(o_id varchar(10) primary key,
c_id int not null,
p_id int not null,
order_date date,
qty int,
Ordered_from varchar(100)
);


insert into orders1 values
('A1',12,107,'2022-11-20',1,'Amazon'),
('A2',11,108,'2022-12-15',5,'Ebay'),
('A3',12,107,'2022-10-18',2,'Amazon'),
('A4',14,101,'2023-02-05',4,'Ebay'),
('A5',17,103,'2022-11-30',7,'Walmart'),  
('A6',18,102,'2023-01-07',1,'Amazon'),    
('A7',13,105,'2022-12-10',2,'Walmart'),
('A8',18,103,'2023-01-07',2,'Alibaba'),   
('A9',21,106,'2022-12-24',1,'Walmart'),
('A10',24,103,'2022-12-27',3,'Amazon'),  
('A11',13,110,'2022-12-27',1,'Walmart'),
('A12',21,104,'2023-01-16',2,'Ebay'),
('A13',25,109,'2023-02-12',2,'Alibaba'),
('A14',22,107,'2023-03-09',1,'Ebay'),   
('A15',22,108,'2022-09-05',3,'Alibaba'),   
('A16',25,103,'2022-09-20',2,'Amazon'),
('A17',15,110,'2022-12-19',1,'Walmart'),
('A18',20,104,'2023-03-11',2,'Amazon'),
('A19',12,101,'2022-12-24',2,'Alibaba'),
('A20',25,109,'2023-01-02',3,'Alibaba'),    
('A21',16,101,'2023-01-01',4,'Walmart'),
('A22',11,102,'2023-02-08',2,'Ebay'),
('A23',23,103,'2023-03-14',1,'Alibaba'),
('A24',12,105,'2023-03-11',3,'Alibaba'),
('A25',21,103,'2022-11-30',2,'Amazon'),     
('A26',22,103,'2022-12-22',5,'Amazon'),
('A27',24,108,'2022-10-15',8,'Ebay'),
('A28',22,109,'2022-09-05',5,'Walmart'),    
('A29',12,108,'2023-03-09',4,'Alibaba'),    
('A30',23,101,'2022-11-20',2,'Amazon');

create table inventory1
(Proprietry varchar(100),
Prod_ID int,
Stock_Level int);

insert into inventory1 values
('Amazon',101,5),('Amazon',102,5),('Amazon',103,15),('Amazon',104,7),
('Amazon',105,10),('Amazon',106,6),('Amazon',107,5),('Amazon',108,6),
('Amazon',109,8),('Amazon',110,9),
('Alibaba',101,8),('Alibaba',102,6),('Alibaba',103,5),('Alibaba',104,10),
('Alibaba',105,5),('Alibaba',106,4),('Alibaba',107,8),('Alibaba',108,10),
('Alibaba',109,7),('Alibaba',110,15),
('Walmart',101,7),('Walmart',102,10),('Walmart',103,10),('Walmart',104,4),
('Walmart',105,5),('Walmart',106,6),('Walmart',107,4),('Walmart',108,6),
('Walmart',109,8),('Walmart',110,5),
('Ebay',101,5),('Ebay',102,6),('Ebay',103,7),('Ebay',104,6),
('Ebay',105,8),('Ebay',106,10),('Ebay',107,5),('Ebay',108,15),
('Ebay',109,5),('Ebay',110,7);


# cust1 - (c_id,cname,country)
# prod1 - (p_id,pdesc,price)
# orders1 - (o_id,c_id,p_id,order_date,qty,ordered_from)
# inventory1 - (Proprietry,Prod_Id,Stock_Level)

# Q1) Find top 5 customers who have spent the most. 
# Return C_ID,Customer Name, Country, amount spend. 
# If a customer has multiple orders then sum of amount has to be displayed for
# each c_id, cname and country.

# Q2) Rank top 3 customers from each country who spend the most.
# Return Country, Customer name, amount spend(in descreasing order) and 
# Rank in ascending order.

# Q3) Find customers who have spend more than avg amount spend by all customers.
# Return C_ID, Customer name, and Amount. Solve 
# a) using Subquery
# b) using CTE

# Q4) Find customers who have spend 1000 or more in the month of Dec or Jan
# Return C_ID, Customer name, and Amount.

# Q5) Rank top 3 customers from each country who spend the most. 
# The result should only inlcude customers from each country where there are 
# at least 3 customers available from each country. 
# Return Country, Customer name, amount spend(in descreasing order) and 
# Rank in ascending order 

# Q6) Find the overall Median Amount. 

# Q7) Generate a Stored Prcoedure to find avg order amount for each Country. 
# Use Country as argument

# Q8) Generate a Stored Prcoedure to fetch top N customers who have spent most amount
# per ecommerce platform

# Q9) Find the customers who fall into the 3rd quartile(Q3) based on the 
# amount spend.

# Q10) Find year and month wise amount spend in decreasing order of Amount spend

# Q11) Generate a Stored Procedure to find Order statistics 
# ie:- min, max and mean Amount per Country.

# Q12) Find Country, Ecommerce Brand wise most sold product and its 
# count in terms of quantity.

# Q13) Find Country wise number of Customers who made an order. Also list 
# all the customer name along with the count

# Q14) If Amazon offers 12% disocunt in month of Jan, 
# Alibaba offers 15% discount in the month of Dec,
# Ebay offers 20% disocunt in Feb and Walmart offers 25% discount in Nov
# Compute month wise order amount after adjusting for discount. 

# Q15) Create an insert trigger into order1 tables that restricts setting 
# order qty to a negative number.Set it to 1 if order qty is less than 0.

# Q16) Create a order date validation trigger. The trigger should prevent
# insertion of an order with future order date. The err msg should be
# 'Future order dates not allowed'

# Q17) Create a trigger Preventing Invalid Product Orders. The trigger should
# prevent the insertion of an order if the specified product does not exist 
# in the prod1 table. Err msg should be 'Invalid product specified'

# Q18) Amazon has a return policy for 10 days, Walmart for 1 week, 
# Alibaba for 15 days, Ebay for 12 days. Create a SP to return the 
# total_price and return date for each order that the customer made. 
# The stored procedure accepts order_id as the argument

# Q19) Find Ecommerce_brand and Month wise sum of sales, where Ecommerce names
# are represented as Column Names and Month_Num is set as Index.

# Q20) Find Ecommerce brand and Prod_Id wise total qty sold.
# Ecommerce Brabd should be represented as seperate columns and prod_id should
# set as Index

# Q21) Create a mysql insert trigger that prevents ordering products more than
# the available stock levels. If such an order is made, the error text should 
# be 'Out of Stock'.
