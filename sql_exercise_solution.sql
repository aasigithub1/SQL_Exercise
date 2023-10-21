
# cust1 - (c_id,cname,country)
# prod1 - (p_id,pdesc,price)
# orders1 - (o_id,c_id,p_id,order_date,qty,ordered_from)
# inventory1 - (Proprietry,Prod_Id,Stock_Level)

# Q1) Find top 5 customers who have spent the most. 
# Return C_ID,Customer Name, Country, amount spend. 
# If a customer has multiple orders then sum of amount has to be displayed for
# each c_id, cname and country.

select c.c_id,c.cname,c.country, sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by c.c_id,c.cname,c.country 
order by Amount desc limit 5;

# Q2) Rank top 3 customers from each country who spend the most.
# Return Country, Customer name, amount spend(in descreasing order) and 
# Rank in ascending order 

select * from
(select c.country,c.cname, sum(p.price*o.qty) as Amount, row_number()
over (partition by Country order by sum(p.price*o.qty) desc) as Amount_Rank 
from cust1 c inner join orders1 o
on c.c_id = o.c_id
inner join prod1 p
on p.p_id = o.p_id
group by c.country,c.cname) dt
where Amount_Rank<=3
order by country;

# Q3) Find customers who have spend more than avg amount spend by all customers.
# Return C_ID, Customer name, and Amount. Solve 
# a) Using Subquery
# b) using CTE

# Method-1 - Using SubQuery
select c.c_id,c.cname, sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by c.c_id,c.cname 
having Amount > (select avg(Amt) from
(select c.c_id,c.cname, sum(p.price*o.qty) as Amt 
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by c.c_id,c.cname) dt); -- 1326.4286


# Using CTE
with cte1 as
(select c.c_id,c.cname, sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id 
inner join prod1 p on p.p_id = o.p_id
group by c.c_id,c.cname)
SELECT c_id, cname, Amount from cte1
WHERE Amount > (select AVG(Amount) FROM cte1); 


# Same ques with 2 ctes
with cte1 as
(select c.c_id,c.cname, sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id 
inner join prod1 p on p.p_id = o.p_id
group by c.c_id,c.cname),
cte2 as   # 1326.
(select avg(Amt) as AvgAmount from
(select c.c_id,c.cname, sum(p.price*o.qty) as Amt 
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by c.c_id,c.cname) dt)
select * from cte1 where Amount > (select AvgAmount FROM cte2);


# Q4) Find customers who have spend 1000 or more in the month of Dec or Jan
# Return C_ID, Customer name, and Amount 

select c.c_id,c.cname ,sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
where month(o.order_date) in (12,1)
group by c.c_id,c.cname 
having Amount > 1000;


# Q5) Rank top 3 customers from each country who spend the most. 
# The result should only inlcude customers from each country where there are 
# at least 3 customers available from each country. 
# Return Country, Customer name, amount spend(in descreasing order) and 
# Rank in ascending order 

select * from
(select c.country,c.cname, sum(p.price*o.qty) as Amount, row_number()
over (partition by Country order by sum(p.price*o.qty) desc) as AmountRank,
count(*) OVER (PARTITION BY Country) AS CountryCount
from cust1 c inner join orders1 o
on c.c_id = o.c_id
inner join prod1 p
on p.p_id = o.p_id
group by c.c_id,c.cname) dt
where AmountRank<=3 and CountryCount>=3 
order by country;


# Q6) Find the overall Median Amount. 

set @x = 10;
select @x;

create or replace view CPO1 as
select c.c_id,c.cname, sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o
on c.c_id = o.c_id
inner join prod1 p
on p.p_id = o.p_id
group by c.c_id,c.cname;

select * from CPO1;

SET @rowidx = -1; 
select @rowidx;

SELECT AVG(amount) as Median FROM
(SELECT @rowidx := @rowidx + 1 AS RowIndex, amount FROM cpo1
ORDER BY amount) AS dt
WHERE dt.RowIndex IN (FLOOR(@rowidx / 2), CEIL(@rowidx / 2));


