-- 1. What is the total amount each customer spent at the restaurant?
SELECT
  	customer_id,
    sum(price) as total_spent
FROM dannys_diner.menu m

-- 2. How many days has each customer visited the restaurant?
SELECT
  	customer_id,
    count(distinct order_date) as total_visit_days
FROM  dannys_diner.sales s

-- 3. What was the first item from the menu purchased by each customer?
with base as
(SELECT
  	customer_id,
    order_date,
    product_id,
    rank() over (partition by customer_id order by order_date) as r
FROM  dannys_diner.sales s
 )
 Select distinct customer_id,
 product_name
 from base b
 join dannys_diner.menu m
 on b.product_id = m.product_id
 where b.r = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 Select 
product_name,
count(s.product_id)
from dannys_diner.menu m
join dannys_diner.sales s
on s.product_id = m.product_id
group by 1
order by 2 desc
limit 1

-- 5. Which item was the most popular for each customer?
with base as
(Select 
customer_id,
product_name,
count(product_name),
rank() over (partition by customer_id order by count(product_name) desc)
from dannys_diner.sales s
join dannys_diner.menu m
on s.product_id = m.product_id
group by 1,2
)
Select customer_id
, product_name from base
where rank = 1

-- 6. Which item was purchased first by the customer after they became a member?
with base as
(Select 
s.customer_id,
join_date,
order_date,
product_name,
 rank() over (partition by s.customer_id order by order_date)
from dannys_diner.sales s
join dannys_diner.members m
on s.customer_id = m.customer_id
and s.order_date >= m.join_date
join dannys_diner.menu mn
 on s.product_id = mn.product_id
)
Select  
customer_id, to_char(order_date, 'yyyy-mm-dd') as order_date,
product_name
from base
where rank =1

-- 7. Which item was purchased just before the customer became a member?
with base as
(Select 
s.customer_id,
join_date,
order_date,
product_name,
 rank() over (partition by s.customer_id order by order_date desc)
from dannys_diner.sales s
join dannys_diner.members m
on s.customer_id = m.customer_id
and s.order_date < m.join_date
join dannys_diner.menu mn
 on s.product_id = mn.product_id
)
Select  
customer_id, to_char(order_date, 'yyyy-mm-dd') as order_date,
product_name
from base
where rank =1

-- 8. What is the total items and amount spent for each member before they became a member?
Select 
s.customer_id,
count(s.product_id),
sum(price)
from dannys_diner.sales s
join dannys_diner.members m
on s.customer_id = m.customer_id
and s.order_date < m.join_date
join dannys_diner.menu mn
 on s.product_id = mn.product_id
 group by 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 with base as(
Select 
s.customer_id,
s.product_id,
(case when product_name='sushi' then 2 else 1 end) as mul,
  price
from dannys_diner.sales s
join dannys_diner.menu mn
on s.product_id = mn.product_id
)
Select customer_id,
sum(mul*price*10)
from base
group by 1;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
with base as(
Select 
s.customer_id,
s.product_id,
(case when product_name='sushi' then 2
 	when order_date between join_date and (join_date+6) then 2 
 	else 1 end) as mul,
  price
from dannys_diner.sales s
join dannys_diner.menu mn
on s.product_id = mn.product_id
join dannys_diner.members m
on s.customer_id = m.customer_id
and order_date < '2021-01-31'
)
Select customer_id,
sum(mul*price*10)
from base
group by 1

-- Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
Select 
s.customer_id,
to_char(s.order_date,'yyyy-mm-dd'),
mn.product_name,
price,
(case when order_date < join_date then 'N' 
 	when join_date is null then 'N' else 'Y' end )as member
from dannys_diner.sales s
join dannys_diner.menu mn
on s.product_id = mn.product_id
left join dannys_diner.members m
on s.customer_id = m.customer_id
order by 1,2;

-- Rank All The Things - Danny also requires further information about the ranking of customer products,
--  but he purposely does not need the ranking for non-member purchases so he expects null ranking values
-- for the records when customers are not yet part of the loyalty program.
with base as(
Select 
s.customer_id,
to_char(s.order_date,'yyyy-mm-dd') as order_date,
mn.product_name,
price,
(case when order_date < join_date then 'N' 
 	when join_date is null then 'N' else 'Y' end )as member
from dannys_diner.sales s
join dannys_diner.menu mn
on s.product_id = mn.product_id
left join dannys_diner.members m
on s.customer_id = m.customer_id
)
Select *,
case when member = 'N' then null
else
(rank() over (partition by customer_id,member order by order_date)) end as ranking
from base;
