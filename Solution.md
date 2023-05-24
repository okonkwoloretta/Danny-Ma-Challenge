# Case Study Questions and Answers

-- What is the total amount each customer spent at the restaurant?
```sql
SELECT customer_id as customer, sum(price) as total_spnt
FROM [Danny Ma Challenge].[dbo].[sales] s
INNER JOIN [Danny Ma Challenge].[dbo].[menu] m
ON s.product_id = m.product_id
group by customer_id
```
|customer|	total_spnt|
|----|-----------|
A	|76
B	|74
C	|36

-- How many days has each customer visited the restaurant?
```sql
SELECT customer_id as customer, count(distinct order_date) as num_days
FROM sales 
GROUP BY customer_id
```
|customer	|num_days|
|----|-----------|
A	|4
B	|6
C	|2

-- What was the first item from the menu purchased by each customer?
```sql
WITH first_pur as (
select customer_id, min(order_date) as first_pur_date
from sales
group by customer_id)

SELECT DISTINCT f.customer_id as customer, f.first_pur_date, m.product_name as first_item
FROM first_pur f
INNER JOIN sales s
ON f.customer_id = s.customer_id
AND f.first_pur_date = s.order_date
INNER JOIN menu m
ON s.product_id = m.product_id
ORDER BY f.first_pur_date
```
|customer	|first_pur_date	|first_item|
|----|-----------|-----------|
A	|2021-01-01	|curry
A	|2021-01-01	|sushi
B	|2021-01-01	|curry
C	|2021-01-01	|ramen

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
SELECT TOP (1) product_name, count(*) as num_item_pur 
FROM sales s
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY num_item_pur DESC
```
|product_name	|num_item_pur|
|-----------|-----------|
ramen	|8

-- Which item was the most popular for each customer?
```sql
WITH purchase_counts AS (
  SELECT
    customer_id,
    m.product_name AS item,
    COUNT(*) AS purchase_count,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
  FROM
    sales s
  INNER JOIN
    menu m ON s.product_id = m.product_id
  GROUP BY
    customer_id, m.product_name
)
SELECT
  customer_id,
  item AS most_popular_item,
  purchase_count
FROM
  purchase_counts
WHERE
  rn = 1
  ```
  
|customer_id	|most_popular_item	|purchase_count|
|-----------|-----------|-----------|
|A	|ramen	|3
|B	|sushi	|2
|C	|ramen	|3


-- Which item was purchased first by the customer after they became a member?
```sql
WITH first_purchase AS (
  SELECT customer_id, MIN(order_date) AS first_purchase_date
  FROM sales
  GROUP BY customer_id
),

member_first_purchase AS (
  SELECT s.customer_id, MIN(s.order_date) AS member_first_purchase_date
  FROM sales s
  INNER JOIN members m 
  ON s.customer_id = m.customer_id
  GROUP BY s.customer_id
)

SELECT
  f.customer_id,
  m.product_name AS first_item_after_membership
FROM
  member_first_purchase mfp
INNER JOIN first_purchase f 
  ON mfp.customer_id = f.customer_id
INNER JOIN sales s 
  ON f.customer_id = s.customer_id 
  AND f.first_purchase_date < s.order_date
INNER JOIN menu m 
  ON s.product_id = m.product_id
WHERE s.order_date = (
                      SELECT MIN(order_date)
                      FROM sales
                      WHERE customer_id = f.customer_id
                      AND order_date > mfp.member_first_purchase_date
                      )
```

|customer_id	|first_item_after_membership|
|-----------|-----------|
|A	|curry
|B	|curry


8. Which item was purchased just before the customer became a member?
9. What is the total items and amount spent for each member before they became a member?
10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
11. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Bonu
