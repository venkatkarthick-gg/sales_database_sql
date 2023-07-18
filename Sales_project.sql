create database sales_practice;
use sales_practice;
select * from `s1-sales_database`;
#There are totally 5 tables customers,delivery,orders,pincode,product.
# Lets retreive the data that client requires 

# Q1. How many customers do not have DOB information available?
select * from customers;
alter table customers rename column `ï»¿cust_id` to customer_id;
select * from customers
where dob='';

# Q2-- How many customers are there in each pincode and gender combination?

select customer_id,gender,primary_pincode,count(customer_id)over(partition by primary_pincode,gender)customer_count
from customers
order by customer_count desc;

# Q3--  Print product name and mrp for products which have more than 50000 MRP? 
select * from product;
select `product_name`,mrp
from product
where mrp>50000
order by mrp desc;

# Q4. How many delivery personal are there in each pincode?

select * from delivery;

select *,count(ï»¿delivery_person_id)over(partition by pincode)total_count
from delivery
order by total_count desc;

/* Q5. For each Pin code, print the count of orders, sum of total amount paid, average amount paid, maximum amount paid,
 minimum amount paid for the transactions which were paid by 'cash'. 
Take only 'buy' order types
*/

select * from orders;
select * from delivery;

select delivery_pincode pd, count(ï»¿order_id)count_order,sum(total_amount_paid)total_amount,avg(total_amount_paid)average_amount,
min(total_amount_paid)min_amount,max(total_amount_paid)max_amount from orders
where order_type='buy' and payment_type='cash'
group by pd
order by total_amount desc;

/*
Q6. For each delivery_person_id, print the count of orders and 
total amount paid for product_id = 12350 or 12348 and total units > 8. 
Sort the output by total amount paid in descending order. Take only 'buy' order types
*/

select * from delivery;
select * from orders;

select ï»¿order_id,tot_units,count(ï»¿order_id)over (partition by delivery_person_id)order_count, total_amount_paid
from orders
where product_id in (12350,12348) and tot_units>8 and order_type='buy'
order by total_amount_paid desc;

# Q7. Print the Full names (first name plus last name) for customers that have email on "gmail.com"?

select * from customers;

select concat(first_name,' ',last_name)full_name
from customers
where email like ('%gmail.com');

# Q8. How many orders had #units between 1-3, 4-6 and 7+? Take only 'buy' order types

select * from orders;

select  
case 
     when tot_units <= 3 then 'till 3'
     when tot_units >4 and tot_units <=6 then 'till 6'
     else 'more than 6'
end as unit_cat,count(ï»¿order_id)cnt_order
from orders
where order_type='buy'
group by unit_cat
order by cnt_order desc;



# Q9. Which pincode has average amount paid more than 150,000? Take only 'buy' order types

select * from orders;

select avg(total_amount_paid)average_amount,delivery_pincode
from orders
where order_type ='buy'
group by delivery_pincode 
having average_amount > 150000
order by average_amount desc;
     

/* Q10. Create following columns from order_dim data -

order_date
Order day
Order month
Order year */

select * from orders;

select order_date, 
substr(order_date,1,2) AS DAY,
substr(order_date,4,2)as month,
substr(order_date,7) as year
from orders
where order_type="buy";


/* Q11. How many total orders were there in each month and how many of them were returned? Add a column for return rate too.
return rate = (100.0 * total return orders) / total buy orders
Hint: You will need to combine SUM() with CASE WHEN
*/

select * from orders;
with t as
(select substr(order_date,4,2)as order_month, sum(if(order_type='return',1,0))total_returns,sum(if(order_type='buy',1,0))total_buy
from orders
group by order_month)
select *,round((total_returns/total_buy)*100,1)return_rate
from t;


 # QUESTION ON SQL JOINS
 
 # Q12. How many units have been sold by each brand? Also get total returned units for each brand.
 
 select * from orders;
 select * from product;
select distinct sum(if(order_type ='buy',(tot_units),0))total_sold,sum(if(order_type ='return',(tot_units),0))total_returned,p.brand
from orders o
join product p
on o.product_id =p.ï»¿
group by p.brand;

 # Q13. How many distinct customers and delivery boys are there in each state?
 select * from customers;
 select * from pincode;
 select * from delivery;

select count(distinct c.customer_id)cust_count,count(distinct d.ï»¿delivery_person_id)del_id,p.state
from customers c
join delivery d
on c.primary_pincode = d.pincode
join pincode p
on d.pincode= p.ï»¿pincode
group by p.state;

/* Q14. For every customer, print how many total units were ordered, how many units were 
ordered from their primary_pincode and how many were ordered not from the primary_pincode. 
Also calulate the percentage of total units which were ordered from 
primary_pincode(remember to multiply the numerator by 100.0). Sort by the percentage column in descending order.
*/ 
 select * from customers;
 select * from pincode;
 select * from delivery;
select * from orders;
with table1 as
(select distinct c.customer_id,sum(o.tot_units)over(partition by c.customer_id)total_units,
sum(if(c.primary_pincode=o.delivery_pincode,(tot_units),0))over(partition by c.customer_id) primary_code_units,
sum(if(c.primary_pincode<>o.delivery_pincode,(tot_units),0))over(partition by c.customer_id)non_primary_code_units
from  customers c
join orders o
on o.cust_id=c.customer_id
where order_type="buy")
select * ,(primary_code_units/total_units)*100 as percentage_of_primary_code_units
from table1
order by percentage_of_primary_code_units desc;

 /* Task 15 
 For each product name, print the sum of number of units, total amount paid, 
 total displayed selling price, total mrp of these units, and finally the net discount from selling price 
 (i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) 
 AND the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp)
*/
select * from orders;
select * from product;
with t1 as
(select distinct p.product_name,sum(o.tot_units)over(partition by p.product_name)
product_units,sum(o.total_amount_paid)over(partition by p.product_name)total_amt_product,
sum(o.displayed_selling_price_per_unit)over(partition by p.product_name)total_display_price,
sum(p.mrp)over(partition by p.product_name)mrp_product
from product p left
join orders o
on o.product_id = p.ï»¿)
select *,(100-((total_amt_product/total_display_price)*100))dis_selling_price,
(100-((total_amt_product/mrp_product)*100))dis_mrp
from t1;




 
 