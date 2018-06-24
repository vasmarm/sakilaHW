-- HOMEWORK SQL --


-- USE sakila --
USE sakila;
-- List of all tables --
Show Tables;


-- --------------------------------------- --
-- 1a. Display the first and last names of all actors from the table actor. --
Select first_name, last_name from actor;

-- --------------------------------------- --
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. --
Select concat(UCASE(first_name), ' ', UCASE(last_name)) as 'Actor Name' from actor;

-- ============================================================= --
-- --------------------------------------- --
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id, first_name, last_name from actor where first_name = "Joe";

-- --------------------------------------- --
-- 2b. Find all actors whose last name contain the letters GEN:
Select * from actor where last_name like '%GEN%';

-- --------------------------------------- --
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
Select * from actor where last_name like '%LI%' order by last_name, first_name;

-- --------------------------------------- --
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
Select country_id, country from country where country IN("Afghanistan", "Bangladesh", "China");

-- ============================================================= --
-- --------------------------------------- --
-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
Alter Table actor Add middle_name varchar(30);
Select * from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
Alter table actor Modify Column middle_name Blob;
Describe actor;

-- --------------------------------------- --
-- 3c. Now delete the middle_name column.
Alter table actor drop column middle_name;
Describe actor;

-- ============================================================= --
-- --------------------------------------- --
-- 4a. List the last names of actors, as well as how many actors have that last name.
Select last_name, count(last_name) from actor group by last_name;

-- --------------------------------------- --
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name) from actor group by last_name having count(last_name) > 1;

-- --------------------------------------- --
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
Update actor Set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';
Select * from actor where actor_id = 172;

-- --------------------------------------- --
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
Update actor Set first_name = 'GROUCHO' where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- ============================================================= --
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
Describe address;
SHOW CREATE TABLE sakila.address;

-- 
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
-- 

-- ============================================================= --
-- --------------------------------------- --
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
Select staff.first_name, staff.last_name, address.address from staff join address on staff.address_id = address.address_id;

-- --------------------------------------- --
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
Select staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount) As 'Total Amount' 
	from staff join payment on staff.staff_id = payment.staff_id 
    where payment.payment_date between '2005-08-01 00:00:00' and '2005-08-31 11:59:59' GROUP BY staff.staff_id;

-- --------------------------------------- --
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
Select film_actor.film_id, film.title, Count(film_actor.actor_id) as 'Number of Actors'
 from film join film_actor on film.film_id = film_actor.film_id group by film_actor.film_id; 

-- --------------------------------------- --
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
Select film.film_id, film.title, count(inventory.film_id) As 'Number of Copies' from film 
	join inventory on film.film_id = inventory.film_id where film.title = 'Hunchback Impossible' group by film.film_id;

-- --------------------------------------- --
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
Select customer.customer_id, customer.first_name, customer.last_name, Sum(payment.amount) As 'Total Amount Paid' from customer 
	join payment on customer.customer_id = payment.customer_id group by payment.customer_id order by customer.last_name, customer.first_name;

--     ![Total amount paid](Images/total_payment.png)

-- ============================================================= --
-- --------------------------------------- --
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
Select * from film where (title like "K%") or (title like "Q%") 
	and language_id = (Select language_id from language where name = 'English');

-- --------------------------------------- --
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
	WHERE film_id IN
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));

-- --------------------------------------- --
-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer join address on customer.address_id = address.address_id 
	join city on address.city_id = city.city_id join country on city.country_id = country.country_id
	WHERE country.country = 'Canada';

-- --------------------------------------- --
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
Select * from film 
	where film_id IN (Select film_id from film_category 
	where category_id = (Select category_id from category where name = 'Family'));

-- --------------------------------------- --
-- 7e. Display the most frequently rented movies in descending order.
Select title, count(rental.rental_id) As 'Number of Times Rented' from film 
	join inventory on film.film_id = inventory.film_id 
    join rental on inventory.inventory_id = rental.inventory_id group by film.title order by count(rental.rental_id) desc;

-- --------------------------------------- --
-- 7f. Write a query to display how much business, in dollars, each store brought in.
Select store.store_id, sum(payment.amount) As 'Total Revenue' from store
	right join staff on store.store_id = staff.store_id 
    left join payment on staff.staff_id = payment.staff_id group by store.store_id;

-- --------------------------------------- --
-- 7g. Write a query to display for each store its store ID, city, and country.
Select store.store_id, city.city, country.country from store
	join address on store.address_id = address.address_id
    join city on address.city_id = city.city_id
    join country on city.country_id = country.country_id;
    
-- --------------------------------------- --    
-- 7h. List the top five genres in gross revenue in descending order.
--  (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
Select category.name, sum(amount) As 'Total Revenue' from category
	join film_category on category.category_id = film_category.category_id
    join inventory on film_category.film_id = inventory.film_id
    join rental on inventory.inventory_id = rental.inventory_id
    join payment on rental.staff_id = payment.staff_id group by category.name order by sum(amount) desc;

-- ============================================================= --
-- --------------------------------------- --
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
show tables;
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;

CREATE VIEW top_five_genres AS
	Select category.name, sum(amount) As 'Total Revenue' from category
		join film_category on category.category_id = film_category.category_id
		join inventory on film_category.film_id = inventory.film_id
		join rental on inventory.inventory_id = rental.inventory_id
		join payment on rental.staff_id = payment.staff_id group by category.name order by sum(amount) desc
	LIMIT 5;
		
-- --------------------------------------- --
-- 8b. How would you display the view that you created in 8a?
Select * from top_five_genres;

-- --------------------------------------- --
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
Drop view top_five_genres;


-- ============================================================= --
-- ============================================================= --