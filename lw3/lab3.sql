# 1

# 1.1
INSERT INTO passenger VALUES (4, 'Ivan', 'Ivanov', '1987-04-04', '+79901324');

# 1.2
INSERT INTO passenger(first_name, second_name, age, phone_number) VALUES ('Petr', 'Liov', '1999-01-02', '+790123123');

# 1.3
INSERT INTO flight (flight_date, departure_point, destination_point, plane_id) VALUES ('2020-04-01', 'Moscow', 'NY', (SELECT plane_id from plane where crew_count = 4 LIMIT 1)); -- Вставлял здесь здесь такой селект потому что по доменной модели копировать особо нечего

# 2

# 2.1
DELETE FROM passenger;

# 2.2
DELETE FROM passenger WHERE first_name = 'Ivan';

# 2.3
TRUNCATE passenger;

# 3

# 3.1
UPDATE passenger SET phone_number = NULL;

# 3.2
UPDATE passenger SET first_name = 'Igor' WHERE passenger_id = 1;

# 3.3
UPDATE passenger SET first_name = 'Nikolay', second_name = 'Svarch' where passenger_id = 2;

# 4

# 4.1
SELECT first_name, second_name from passenger;

# 4.2
SELECT * FROM passenger;

# 4.3
SELECT * FROM passenger WHERE second_name = 'Ivan';

# 5

# 5.1
SELECT * FROM passenger ORDER BY first_name LIMIT 100;

# 5.2
SELECT * FROM passenger ORDER BY first_name DESC;

# 5.3
SELECT * FROM passenger ORDER BY first_name, second_name LIMIT 50;

# 5.4
SELECT * FROM passenger ORDER BY 1 LIMIT 100;

# 6

# 6.1
SELECT * FROM flight WHERE flight_date = '2020-04-01';

# 6.2
SELECT YEAR(flight_date) from flight;

# 7

# 7.1
SELECT comfort_level, MIN(gas_tank_volume_in_liters) as 'Something meaningful' FROM plane GROUP BY comfort_level;

# 7.2
SELECT comfort_level, MAX(gas_tank_volume_in_liters) as 'Something meaningful' FROM plane GROUP BY comfort_level;

# 7.3
SELECT comfort_level, AVG(comfort_level) as 'Something meaningful' FROM plane GROUP BY comfort_level;

# 7.4
SELECT comfort_level, SUM(crew_count) as 'Something meaningful' FROM plane GROUP BY capacity;

# 7.5
SELECT comfort_level, COUNT(*) as 'Something meaningful' FROM plane GROUP BY comfort_level;

# 8

# 8.1
SELECT first_name FROM passenger GROUP BY second_name, age HAVING YEAR(age) > 1980;

# 8.2
SELECT comfort_level, crew_count FROM plane GROUP BY capacity HAVING capacity > 100;

# 8.3
SELECT weight, volume FROM baggage GROUP BY is_fragile HAVING is_fragile = TRUE;

# 9

# 9.1
SELECT * FROM passenger LEFT JOIN ticket ON passenger.passenger_id = ticket.passenger_id;

# 9.2
SELECT * FROM passenger RIGHT JOIN ticket ON passenger.passenger_id = ticket.passenger_id;

# 9.3
SELECT price, class, first_name, departure_point FROM passenger LEFT JOIN ticket ON passenger.passenger_id = ticket.passenger_id LEFT JOIN flight ON ticket.flight_id = flight.flight_id;

# 9.4
SELECT * FROM passenger LEFT JOIN ticket t on passenger.passenger_id = t.passenger_id UNION SELECT * FROM passenger RIGHT JOIN ticket ON passenger.passenger_id = ticket.passenger_id;


# 10

# 10.1
SELECT * FROM passenger WHERE passenger_id = (SELECT passenger_id FROM ticket WHERE price > 100);

# 10.2
SELECT first_name, second_name, (SELECT price FROM ticket WHERE passenger_id = passenger.passenger_id) AS 'Price for ticket' FROM passenger;