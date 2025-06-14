USE sakila;

-- Step 1: Create a view
-- First, create a view that summarizes rental information for each customer.
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

SELECT * FROM rental;

DROP VIEW IF EXISTS summarized_info;

CREATE VIEW summarized_info AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

SELECT * FROM summarized_info;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 
-- to join with the payment table and calculate the total amount paid by each customer.

SELECT * FROM payment; -- payment_id, customer_id, rental_id, amount

DROP TEMPORARY TABLE IF EXISTS total_paid;
CREATE TEMPORARY TABLE total_paid AS
SELECT 
    s.customer_id,
    s.first_name,
    s.last_name,
    s.email,
    COUNT(r.rental_id) AS rental_count,
    SUM(p.amount) AS total_amount_spent
FROM summarized_info s
JOIN rental r ON r.customer_id = s.customer_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY s.customer_id, s.first_name, s.last_name, s.email
;

SELECT * FROM total_paid;

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
-- The CTE should include the customer's name, email address, rental count, and total amount paid.


WITH merged_sum_pay AS (
SELECT 
	s.first_name,
    s.last_name,
    s.email,
    s.rental_count,
    t.total_amount_spent
FROM summarized_info s
JOIN total_paid t ON t.customer_id = s.customer_id
)
SELECT * FROM merged_sum_pay;


-- CREATING THE REPORT 
WITH merged_sum_pay AS (
SELECT 
	s.first_name,
    s.last_name,
    s.email,
    s.rental_count,
    t.total_amount_spent
FROM summarized_info s
JOIN total_paid t ON t.customer_id = s.customer_id
)

SELECT 
    first_name,
    last_name,
    email,
    rental_count,
    total_amount_spent AS total_paid,
    ROUND(total_amount_spent / rental_count, 2) AS avg_payment_per_rental
FROM merged_sum_pay
ORDER BY avg_payment_per_rental DESC;

