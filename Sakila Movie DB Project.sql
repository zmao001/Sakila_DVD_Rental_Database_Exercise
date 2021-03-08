/*QUERY 1 - query used for first insight*/

With table1 AS (SELECT *
      			FROM category c
      			JOIN film_category fc
      			ON fc.category_id = c.category_id
      			JOIN film f
      			ON f.film_id = fc.film_id
      			JOIN Inventory i
      			ON i.film_id = f.film_id
      			JOIN rental r
      			ON i.inventory_id = r.inventory_id
      			WHERE name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 4)

SELECT table1.title film_title, table1.name category_name, COUNT(*) AS rental_count
FROM table1
GROUP BY 1,2
ORDER BY 2,1,3 DESC;




/*QUERY 2 - query used for second insight*/

SELECT table1.name, table1.standard_quartile, COUNT (table1.name) AS count
FROM (SELECT f.title, c.name, f.rental_duration, 
              NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
      FROM film f
  JOIN film_category fc
  ON f.film_id = fc.film_id
  JOIN category c
  ON fc.category_id = c.category_id
  WHERE name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
  ORDER BY 3) table1
GROUP BY 1, 2
ORDER BY 1, 2; 




/*QUERY 3 - query used for third insight*/

SELECT DATE_PART('month',r.rental_date) AS rental_month, DATE_PART('year',r.rental_date) AS rental_year, s.store_id store_id,
count(*) count_rentals,
DATE_PART('year',r.rental_date) || '-0' || DATE_PART('month',r.rental_date) rental_period
FROM rental r
JOIN staff s
ON r.staff_id = s.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;




/*QUERY 4 - query used for fourth insight*/

WITH results AS (SELECT DATE_TRUNC ('month', p.payment_date) pay_month, 
		c.first_name || ' ' || c.last_name full_name,
        COUNT (p.payment_date) pay_countpermon,
        SUM (p.amount) pay_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
WHERE DATE_TRUNC ('month', p.payment_date) >= '2007-01-01'
AND DATE_TRUNC ('month', p.payment_date) < '2008-01-01'
GROUP BY 1, 2
ORDER BY 2),

top_10 AS (SELECT c.first_name || ' ' || c.last_name full_name, SUM (p.amount) pay_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)

SELECT r.*
FROM results r
JOIN top_10 t
ON r.full_name = t.full_name
ORDER BY 2, 1;
