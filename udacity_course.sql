--Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and total_amt_usd.

select id, occurred_at, total_amt_usd
from orders
order by occurred_at
limit 10;

--Write a query to return the top 5 orders in terms of largest total_amt_usd. Include the id, account_id, and total_amt_usd.
select  id, account_id, total_amt_usd
from orders
order by total_amt_usd desc
limit 5;

--Write a query that displays the order ID, account ID, and total dollar amount for all the orders, sorted first by the account ID (in ascending order), and then by the total dollar amount (in descending order).
select id, account_id, total_amt_usd
from orders
order by account_id, total_amt_usd desc;


--FROM BIGQUERY

-- **Warm Up 1**

--1: Earliest year of purchase

    select min(Year) as earliest_year from prework.sales;

 --2. What is the average customer age per year? Order the years in ascending order.

select * from prework.sales;

 select Year, avg(Customer_Age) as average_age
 from prework.sales
 group by 1
 order by 1;

--Return all clothing purchases from September 2015 where the cost was at least $70.

select *
from prework.sales
where product_Category = 'Clothing'
  and cost >= 70
  and month ='September'
  and year > 2015;

--4. What are all the different types of product categories that were sold from 2014 to 2016 in France?

select distinct product_category
from prework.sales
where year between 2014 and 2016
and country='France';

--5. Within each product category and age group (combined), what is the average order quantity and total profit?

select product_category, age_group,avg(order_quantity) as Avgorderqty, sum(profit) as totalprofit
from prework.sales
group by product_category, age_group;

--**Warm Up 2**

--1. Which product category has the highest number of orders among 31-year olds? Return only the top product category.

select product_category, sum(Order_Quantity)
from prework.sales
where Customer_Age = 31
group by 1
order by 2 desc
limit 1;

--2. Of female customers in the U.S. who purchased bike-related products in 2015, what was the average revenue?

select distinct Product_Category
from prework.sales;

select avg(revenue)
from prework.sales
where customer_gender = 'F'
and product_category like '%Bike%'
and year = 2015
and country='United States'

--3. Categorize all purchases into bike vs. non-bike related purchases. How many purchases were there in each group among male customers in 2016?

select (case when Product_Category like '%Bike%'then 'Biker' else 'Non-Biker' end) as category, count(*) as count
from prework.sales
where Customer_Gender='M'
and year = 2016
group by 1;

--4. Among people who purchased socks or caps (use `sub_category`), what was the average profit earned per country per year, ordered by highest average profit to lowest average profit?

select country, year, avg(profit) as profitavg
from prework.sales
where sub_category in('Socks','Caps')
group by 1,2
order by 3 desc;

--5. For male customers who purchased the AWC Logo Cap (use `product`), use a window function to order the purchase dates from oldest to most recent within each gender.
select Customer_Gender, Date,
row_number() over (partition by Customer_Gender order by Date desc) as purchase_orders
from prework.sales
where customer_gender ='M' and product ='AWC Logo Cap';




--Operator	Condition	SQL Example
=, !=, <, <=, >, >=	Standard numerical operators	col_name != 4
BETWEEN … AND …	Number is within range of two values (inclusive)	col_name BETWEEN 1.5 AND 10.5
NOT BETWEEN … AND …	Number is not within range of two values (inclusive)	col_name NOT BETWEEN 1 AND 10
IN (…)	Number exists in a list	col_name IN (2, 4, 6)
NOT IN (…)	Number does not exist in a list	col_name NOT IN (1, 3, 5)


--Operator	Condition	Example
=	Case sensitive exact string comparison (notice the single equals)	col_name = "abc"
!= or <>	Case sensitive exact string inequality comparison	col_name != "abcd"
LIKE	Case insensitive exact string comparison	col_name LIKE "ABC"
NOT LIKE	Case insensitive exact string inequality comparison	col_name NOT LIKE "ABCD"
%	Used anywhere in a string to match a sequence of zero or more characters (only with LIKE or NOT LIKE)	col_name LIKE "%AT%"
(matches "AT", "ATTIC", "CAT" or even "BATS")
_	Used anywhere in a string to match a single character (only with LIKE or NOT LIKE)	col_name LIKE "AN_"
(matches "AND", but not "AN")
IN (…)	String exists in a list	col_name IN ("A", "B", "C")
NOT IN (…)	String does not exist in a list	col_name NOT IN ("D", "E", "F")

Query order of execution
1. FROM and JOINs
The FROM clause, and subsequent JOINs are first executed to determine the total working set of data that is being queried. This includes subqueries in this clause, and can cause temporary tables to be created under the hood containing all the columns and rows of the tables being joined.

2. WHERE
Once we have the total working set of data, the first-pass WHERE constraints are applied to the individual rows, and rows that do not satisfy the constraint are discarded. Each of the constraints can only access columns directly from the tables requested in the FROM clause. Aliases in the SELECT part of the query are not accessible in most databases since they may include expressions dependent on parts of the query that have not yet executed.

3. GROUP BY
The remaining rows after the WHERE constraints are applied are then grouped based on common values in the column specified in the GROUP BY clause. As a result of the grouping, there will only be as many rows as there are unique values in that column. Implicitly, this means that you should only need to use this when you have aggregate functions in your query.

4. HAVING
If the query has a GROUP BY clause, then the constraints in the HAVING clause are then applied to the grouped rows, discard the grouped rows that don't satisfy the constraint. Like the WHERE clause, aliases are also not accessible from this step in most databases.

5. SELECT
Any expressions in the SELECT part of the query are finally computed.

6. DISTINCT
Of the remaining rows, rows with duplicate values in the column marked as DISTINCT will be discarded.

7. ORDER BY
If an order is specified by the ORDER BY clause, the rows are then sorted by the specified data in either ascending or descending order. Since all the expressions in the SELECT part of the query have been computed, you can reference aliases in this clause.

8. LIMIT / OFFSET
Finally, the rows that fall outside the range specified by the LIMIT and OFFSET are discarded, leaving the final set of rows to be returned from the query.
