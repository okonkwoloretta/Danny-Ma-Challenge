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

4. What was the first item from the menu purchased by each customer?
5. What is the most purchased item on the menu and how many times was it purchased by all customers?
6. Which item was the most popular for each customer?
7. Which item was purchased first by the customer after they became a member?
8. Which item was purchased just before the customer became a member?
9. What is the total items and amount spent for each member before they became a member?
10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
11. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Bonu
