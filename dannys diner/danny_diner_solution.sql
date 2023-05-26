-- Case Study Questions


-- What is the total amount each customer spent at the restaurant?
SELECT customer_id as customer, sum(price) as total_spnt
FROM [Danny Ma Challenge].[dbo].[sales] s
INNER JOIN [Danny Ma Challenge].[dbo].[menu] m
ON s.product_id = m.product_id
group by customer_id


-- How many days has each customer visited the restaurant?

SELECT customer_id as customer, count(distinct order_date) as num_days
FROM sales 
GROUP BY customer_id

What was the first item from the menu purchased by each customer?

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

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP (1) product_name, count(*) as num_item_pur 
FROM sales s
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY num_item_pur DESC

-- Which item was the most popular for each customer?

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


-- Which item was purchased first by the customer after they became a member?
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


-- What is the total items and amount spent for each member before they became a member?
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

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?
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

