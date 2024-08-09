create database pizzahut;

create table order_details;
-- import csv file of order_details in this table  
create table orders;
-- import csv file of orders in this table
create table pizza_types;
-- import csv file of pizza_types in this table
create table pizzas;
-- import csv file of pizzas in this table

use pizzahut;

-- Q1: The total number of order place
SELECT 
    COUNT(order_id) AS total_order
FROM
    orders;
    
-- Q2: The total revenue generated from pizza sales
SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id;
    
-- Q3: The highest priced pizza.
SELECT 
    name, MAX(price) AS highest_price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY highest_price DESC
LIMIT 1;

-- Q4: The most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- Q5: The top 5 most ordered pizza types along their quantities.
SELECT 
    pt.name, sum(quantity) AS quantities
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY name
ORDER BY quantities DESC
LIMIT 5;

-- Q6: The quantity of each pizza categories ordered.
SELECT 
    pt.category, sum(quantity) AS quantities
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY category
ORDER BY quantities DESC;

-- Q7: The distribution of orders by hours of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours;

-- Q8: The category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Q9: The average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_quantity), 0)
FROM
    (SELECT 
        order_date, SUM(quantity) AS total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS qauntity;
    

-- Q10: Top 3 most ordered pizza type base on revenue.
SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;   

-- Q11: The percentage contribution of each pizza type to revenue.
SELECT 
    pt.category,
	round(SUM(order_details.quantity * p.price) / (SELECT 
    ROUND(SUM(order_details.quantity * p.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas p  ON order_details.pizza_id = p.pizza_id)* 100,2)  as revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id =pt.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC; 

-- Q12: The cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * p.price) as revenue
from order_details join pizzas p
on order_details.pizza_id = p.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category.
select name,revenue
from
(select category,name,revenue,
rank() over(partition by category order by revenue desc)as rn
from 
(select pt.category,pt.name,
sum(order_details.quantity * p.price) as revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details
on order_details.pizza_id = p.pizza_id
group by pt.category,pt.name) as a) as b
where rn<=3;  

 





