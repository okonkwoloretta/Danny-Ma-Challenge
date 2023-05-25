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


-- Which item was purchased just before the customer became a member?
```sql
SELECT
  m.customer_id,
  s.product_id,
  menu.product_name,
  s.order_date
FROM members m
INNER JOIN sales s 
  ON m.customer_id = s.customer_id
INNER JOIN menu 
  ON s.product_id = menu.product_id
WHERE m.join_date <= s.order_date
AND s.order_date = (
                    SELECT MIN(order_date)
                    FROM sales
                    WHERE customer_id = m.customer_id
                    AND order_date >= m.join_date
                    )
```


|customer_id	|product_id	|product_name	|order_date|
|-----------|-----------|-----------|-----------|
|A	|2	|curry	|2021-01-07|
|B	|1	|sushi	|2021-01-11|


-- What is the total items and amount spent for each member before they became a member?
```sql
SELECT
  m.customer_id as member,
  COUNT(s.product_id) AS total_items,
  SUM(menu.price) AS total_amount
FROM members m
LEFT JOIN sales s 
  ON m.customer_id = s.customer_id
INNER JOIN  menu 
  ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id
```
|member	|total_items	|total_amount|
|-----------|-----------|-----------|
|A	|2	|25
|B	|3	|40



-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
SELECT
  m.customer_id as customer,
  SUM(CASE
        WHEN menu.product_name = 'sushi' THEN 2 * menu.price
        ELSE menu.price
      END) * 10 AS total_points
FROM members m
INNER JOIN sales s 
  ON m.customer_id = s.customer_id
INNER JOIN menu 
  ON s.product_id = menu.product_id
GROUP BY m.customer_id
```
|customer	|total_points|
|-----------|-----------|
|A	|860
|B	|940


-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
WITH jan_member_points AS (
	SELECT m.customer_id AS customer,
		SUM( CASE
			 WHEN s.order_date < m.join_date THEN 
			 CASE
			 WHEN m2.product_name = 'sushi' THEN (m2.price * 20)
			 ELSE (m2.price * 10)
			 END
			 WHEN s.order_date > DATEADD(DAY, 6, m.join_date) THEN 
			 CASE
			 WHEN m2.product_name = 'sushi' THEN (m2.price * 20)
			 ELSE (m2.price * 10)
			 END
			 ELSE (m2.price * 20)
			 END
		   ) AS member_points
	FROM members AS m
	JOIN sales AS s 
	  ON s.customer_id = m.customer_id
	JOIN menu AS m2 
	  ON s.product_id = m2.product_id
	WHERE s.order_date <= '2021-01-31'
	GROUP BY m.customer_id
)
SELECT *
FROM jan_member_points
WHERE customer IN ('A', 'B')
ORDER BY customer
```
|customer	|member_points|
|-----------|-----------|
A	|1370
B	|820

# Bonus Questions
## Join All The Things

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

|customer_id	|order_date	|product_name	|price	|member
|-----------|-----------|-----------|-----------|-----------|
A	|2021-01-01	|curry	|15	|N
A	|2021-01-01	|sushi	|10	|N
A	|2021-01-07	|curry	|15	|Y
A	|2021-01-10	|ramen	|12	|Y
A	|2021-01-11	|ramen	|12	|Y
A	|2021-01-11	|ramen	|12	|Y
B	|2021-01-01	|curry	|15	|N
B	|2021-01-02	|curry	|15	|N
B	|2021-01-04	|sushi	|10	|N
B	|2021-01-11	|sushi	|10	|Y
B	|2021-01-16	|ramen	|12	|Y
B	|2021-02-01	|ramen	|12	|Y
C	|2021-01-01	|ramen	|12	|N
C	|2021-01-01	|ramen	|12	|N
C	|2021-01-07	|ramen	|12	|N



