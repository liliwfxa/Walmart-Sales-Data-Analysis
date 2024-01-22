-- Create database
CREATE DATABASE IF NOT EXISTS Walmart_sales_data;

-- Create table sales
create table if not exists sales(
	invoice_id varchar(30) NOT NULL PRIMARY KEY,
    branch varchar(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9) NOT NULL,
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2, 1) NOT NULL
    );

-- -----------------------------------------------------------------
-- ---------------------- Feature Engeering-------------------------

-- time_of_day
Alter table sales add column time_of_day Varchar(20);
    
update sales
set time_of_day = case
					when time between '00:00:00' and '5:00:00' then 'Night'
					when time between '5:00:01' and '12:00:00' then 'Morning'
					when time between '12:00:01' and '17:00:00' then 'Afternoon'
					else 'Evening'
					end; 
                    
-- day_name
select date, dayname(date)
from sales;

Alter table sales add column day_name Varchar(10);

update sales
set day_name = Dayname(date);

-- month_name
select date, monthname(date)
from sales;

Alter table sales add column month_name Varchar(10);

update sales
set month_name = monthname(date);       
    
-- ----------------------------------------------------------------    
-- ---------------------------------------------------------------- 
-- ----------------------------Generic ----------------------------
-- How many unique cities does the data have?
select count(distinct city) from sales;

-- In which city is each branch?
select distinct city, branch
from sales;

-- ------------------------------------------------------------------
-- ---------------------------Product--------------------------------

-- How many unique product lines does the data have?
select count(distinct product_line) from sales;

-- What is the most selling product line?
select product_line, sum(quantity)
from sales
group by product_line
order by sum(quantity) desc
limit 1;

-- What is the most common payment method?
select payment_method, count(*)
from sales
group by payment_method
order by count(*) desc
limit 1;

-- What is the total revenue by month?
select month_name, sum(total) as total_revenue_permonth
from sales
group by month_name;

-- What month had the largest COGS?
select month_name, sum(cogs) 
from sales
group by month_name
order by sum(cogs)
limit 1;

-- What product line had the largest revenue?
select product_line, sum(total) as Revenue
from sales
group by product_line
order by sum(total)
limit 1;

-- What is the city with the largest revenue?
select branch, city, sum(total) as Revenue
from sales
group by city, branch
order by sum(total)
limit 1;

-- What product line had the largest VAT?
select product_line, sum(VAT) 
from sales
group by product_line
order by sum(VAT)
limit 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good 
-- if its greater than average sales
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

select product_line, case when AVG(quantity) > (SELECT AVG(quantity) AS avg_qnty FROM sales as baseline)
						then 'Good'
                        else 'bad'
                        end
from sales
group by product_line;
                        
-- Which branch sold more products than average product sold?
select branch,sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (SELECT AVG(quantity) AS avg_qnty FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

SELECT *
FROM (
  SELECT
    gender,
    product_line,
    COUNT(*) AS total_cnt,
    ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) as rn
  FROM sales
  GROUP BY gender, product_line
) ranked
WHERE rn = 1;

-- What is the average rating of each product line?
select product_line, avg(rating)
from sales
group by product_line;

-- Number of sales made in each time of the day per weekday
select day_name, sum(quantity)
from sales
group by day_name;

-- --------------------------------------------------------------
-- --------------------------Customer ---------------------------
-- Which of the customer types brings the most revenue?
select customer_type, sum(total) as revenue
from sales
group by customer_type
order by revenue desc
limit 1;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(VAT*100/(total+VAT)) as tax_per
from sales
group by city
order by tax_per desc
limit 1;

-- Which customer type pays the most in VAT?
select customer_type, sum(VAT)
from sales
group by customer_type
order by customer_type desc
limit 1;

-- How many unique customer types does the data have?
select count(distinct customer_type)
from sales;

-- How many unique payment methods does the data have?
select count(distinct payment_method)
from sales;

-- What is the most common customer type?
select customer_type, count(*)
from sales
group by customer_type;

-- What is the gender of most of the customers?
select gender, count(*)
from sales
group by gender
order by count(*) desc
limit 1;

-- What is the gender distribution per branch?
select branch, gender, count(*)
from sales
group by branch, gender;

-- Which time of the day do customers give most ratings?
select time_of_day, count(rating)
from sales
group by time_of_day
order by count(rating) desc
limit 1;

-- Which day fo the week has the best avg ratings?
select time_of_day, avg(rating)
from sales
group by time_of_day
order by avg(rating) desc
limit 1;

-- Which day of the week has the best average ratings per branch?
select * 
from (select branch, day_name, avg(rating) as avgrating, ROW_NUMBER() OVER (PARTITION BY branch ORDER BY avg(rating) DESC) as rn
	  from sales
	  group by branch, day_name ) AS ranked_branch_days	
where rn = 1;
     
       






