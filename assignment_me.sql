-- creating database
create database project;

-- use database "project"
use project;

-- creating tables
CREATE TABLE IF NOT EXISTS `sales_team` (
  `salesteam_id` INT NOT NULL,
  `salesteam` VARCHAR(45) NULL,
  `salesteam_region` VARCHAR(45) NULL,
  PRIMARY KEY (`salesteam_id`));
  
CREATE TABLE IF NOT EXISTS `products` (
  `product_id` INT NOT NULL,
  `product_name` VARCHAR(45) NULL,
  `product_category` VARCHAR(45) NULL,
  PRIMARY KEY (`product_id`));
  
CREATE TABLE IF NOT EXISTS `stores` (
  `store_id` INT NOT NULL,
  `store_name` VARCHAR(255) NULL,
  `state_code` CHAR(2) NULL,
  `state` VARCHAR(255) NULL,
  PRIMARY KEY (`store_id`));
    
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` VARCHAR(15) NOT NULL,
  `sales_date` VARCHAR(15) NULL,
  `sales_channel` VARCHAR(15) NULL,
  `currency` CHAR(3) NULL,
  `salesteam_id` INT NOT NULL,
  `store_id` INT NULL,
  `product_id` INT NULL,
  `order_qty` INT NULL,
  `unit_price` DECIMAL(8,2) NULL,
  `unit_cost` DECIMAL(8,2) NULL,
  PRIMARY KEY (`order_id`));
  
-- update orders table to convert the date column from string to date
UPDATE orders
SET sales_date = STR_TO_DATE(sales_date, '%m/%d/%Y');

-- create a joint table for the four tables
create table sales_table as 
select orders.order_id, orders.sales_date, orders.sales_channel, sales_team.salesteam, sales_team.salesteam_region,
products.product_name, products.product_category, stores.store_name, stores.state, orders.order_qty,
orders.unit_cost, orders.unit_price
from orders
left join sales_team on orders.salesteam_id = sales_team.salesteam_id
left join products on orders.product_id = products.product_id
left join stores on orders.store_id = stores.store_id;

-- add calculated columns
alter table sales_table
add column sales_price decimal(8,2) as (unit_price * order_qty),
add column cost_price decimal(8,2) as (unit_cost * order_qty),
add column profit decimal(8,2) as (sales_price - cost_price);

-- view the sales table
select * from sales_table;
truncate table stores;

-- alter original orders table to add foreign keys
alter table orders
add constraint Fk_orders_products foreign key (product_id) references products (product_id),
add constraint Fk_orders_salesteam foreign key (salesteam_id) references sales_team (salesteam_id),
add constraint Fk_orders_stores foreign key (store_id) references stores (store_id);

-- question 1
select sum(sales_price) as "Total Sales Revenue"
from sales_table;

-- question 2
select order_id, product_name, order_qty
from sales_table
where sales_channel in ("distributor", "in-store");

-- question 3
select *
from sales_table
where salesteam = "Nicholas Cunningham";

-- question 4
select *
from sales_table
where order_qty > (select avg(order_qty) from sales_table);

-- question 5
select product_name, sum(order_qty) as order_qtys
from sales_table
group by product_name
order by order_qtys desc
limit 10;

-- question 6
select count(*) as "No of Orders from stores in Alabama"
from sales_table
where state = "Alabama";

-- question 7
select *
from sales_table
where order_id = "SO471";

-- question 8
select salesteam_region, round(avg(profit), 2) as avg_profit
from sales_table
group by salesteam_region
order by avg_profit desc;

-- question 9
select *
from sales_table
where sales_price > (
	select avg(sales_price)
	from sales_table
);

-- question 10
select product_category, count(order_id) as no_orders
from sales_table
group by product_category
having no_orders >= 2000
order by no_orders desc;

-- question 11a
select product_name, round(avg(unit_price), 2) as avg_price, sum(order_qty) as total_qty_ordered
from sales_table
group by product_name
order by avg_price desc
limit 5;

-- question 11b
select product_name, round(avg(unit_price), 2) as avg_price, sum(order_qty) as total_qty_ordered
from sales_table
group by product_name
order by avg_price 
limit 5;