# using percent rank
select amount, percent_rank() over (order by amount asc) as PRank
from cpo1;

# floor(13/2),ceil(13/2) (6, 7)

# Q7) Generate a SP to find avg order amount for each Country. 
# Use Country as argument.

drop procedure sp1;
delimiter //
create procedure sp1(in loc varchar(25))
begin
	select c.country, avg(p.price*o.qty) as Amt 
	from cust1 c inner join orders1 o
	on c.c_id = o.c_id
	inner join prod1 p
	on p.p_id = o.p_id
    where c.country=loc
	group by c.country; 
end //
delimiter ;

call sp1('Germany');


-- select avg(Amt) from 
-- (select c.country, sum(p.price*o.qty) as Amt 
-- from cust1 c inner join orders1 o
-- on c.c_id = o.c_id
-- inner join prod1 p
-- on p.p_id = o.p_id
-- where c.country='Germany'
-- group by c.country) dt;

-- select (7440 + 1730 + 6395 + 2505 + 950)/5;  # 3804

# Q8) Generate a Stored Procedure to fetch top N customers who have spent 
# most amount per ecommerce platform

delimiter //
create procedure sp2(in n int)
begin
    select * from 
	(select c.c_id,o.ordered_from, sum(p.price*o.qty) as Amount,
	row_number() over 
	(partition by o.ordered_from order by sum(p.price*o.qty) desc) as RNum
	from cust1 c inner join orders1 o on c.c_id = o.c_id
	inner join prod1 p on p.p_id = o.p_id
	group by c.c_id,o.ordered_from) dt
	where RNum<=n;	
end//
delimiter ;

call sp2(3);

# Q9) Find the customers who fall into the 3rd quartile(Q3) based on the 
# amount spend.
select * from 
(select Cname, Amount, ntile(4) over (order by Amount) AmtQuartile from CPO1) dt
where AmtQuartile=3;

# rank, dense_rank, row_num, lead,lag,ntile,percent_rank

# Q10) Find year and month wise amount spend in decreasing order of Amount spend.

select year(o.order_date) as Year, month(o.order_date) as Month, 
sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by Year, month
order by Amount desc;

# Q11) Generate a Stored Procedure to find Order statistics 
# ie:- min, max and mean Amount per Country.

#drop procedure sp3;

delimiter //
create procedure sp3()
begin
    SELECT c.country, MIN(p.price*o.qty) MinAmt, MAX(p.price*o.qty) MaxAmt, 
    AVG(p.price*o.qty) as AvgAmt
    FROM cust1 c inner join orders1 o
	on c.c_id = o.c_id inner join prod1 p on p.p_id = o.p_id
    group by c.country;
end//
delimiter ;

call sp3();

# Q12) Find Country, Ecommerce Brand wise most sold product and 
# its count in terms of quantity.

select c.country, o.ordered_from, p.pdesc, sum(qty) as SumQty # ,count(o.o_id) Count
from orders1 o inner join cust1 c on o.c_id = c.c_id
inner join prod1 p on o.p_id = p.p_id
group by c.country, o.ordered_from, p.pdesc
order by c.country, o.ordered_from;

select c.country,  p.pdesc, sum(qty) as SumQty # ,count(o.o_id) Count
from orders1 o inner join cust1 c on o.c_id = c.c_id
inner join prod1 p on o.p_id = p.p_id
group by c.country,  p.pdesc
order by c.country;

# Q13) Find Country wise number of Customers who made an order. Also list 
# all the customer name along with the count

select c.country, count(o.o_id) as Count, 
group_concat(distinct c.cname) as List_of_Customers
from cust1 c inner join orders1 o on o.c_id = c.c_id
inner join prod1 p on o.p_id = p.p_id
group by c.country;

# Q14) If amazon offers 12% disocunt in month of Jan, 
# Alibaba offers 15% discount in the month of Dec,
# Ebay offers 20% disocunt in Feb and Walmart offers 25% discount in Nov
# Compute month wise order amount after adjusting for discount. 

SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS MName, 
    SUM(p.price * o.qty) AS Org_Amount,
    SUM(CASE
        WHEN MONTH(o.order_date) = 1 AND o.ordered_from = 'Amazon' THEN 0.88 * p.price * o.qty
        WHEN MONTH(o.order_date) = 12 AND o.ordered_from = 'Alibaba' THEN 0.85 * p.price * o.qty
        WHEN MONTH(o.order_date) = 2 AND o.ordered_from = 'Ebay' THEN 0.80 * p.price * o.qty
        WHEN MONTH(o.order_date) = 11 AND o.ordered_from = 'Walmart' THEN 0.75 * p.price * o.qty
        ELSE p.price * o.qty
    END) AS Discounted_Amt
FROM cust1 c JOIN orders1 o ON c.c_id = o.c_id JOIN prod1 p ON p.p_id = o.p_id
GROUP BY MName ORDER BY MName ASC;


# Q15) Create an insert trigger into order1 tables that restricts setting 
# order qty to a negative number. Set it to 1 if order qty is less than 0.

use exercise;
select * from orders1;

# new old

show triggers;

delimiter //
create trigger before_insert_order 
before insert on orders1 for each row
begin
	if new.qty<0 then set new.qty=1;
	end if;
end//
delimiter ;

insert into orders1 values
('A32',20,102,'2023-01-29',-5,'Ebay');

select * from orders1;

# Q16) Create a order date validation trigger. The trigger should prevent
# insertion of an order with future order date. The err msg should be
# 'Future order dates not allowed'

select curdate();

DELIMITER //
CREATE TRIGGER validate_order_date
BEFORE INSERT ON orders1 FOR EACH ROW
BEGIN
  IF NEW.order_date > CURDATE() THEN
    SIGNAL SQLSTATE '45000'	
    SET MESSAGE_TEXT = 'Future order dates not allowed';
  END IF;
END//
DELIMITER ;

insert into orders1 values
('A33',15,105,'2023-10-21',4,'Amazon');

# Q17) Create a trigger Preventing Invalid Product Orders. The trigger should
# prevent the insertion of an order if the specified product does not exist 
# in the prod1 table. Err msg should be 'Invalid product specified'.

DELIMITER //
CREATE TRIGGER prevent_invalid_product
BEFORE INSERT ON orders1 FOR EACH ROW
BEGIN
  DECLARE product_count INT;
  SELECT COUNT(*) INTO product_count FROM prod1 WHERE p_id = NEW.p_id;
  IF product_count = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid product specified';
  END IF;
END//
DELIMITER ;

select * from prod1;
select count(*) from prod1 where p_id = 102;

insert into orders1 values
('A36',15,124,'2022-12-24',2,'Amazon');  # invalid product specified - err msg

insert into orders1 (o_id,c_id,order_date,qty,p_id,ordered_from) values
('A36',15,'2023-12-24',2,124,'Amazon');  # furture order date - err msg

insert into orders1 values
('A36',15,124,'2023-12-30',-7,'Amazon');


# Q18) Amazon has a return policy for 10 days, Walmart for 1 week, 
# Alibaba for 15 days, Ebay for 12 days. Create a SP to return the 
# total_amount and return date for each order that the customer made. 
# The stored procedure accepts order_id as the argument

drop procedure sp4;

DELIMITER //
create procedure sp4(in order_id varchar(20))
begin
select o.o_id, o.order_date,o.ordered_from,p.price,o.qty, 
sum(p.price*o.qty) as Amount,case 
when o.ordered_from ='Amazon' then adddate(o.order_date,10)
when o.ordered_from ='Walmart' then adddate(o.order_date,7)
when o.ordered_from ='Alibaba' then adddate(o.order_date,15)
when o.ordered_from ='Ebay' then adddate(o.order_date,12)
end as Return_Date
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
where o.o_id = order_id
group by o.o_id,o.order_date,o.ordered_from,p.price,o.qty, Return_Date;
end//
delimiter ;

call sp4('A30');
call sp4('A24');

# Q19) Find Ecommerce_brand and Month wise sum of sales, where Ecommerce names
# are represented as Column Names and Month_Num is set as Index.

