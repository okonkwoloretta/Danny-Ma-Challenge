

-- Create a new table
CREATE TABLE ranked_insights (
  customer_id VARCHAR(1),
  order_date DATE,
  product_name VARCHAR(10),
  price INT,
  member CHAR(1),
  ranking INT
)

-- Insert the data into the table with null ranking values
INSERT INTO ranked_insights (customer_id, order_date, product_name, price, member, ranking)
VALUES
  ('A', '2021-01-01', 'curry', 15, 'N', NULL),
  ('A', '2021-01-01', 'sushi', 10, 'N', NULL),
  ('A', '2021-01-07', 'curry', 15, 'Y', 1),
  ('A', '2021-01-10', 'ramen', 12, 'Y', 2),
  ('A', '2021-01-11', 'ramen', 12, 'Y', 3),
  ('A', '2021-01-11', 'ramen', 12, 'Y', 3),
  ('B', '2021-01-01', 'curry', 15, 'N', NULL),
  ('B', '2021-01-02', 'curry', 15, 'N', NULL),
  ('B', '2021-01-04', 'sushi', 10, 'N', NULL),
  ('B', '2021-01-11', 'sushi', 10, 'Y', 1),
  ('B', '2021-01-16', 'ramen', 12, 'Y', 2),
  ('B', '2021-02-01', 'ramen', 12, 'Y', 3),
  ('C', '2021-01-01', 'ramen', 12, 'N', NULL),
  ('C', '2021-01-01', 'ramen', 12, 'N', NULL),
  ('C', '2021-01-07', 'ramen', 12, 'N', NULL);

-- Select the data from the table
SELECT 
  customer_id, 
  order_date, 
  product_name, 
  price, 
  member, 
  CASE WHEN member = 'Y' THEN RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date) END AS ranking
FROM 
  ranked_insights
