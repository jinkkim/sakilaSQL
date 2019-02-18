use sakila;

# 1a
select first_name, last_name from actor

# 1b
select concat(first_name, ' ', last_name) AS Actor_Name from actor;

# 2a
select actor_id, first_name, last_name from actor where first_name = 'Joe';

# 2b
select actor_id, first_name, last_name from actor where last_name LIKE '%GEN%';

# 2C
select actor_id, first_name, last_name from actor where last_name LIKE '%LI%' order by last_name asc, first_name asc;

# 2d
select country_id, country from country where country IN ("Afghanistan", "Bangladesh", "China")

# 3a
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_update`;

# 3b
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `description`;

# 4a
select last_name, count(*) from actor group by last_name;

# 4b
select last_name, count(*) AS count from actor group by last_name having count > 1;

# 4c
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' AND last_name='WILLIAMS';

# 4d
update actor set first_name = 'GROUCHO' where first_name = 'HARPO' AND last_name='WILLIAMS';

# 5a
#show create table address

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

# 6a
select first_name, last_name, address from staff join address on staff.address_id = address.address_id;

# 6b
	# from payment table 
	#select staff_id, sum(amount) as total_amount from payment where payment_date like '2005-08%' group by staff_id;
    
select first_name, last_name, total_amount from staff join (select staff_id, sum(amount) as total_amount from payment where payment_date like '2005-08%' group by staff_id) x on staff.staff_id = x.staff_id;


# 6c
	# from film_actor
    # select film_id, count(*) AS count from film_actor group by film_id;
select title, a.count from film inner join (select film_id, count(*) as count from film_actor group by film_id) a on film.film_id = a.film_id;

# 6d
	# find out film id of "hunchback impossible" from film table 
	# select film_id from film where title='hunchback impossible'
select count(*) as copies from inventory where film_id = (select film_id from film where title='hunchback impossible');

# 6e
	# from payment table
	# select customer_id, sum(amount) as total_amount from payment group by customer_id;

select first_name, last_name, total_amount from customer join (select customer_id, sum(amount) as total_amount from payment group by customer_id) b on customer.customer_id = b.customer_id order by last_name asc;



# 7a
    # language_id = 1 = English
    # select language_id from language where name = "English"
select title, language_id from film where (title like "K%" OR title like "Q%") AND language_id = (select language_id from language where name = "English");



# 7b
    # select film_id from film where title = "Alone Trip";
    # select actor_id from film_actor where film_id = (select film_id from film where title = "Alone Trip");

select first_name, last_name from actor where actor_id IN (select actor_id from film_actor where film_id = (select film_id from film where title = "Alone Trip"));



# 7c

	# CANADA country id:
	# select country_id from country where country="Canada"

	# list of cities in canada:
	# select city_id from city where country_id = (select country_id from country where country="Canada")
	
	# list of address ids in canada's cities:
	# select address_id from address where city_id IN (select city_id from city where country_id = (select country_id from country where country="Canada"))

# names and adresses from canada
select first_name, last_name, email from customer where address_id in (select address_id from address where city_id IN (select city_id from city where country_id = (select country_id from country where country="Canada")));



# 7d

	# "family" category = 8
	# select category_id from category where name = 'family'

	# film ids in family category
	# select film_id from film_category where category_id = (select category_id from category where name = 'family')

# titles in family category
select title from film where film_id in (select film_id from film_category where category_id = (select category_id from category where name = 'family'));




# 7e

	# rental count by inventory ids 
	# select inventory_id, count(*) as rent_count from rental group by inventory_id;

	# film ids from inventory
	# select film_id, sum(rent_count) as rent_recount from inventory inner join (select inventory_id, count(*) as rent_count from rental group by inventory_id) c on inventory.inventory_id = c.inventory_id group by film_id order

# film id --> title
select title, rent_recount from film inner join (select film_id, sum(rent_count) as rent_recount from inventory inner join (select inventory_id, count(*) as rent_count from rental group by inventory_id) c on inventory.inventory_id = c.inventory_id group by film_id) d on film.film_id = d.film_id order by rent_recount desc;



# 7f
	# from payment table
	# select staff_id, sum(amount) as revenue from payment group by staff_id;

# staff id --> store id
select store_id, revenue from staff join (select staff_id, sum(amount) as revenue from payment group by staff_id) e on staff.staff_id = e.staff_id;



# 7g
	# store id + address id:
	# select store_id, address_id from store;
    
    # store id + city id:
	# select store_id, city_id from address inner join (select store_id, address_id from store) f on address.address_id = f.address_id
	
    # store id + city name + country id:
    # select store_id, city, country_id from city inner join (select store_id, city_id from address inner join (select store_id, address_id from store) f on address.address_id = f.address_id) g on city.city_id = g.city_id

# store id + city name + country
select store_id, city, country from country inner join (select store_id, city, country_id from city inner join (select store_id, city_id from address inner join (select store_id, address_id from store) f on address.address_id = f.address_id) g on city.city_id = g.city_id
) h on country.country_id = h.country_id;



# 7h
# rental id + revenue:
# select rental_id, sum(amount) as revenue from payment group by rental_id

# inventory id + revenue:
# select inventory_id, revenue from rental inner join (select rental_id, sum(amount) as revenue from payment group by rental_id) i on rental.rental_id = i.rental_id

# film id + revenue (remove duplicate):
# select film_id, sum(revenue) as total_revenue from inventory inner join (select inventory_id, revenue from rental inner join (select rental_id, sum(amount) as revenue from payment group by rental_id) i on rental.rental_id = i.rental_id) j on inventory.inventory_id = j.inventory_id group by film_id

# category id + gross revenue (remove duplicate, descending sort, limit 5):
# select category_id, sum(total_revenue) as gross_revenue from film_category inner join (select film_id, sum(revenue) as total_revenue from inventory inner join (select inventory_id, revenue from rental inner join (select rental_id, sum(amount) as revenue from payment group by rental_id) i on rental.rental_id = i.rental_id) j on inventory.inventory_id = j.inventory_id group by film_id) k on film_category.film_id = k.film_id group by category_id order by gross_revenue desc limit 5

# category + gross revenue (finally the END!!)
select name as genre, gross_revenue from category inner join (select category_id, sum(total_revenue) as gross_revenue from film_category inner join (select film_id, sum(revenue) as total_revenue from inventory inner join (select inventory_id, revenue from rental inner join (select rental_id, sum(amount) as revenue from payment group by rental_id) i on rental.rental_id = i.rental_id) j on inventory.inventory_id = j.inventory_id group by film_id) k on film_category.film_id = k.film_id group by category_id order by gross_revenue desc limit 5) l on category.category_id = l.category_id;


# 8a
CREATE VIEW top_five_genres AS SELECT name as genre, gross_revenue from category inner join (select category_id, sum(total_revenue) as gross_revenue from film_category inner join (select film_id, sum(revenue) as total_revenue from inventory inner join (select inventory_id, revenue from rental inner join (select rental_id, sum(amount) as revenue from payment group by rental_id) i on rental.rental_id = i.rental_id) j on inventory.inventory_id = j.inventory_id group by film_id) k on film_category.film_id = k.film_id group by category_id order by gross_revenue desc limit 5) l on category.category_id = l.category_id;

# 8b
select * from top_five_genres;

# 8c
drop view top_five_genres;