# Simple Solution (without Pivoting)
select o.ordered_from, year(o.order_date) as Year, month(o.order_date) as Month,
sum(p.price*o.qty) as Amount
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by o.ordered_from , Year, Month
order by o.ordered_from, year, month;


# Expected Result
#          Oct22  Nov22  Dec22  Jan23 Feb23  
# Amazon   ...
# Ebay
# Walmart
# Alibaba

SELECT year(o.order_date) as Year, MONTH(o.order_date) AS MonthNum,
SUM(CASE WHEN o.ordered_from='Amazon' THEN p.price * o.qty ELSE 0 END) AS Amazon,
SUM(CASE WHEN o.ordered_from = 'Alibaba' THEN p.price * o.qty ELSE 0 END) AS Alibaba,
SUM(CASE WHEN o.ordered_from = 'Walmart' THEN p.price * o.qty ELSE 0 END) AS Walmart,
SUM(CASE WHEN o.ordered_from = 'Ebay' THEN p.price * o.qty ELSE 0 END) AS Ebay
FROM cust1 c INNER JOIN orders1 o ON c.c_id = o.c_id
INNER JOIN prod1 p ON p.p_id = o.p_id
GROUP BY Year, MonthNum ORDER BY Year, MonthNum;


# Q20) Find Ecommerce brand and Prod_Id wise total qty sold.
# Ecommerce Brand should be represented as seperate columns and prod_id should
# set as Index.
        
create or replace View Pid_SumQty as         
select p.p_id,
SUM(CASE WHEN o.ordered_from='Alibaba' THEN o.qty ELSE 0 END) AS Alibaba,
SUM(CASE WHEN o.ordered_from='Amazon' THEN o.qty ELSE 0 END) AS Amazon,
SUM(CASE WHEN o.ordered_from='Ebay' THEN o.qty ELSE 0 END) AS Ebay,
SUM(CASE WHEN o.ordered_from='Walmart' THEN o.qty ELSE 0 END) AS Walmart
from cust1 c inner join orders1 o on c.c_id = o.c_id
inner join prod1 p on p.p_id = o.p_id
group by p.p_id order by p.p_id;     

select * from Pid_SumQty;
        
        
# P_ID   Amazon   EBay  Alibaba   Walmart
# 101    ...
# 102


# Q21) Create a mysql insert trigger that prevents ordering products more than
# the available stock levels. If such an order is made, the error text should 
# be 'Out of Stock'.

# Inventory  qty   - 10  # i.stock_level
# Past Order1 qty  - 1
# Past Order2 qty  - 3
# Past Order3 qty  - 2  # total_ordered_qty = 1+3+2 = 6
# ...
# New order  qty -   3

# ordered_qty = total_ordered_qty + new_qty = 9

select * from inventory1;


delimiter //
create trigger prevent_over_order_tr1
BEFORE INSERT ON orders1 FOR EACH ROW
begin
	DECLARE stock_level INT;
    DECLARE ordered_qty INT;
    DECLARE total_ordered_qty INT;
    
    -- Get the stock level for the ordered product and brand
    SELECT i.stock_level INTO stock_level
    FROM inventory1 i
    WHERE i.Prod_Id = NEW.p_id AND i.Proprietry = NEW.ordered_from;

	-- Get the total ordered quantity for the product and brand, 
    -- including current order
    SELECT COALESCE(SUM(o.qty), 0) INTO total_ordered_qty
    FROM orders1 o
    WHERE o.p_id = NEW.p_id AND o.ordered_from = NEW.ordered_from;
    
	-- Calculate the ordered quantity including the current order
    SET ordered_qty = total_ordered_qty + NEW.qty;
    
    -- Check if ordered quantity exceeds stock level
    IF ordered_qty > stock_level THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Out of Stock. Come back soon';
    END IF;
end//
delimiter ;

select * from inventory1;   # Walmart 103 -  Stock level - 10;
select * from Pid_SumQty;   # Walmart 103 - prev order sum qty - 7

insert into orders1 values
('A37',25,103,'2022-10-27',5,'Walmart');









