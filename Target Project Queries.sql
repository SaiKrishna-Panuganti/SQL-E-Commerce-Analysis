# Problem statements

# q1. data type of all columns in customers table
desc customers;


# q2. Get the time range between which the orders were placed.

SELECT
    MIN(order_purchase_timestamp) AS earliest_order_date,
    MAX(order_purchase_timestamp) AS latest_order_date
FROM
    orders;
    
# q3. Count the Cities & States of customers who ordered during the given period.

select count(distinct customer_city) as number_of_unique_cities,
	   count(distinct customer_state) as number_of_unique_states 
from customers;

# q4. Is there a growing trend in the number of orders placed over the past years?

select 
	year(order_purchase_timestamp) as order_year,
    count(order_id) as Total_orders
from orders
	group by order_year 
    order by order_year;

-- Insight : Yes, there is a very strong growing trend in the number of orders, indicating rapid business expansion year over year.

# q5. Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

SELECT
    MONTHNAME(order_purchase_timestamp) AS month_name,
    COUNT(order_id) AS number_of_orders
FROM
    orders
GROUP BY
    month_name
ORDER BY
    number_of_orders DESC;

-- Yes, there is clear monthly seasonality. Sales peak in the middle of the year (specifically August) and are lowest in the early autumn (September/October).

#q6. During what time of the day do customers mostly place their orders?

select 
	hour(order_purchase_timestamp) as Hour_of_the_day,
    count(order_id) as number_of_orders 
from orders
	group by Hour_of_the_day
    order by number_of_orders desc;
    
-- Customers predominantly shop during the afternoon (1 PM - 4 PM), with another smaller peak in the late morning (11 AM).

   # The problem statement also mentioned grouping these hours into bins like "Morning" or "Afternoon".
		SELECT
			CASE
				WHEN HOUR(order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
				WHEN HOUR(order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
				WHEN HOUR(order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Evening'
				ELSE 'Dawn'
			END AS time_of_day_bin,
			COUNT(order_id) AS number_of_orders
		FROM
			orders
		GROUP BY
			time_of_day_bin
		ORDER BY
			number_of_orders DESC;

#q7.  Get the month on month no. of orders placed in each state.

select 
	c.customer_state,
    date_format(o.order_purchase_timestamp,'%Y-%m') as order_month,
    count(order_id) as number_of_orders
from orders o 
inner join customers c on o.customer_id=c.customer_id 
group by customer_state,
		order_month
order by customer_state,
		order_month;
        
-- successfully produced the month-on-month report of orders placed in each state.

#q8. How are the customers distributed across all the states?

select 
	customer_state,
	count(distinct customer_unique_id) as number_of_customers
from customers
group by customer_state 
order by number_of_customers desc;

-- The customer distribution is highly concentrated in Brazil's southeastern states, with São Paulo (SP) being the overwhelmingly dominant market and RJ (Rio de Janeiro), MG (Minas Gerais) are the next.

#q9. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only)

with 
	sales_2017 as (
	select 
		sum(p.payment_value) as total_sales_2017
	from orders o 
	inner join payments p on o.order_id = p.order_id 
	where 
		year(order_purchase_timestamp) = 2017 and 
		month(order_purchase_timestamp) between 1 and 8
        ),
	sales_2018 as (
    select 
		sum(p.payment_value) as total_sales_2018
	from orders o 
	inner join payments p on o.order_id = p.order_id 
	where 
		year(order_purchase_timestamp) = 2018 and 
		month(order_purchase_timestamp) between 1 and 8
        )
select 
	   s2017.total_sales_2017,
       s2018.total_sales_2018, 
       (
        (s2018.total_sales_2018-s2017.total_sales_2017)/s2017.total_sales_2017
       ) * 100 as percentage_increase
from sales_2017 as s2017, 
sales_2018 as s2018;

-- The company's cost of orders grew by an enormous 136.97% when comparing the first eight months of 2018 to the same period in 2017. This financially confirms the powerful growth trend we saw earlier

#q10. Calculate the Total & Average value of order price for each state.

SELECT
    c.customer_state,
    SUM(oi.price) AS total_sales_value,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
INNER JOIN
    order_items AS oi ON o.order_id = oi.order_id 
group by c.customer_state
order by total_sales_value desc;

#q11. Calculate the Total & Average value of order freight for each state

SELECT
    c.customer_state,
    SUM(oi.freight_value) AS total_charge_value,
    ROUND(AVG(oi.freight_value), 2) AS Average_charge_value
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
INNER JOIN
    order_items AS oi ON o.order_id = oi.order_id 
group by c.customer_state
order by total_charge_value desc;

#q12. Find the number of days taken to deliver each order & calculate the difference between the estimated and actual delivery date.

select 
	order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    datediff(order_delivered_customer_date,order_purchase_timestamp) as actual_delivery_time_days,
    datediff(order_estimated_delivery_date,order_purchase_timestamp) as diff_estimated_vs_actual_days
from orders
LIMIT 100;

#q13. Find out the top 5 states with the highest & lowest average freight value.

-- Top 5 states with the HIGHEST average freight value

SELECT
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS average_freight_value
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
INNER JOIN
    order_items AS oi ON o.order_id = oi.order_id
GROUP BY
    c.customer_state
ORDER BY
    average_freight_value DESC 
LIMIT 5; 
-------------------------------------------------------------------------------
-- Top 5 states with the LOWEST average freight value
SELECT
    c.customer_state,
    ROUND(AVG(oi.freight_value), 2) AS average_freight_value
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
INNER JOIN
    order_items AS oi ON o.order_id = oi.order_id
GROUP BY
    c.customer_state
ORDER BY
    average_freight_value ASC
LIMIT 5; 

#q14. Find out the top 5 states with the highest & lowest average delivery time.

-- Top 5 states with the fastest average delivery time
SELECT
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS average_delivery_days
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    c.customer_state
ORDER BY
    average_delivery_days ASC -- Sort from lowest (fastest) to highest
LIMIT 5;


-- Top 5 states with the slowest average delivery time

SELECT
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS average_delivery_days
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    c.customer_state
ORDER BY
    average_delivery_days DESC 
LIMIT 5;

#q15. Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.

-- Top 5 states where deliveries are fastest compared to the estimate
SELECT
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date)), 1) AS avg_days_early
FROM
    customers AS c
INNER JOIN
    orders AS o ON c.customer_id = o.customer_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    c.customer_state
ORDER BY
    avg_days_early DESC -- Sort by the highest number of days early
LIMIT 5;

#q16. Find the month on month no. of orders placed using different payment types.

SELECT
    p.payment_type,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS number_of_orders
FROM
    orders AS o
INNER JOIN
    payments AS p ON o.order_id = p.order_id
GROUP BY
    p.payment_type,
    order_month
ORDER BY
    p.payment_type,
    order_month;
    
#q17. Find the no. of orders placed on the basis of the payment installments that have been paid.

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM
    payments
GROUP BY
    payment_installments
ORDER BY
    payment_installments ASC;