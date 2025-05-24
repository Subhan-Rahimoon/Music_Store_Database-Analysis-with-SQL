-- Who is most senior employee 

SELECT * FROM employee
ORDER BY levels DESC 
LIMIT 1;

-- which country have most invoices 
SELECT COUNT(invoice) , billing_country FROM invoice 
GROUP BY billing_country
ORDER BY COUNT(invoice) DESC
LIMIT 1;

-- top 3 invoice 
SELECT total FROM invoice 
ORDER BY total DESC
LIMIT 3;


-- which city has best customer

SELECT SUM(total) , billing_city FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC;

-- who is best customer 

SELECT c.first_name , c.last_name , SUM(total) FROM invoice AS i
JOIN customer c
on i.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY SUM(total) DESC
LIMIT 1;


-- Write query to return the email , first name , last name & Genre of all 
-- Rock music listeners. Return your list order alphabeticlly by email starting with A



SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;


-- Let's invite the artist who have written the most rock music in 
-- our dataset. Write a query that return the Artist name and total track count of the top 10 rock bands

SELECT a.name AS artist_name, COUNT(t.track_id) AS total_count_song
FROM Artist AS a
JOIN Album AS alb ON a.artist_id = alb.artist_id
JOIN Track AS t ON alb.album_id = t.album_id
JOIN Genre AS g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_count_song DESC
LIMIT 10;

-- Return all the track names that have a song length longer than te average song length.
-- Return the name and millisecond for each track. Order by song length with the longest song
-- listed first


SELECT 
    name, 
    milliseconds 
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC;


-- Find how much amount spend by earch customer on artists? write query to return customer name , artist name
-- and total spent

SELECT 
    c.first_name, 
    c.last_name, 
    art.name AS artist_name,
    art.artist_id, 
    SUM(il.quantity * il.unit_price) AS total_sales
FROM customer AS c
JOIN invoice AS inv ON c.customer_id = inv.customer_id
JOIN invoice_line AS il ON inv.invoice_id = il.invoice_id
JOIN track AS t ON il.track_id = t.track_id
JOIN album AS alb ON t.album_id = alb.album_id
JOIN artist AS art ON alb.artist_id = art.artist_id
GROUP BY c.first_name, c.last_name, art.name, art.artist_id
ORDER BY total_sales DESC;


-- we want to find out the most popular music genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchase.
-- Write a query that returns each country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genres.



WITH genre_rank AS (
    SELECT 
        c.country, 
        g.name AS genre_name, 
        COUNT(il.quantity) AS total_purchase,
        RANK() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS rank
    FROM customer AS c
    JOIN invoice AS inv ON c.customer_id = inv.customer_id
    JOIN invoice_line AS il ON inv.invoice_id = il.invoice_id
    JOIN track AS t ON il.track_id = t.track_id
    JOIN genre AS g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
)
SELECT 
    country, 
    genre_name, 
    total_purchase
FROM genre_rank
WHERE rank = 1
ORDER BY country;


-- Write a query that determines the customer that has spend the most on music for each country. Write a qeury that returns the country 
-- along wit hthe top customer and how much they spent. for country where
-- the top amount spent is shared, provide all customers who spend this amount




WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        SUM(il.unit_price * il.quantity) AS total_spent,
        RANK() OVER(PARTITION BY c.country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS rank
    FROM customer AS c
    JOIN invoice AS i ON c.customer_id = i.customer_id
    JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT 
    country,
    first_name,
    last_name,
    total_spent
FROM customer_spending
WHERE rank = 1
ORDER BY total_spent DESC;
















