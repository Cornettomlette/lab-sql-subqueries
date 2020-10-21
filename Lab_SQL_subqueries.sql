/*Lab | SQL Subqueries
In this lab, you will be using the Sakila database of movie rentals.

Instructions
	How many copies of the film Hunchback Impossible exist in the inventory system?
	List all films longer than the average.
	Use subqueries to display all actors who appear in the film Alone Trip.
	Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
	Get name and email from customers from Canada using subqueries. Do the same with joins.
	Which are films starred by the most prolific actor?
	Films rented by most profitable customer.
	Customers who spent more than the average.*/
USE sakila;
SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM (SELECT film.film_id, title, count(inventory_id) 
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
GROUP BY film.film_id) as sub
WHERE title = 'Hunchback Impossible';

-- List all films longer than the average.
SELECT film_id, title, length 
FROM film
WHERE length > (SELECT avg(length) FROM film);

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM (SELECT film.film_id, title, film_actor.actor_id, concat(first_name, ' ', last_name)
FROM film_actor
INNER JOIN film ON film_actor.film_id =  film.film_id
INNER JOIN actor ON film_actor.actor_id =  actor.actor_id) as sub
WHERE title = 'Alone Trip';

-- You wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM (SELECT film.film_id, title, category.name as cat_name
FROM film
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id) as sub
WHERE cat_name = 'Family';
 
-- Get name and email from customers from Canada using subqueries. Do the same with joins.
SELECT * FROM (SELECT customer_id, concat(first_name, " ", last_name) as full_name, email, country 
FROM customer
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id) as sub
WHERE country = "Canada";

SELECT customer_id, concat(first_name, " ", last_name) as full_name, email, country 
FROM customer
INNER JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country = "Canada";

-- Which are films starred by the most prolific actor?
# number of films count
SELECT actor_id, count(film_id) as num_films FROM film_actor
GROUP BY actor_id;

# max number
SELECT max(num_films) FROM (SELECT actor_id, count(film_id) as num_films FROM film_actor
GROUP BY actor_id) as sub;

# actor id with max number
SELECT actor_id FROM (SELECT actor_id, count(film_id) as num_films FROM film_actor
GROUP BY actor_id) as sub1 
WHERE sub1.num_films = (SELECT max(num_films) FROM (SELECT actor_id, count(film_id) as num_films FROM film_actor
GROUP BY actor_id) as sub);

# final query
SELECT actor.actor_id, concat(first_name, " ", last_name) as full_name, film.film_id, title
FROM actor
INNER JOIN film_actor on film_actor.actor_id = actor.actor_id
INNER JOIN film ON film_actor.film_id = film.film_id
WHERE actor.actor_id = (SELECT actor_id FROM (SELECT actor_id, count(film_id) as num_films FROM film_actor
GROUP BY actor_id) as sub1 
WHERE sub1.num_films = (SELECT max(num_films) FROM (SELECT actor_id, count(film_id) as num_films FROM film_actor
GROUP BY actor_id) as sub));

-- Films rented by most profitable customer.
# customers and sum of money spent on rentals
SELECT customer_id, sum(amount) as sum_spent
FROM payment
GROUP BY customer_id;

# max sum spent on rentals
SELECT max(sum_spent) FROM (SELECT customer_id, sum(amount) as sum_spent
FROM payment
GROUP BY customer_id) as sub;

# customer_id with max spent on rentals
SELECT customer_id FROM (SELECT customer_id, sum(amount) as sum_spent
FROM payment
GROUP BY customer_id) as sub1 
WHERE sub1.sum_spent = (SELECT max(sum_spent) FROM (SELECT customer_id, sum(amount) as sum_spent
FROM payment
GROUP BY customer_id) as sub);

# final query

SELECT customer.customer_id, concat(first_name, " ", last_name) as full_name, film.film_id, title
FROM rental
INNER JOIN customer ON rental.customer_id = customer.customer_id
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film ON inventory.film_id = film.film_id
WHERE customer.customer_id = (SELECT customer_id FROM (SELECT customer_id, sum(amount) as sum_spent
FROM payment GROUP BY customer_id) as sub1 
WHERE sub1.sum_spent = (SELECT max(sum_spent) FROM (SELECT customer_id, sum(amount) as sum_spent
FROM payment
GROUP BY customer_id) as sub));

-- Customers who spent more than the average
# the average money spending
SELECT customer_id, sum(amount) as spending FROM payment
GROUP BY customer_id;

SELECT round(avg(spending), 2) FROM (SELECT customer_id, sum(amount) as spending FROM payment
GROUP BY customer_id) as sub;

# final query 
SELECT customer.customer_id, concat(first_name, " ", last_name) as full_name, sum(amount) as spending 
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
HAVING spending > (SELECT round(avg(spending), 2) FROM (SELECT customer_id, sum(amount) as spending FROM payment
GROUP BY customer_id) as sub);