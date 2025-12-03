create database pizzahut;
use pizzahut;
select * from pizzas;
select * from pizza_types;
create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));
select * from orders;
create table order_details ( order_details_id int not null, order_ide int not null, pizza_id text not null, quantity  int not null, primary key (order_details_id));
select * from order_details;
-- q1 retrieve total no. of orders placed
select count(order_id) as total_orders  from orders;
-- q2 calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity*pizzas.price),2) as total_sales from order_details join pizzas on pizzas.pizza_id = order_details.pizza_id;
-- q3 identify highest price pizza.
 
select pizza_types.name, pizzas.price from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id order by pizzas.price desc limit 1;
-- q4  identify the most common pizza size ordered

 select pizzas.size,count(order_details.order_details_id) as order_count 
 from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id group by pizzas.size order by order_count  desc limit 1;
 -- q5 list the top 5 most ordered pizzas along with their qty
 SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS quantity_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity_ordered DESC
LIMIT 5;
-- q6 join the necessary tables to find total qty of each pizza ordered

SELECT 
    pizza_types.name, COUNT(order_details.quantity) AS qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY qty DESC;

SELECT 
    pizza_types.category, COUNT(order_details.quantity) AS qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY qty DESC;

-- q7 determine the distribution of orders by hour of the day

select hour(order_time) as hour, count(order_id) as numberoforders from orders group by hour(order_time);


-- q8 join relevant tables to find the category wise distribution of pizzas

select category, 
count(pizza_type_id) from pizza_types group by category order by count(pizza_type_id) desc;

-- q9 group the orders by date and calculate the average number of pizzas ordered per day

select round(avg(qty),0) from (select date(orders.order_date) as date, sum(order_details.quantity) as qty from orders join order_details 
on orders.order_id = order_details.order_ide group by date) as average ;

-- q10 determine the top 3 most ordered pizza type based on revenue

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- q11 calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) /
        (
            SELECT SUM(order_details.quantity * pizzas.price)
            FROM order_details
            JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
        ) * 100,
        2
    ) AS revenue_percentage
FROM pizza_types
JOIN pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;


-- q 12 analyse the cumulative revenue generated over time

SELECT
    sales.order_date,
    SUM(sales.revenue) OVER (ORDER BY sales.order_date) AS cumulative_revenue
FROM
(
    SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas 
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders 
        ON orders.order_id = order_details.order_ide
    GROUP BY orders.order_date
) AS sales
ORDER BY sales.order_date;

-- q13 determine the top 3 most ordered pizza types based on revenues for each pizza category

SELECT *
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (
            PARTITION BY pizza_types.category
            ORDER BY SUM(order_details.quantity * pizzas.price) DESC
        ) AS rn
    FROM pizza_types
    JOIN pizzas 
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details 
        ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) AS ranked_pizzas
WHERE rn <= 3
ORDER BY category, rn;







