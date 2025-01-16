CREATE DATABASE walmart_db;
SHOW  databases;
USE walmart_db;
SHOW tables;

SELECT *
FROM walmart;

SELECT DISTINCT payment_method
FROM walmart;

-- Count each payment/_method has how many paymemts made in that way
SELECT 
	payment_method,
    count(*)
FROM walmart
GROUP BY payment_method;

-- COUNT OF BRANCHES 
SELECT count(distinct Branch) 
FROM walmart;

-- COUNT of categories
SELECT DISTINCT category		
FROM walmart;

SELECT min(quantity) FROM walmart;

-- Business Problems 
-- q1. Find different payment methods and number of transactions, number of quantites sold. 

SELECT 
	payment_method,
    count(*) AS no_of_payments,
    sum(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- q2. Identify the highest rated category in each branch, displaying branch and category
-- AVG rating

SELECT 
	Branch,
    category,
    avg(rating),
    RANK()over(partition by Branch order by avg(rating) DESC) as rank_of_branch
FROM walmart
GROUP BY Branch,category;

-- q3. Identify the busiest day for each branch based on no. of transactions 

SELECT * 
FROM 
    (SELECT 
        Branch,
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') as day_name,
        COUNT(*) as no_transactions,
        RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_1
    FROM walmart
    GROUP BY Branch, day_name
) as busy_day
WHERE rank_1 = 1;

-- q4 Calculate the total quantity of items sold per payments method. List payment_method and total_quantity

 SELECT 
	payment_method,
    sum(quantity) AS total_qty
 FROM walmart
 GROUP BY payment_method;
 
 -- q5 determine the average,minimum, maximum rating of products for each city 
 
 SELECT 
	city,
    category,
    max(rating) AS max_rating,
    min(rating) AS min_rating,
    avg(rating) AS avg_rating
FROM walmart
GROUP BY city,category;

-- q6 list the total profit of each category. (total profit = unit price*qty*profit margin). Orderby desc

SELECT category, sum(total*profit_margin )AS total_profit, sum(total) AS total_revenue
FROM walmart
group by category
ORDER BY total_profit desc;
 
-- q7 Determine the most common payment for each branch
-- display branch and prefered_payment_mthd

WITH cte
AS
(SELECT 
	branch,
    payment_method,
    count(*) AS total_trans,
    RANK() OVER(partition by Branch order by count(*) DESC) AS rank_1
FROM walmart
GROUP BY branch,payment_method
)
SELECT *
FROM cte
WHERE rank_1 = 1;

-- q8 Categorise sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out each of the shift and number of invoices

SELECT 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    count(*) AS transactions
FROM walmart
GROUP BY day_time;


SELECT 
	Branch,
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    count(*) AS transactions
FROM walmart
GROUP BY Branch, day_time
ORDER BY Branch, transactions desc;


-- q9 Identify 5 branch with highest decrease ratio in revenue compare to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 r2022
JOIN revenue_2023 r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
