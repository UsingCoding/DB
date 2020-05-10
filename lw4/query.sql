# 1. Добавить внешние ключи
ALTER TABLE booking ADD CONSTRAINT booking_client_id_client_fk FOREIGN KEY (id_client) REFERENCES client;

ALTER TABLE room_in_booking ADD CONSTRAINT room_in_booking_booking_id_booking_fk FOREIGN KEY (id_booking) REFERENCES booking;

ALTER TABLE room_in_booking ADD CONSTRAINT room_in_booking_room_id_room_fk FOREIGN KEY (id_room) REFERENCES room;

ALTER TABLE room ADD CONSTRAINT room_hotel_id_hotel_fk FOREIGN KEY (id_hotel) REFERENCES hotel;

ALTER TABLE room ADD CONSTRAINT room_room_category_id_room_category_fk FOREIGN KEY (id_room_category) REFERENCES room_category;

# 2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах категории “Люкс” на 1 апреля 2019г.
SELECT client.name, client.phone
FROM booking
         LEFT JOIN client ON client.id_client = booking.id_client
         LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
         LEFT JOIN room ON room.id_room = room_in_booking.id_room
         LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
         LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
WHERE checkin_date <= CAST('2019-04-01' AS DATE)
  AND checkout_date >= CAST('2019-04-01' AS DATE)
  AND hotel.name = 'Космос'
  AND room_category.name = 'Люкс';

#3. Дать список свободных номеров всех гостиниц на 22 апреля
SELECT * FROM room except
SELECT room.*
FROM room LEFT OUTER JOIN room_in_booking on room_in_booking.id_room = room.id_room
WHERE checkin_date <= CAST('2019-04-22' AS DATE)
  AND checkout_date >= CAST('2019-04-22' AS DATE);

#4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров
SELECT count(id_client), room_category.name
FROM booking
         LEFT JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
         LEFT JOIN room ON room.id_room = room_in_booking.id_room
         LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
         LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
WHERE checkin_date <= CAST('2019-03-23' AS DATE)
  AND checkout_date >= CAST('2019-03-23' AS DATE)
  AND hotel.name = 'Космос'
GROUP BY room_category.id_room_category;

#5. Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, выехавшим в апреле с указанием даты выезда
SELECT client.name, room.id_room, room_in_booking.checkout_date
FROM room_in_booking
         LEFT JOIN room ON room.id_room = room_in_booking.id_room
         LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
         LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
         LEFT JOIN booking ON booking.id_booking = room_in_booking.id_booking
         LEFT JOIN client ON client.id_client = booking.id_client
WHERE hotel.name = 'Космос'
  AND (checkout_date BETWEEN CAST('2019-04-01' AS date) AND CAST('2019-04-30' AS date))
GROUP BY room.id_room, client.name;

#6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам комнат категории “Бизнес”, которые заселились 10 мая.
UPDATE room_in_booking
SET checkout_date = checkout_date + INTERVAL '2 days'
WHERE room_in_booking.id_room_in_booking IN (
    SELECT room_in_booking.id_room_in_booking
    FROM room_in_booking
             LEFT JOIN booking ON room_in_booking.id_booking = booking.id_booking
             LEFT JOIN room ON room.id_room = room_in_booking.id_room
             LEFT JOIN room_category ON room_category.id_room_category = room.id_room_category
             LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
    WHERE checkin_date = CAST('2019-05-10' AS DATE)
      AND hotel.name = 'Космос'
      AND room_category.name = 'Бизнес'
);

#7. Найти все "пересекающиеся" варианты проживания. Правильное состояние:не может быть забронирован один номер на одну дату несколько раз, т.к. нельзя заселиться нескольким клиентам в один номер. Записи в таблице room_in_booking с id_room_in_booking = 5 и 2154 являются примером неправильного с остояния, которые необходимо найти. Результирующий кортеж выборки должен содержать информацию о двух конфликтующих номерах.
SELECT rib_1.id_room_in_booking as rib_1,
       rib_2.id_room_in_booking as rib_2,
       rib_1.id_room as id_room,
       rib_1.checkin_date as checkin_1,
       rib_1.checkout_date as checkout_1,
       rib_2.checkin_date as checkout_2,
       rib_2.checkout_date as checkout_2
FROM room_in_booking rib_1 LEFT JOIN room_in_booking rib_2 ON rib_1.id_room = rib_2.id_room
WHERE (rib_1.checkin_date < rib_2.checkin_date AND rib_2.checkin_date < rib_1.checkout_date) AND (rib_1.id_room_in_booking != rib_2.id_room_in_booking);


#8. Создать бронирование в транзакции.
BEGIN TRANSACTION;
INSERT INTO booking (id_client, booking_date)
VALUES (4, now());
INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
VALUES (10000, 1, date('2020-05-01'), date('2020-05-10'));
COMMIT;


#9. Добавить необходимые индексы для всех таблиц
CREATE INDEX booking_id_client_index
    ON booking (id_client);

CREATE INDEX room_in_booking_checkin_date_checkout_date_index
    ON room_in_booking (checkin_date, checkout_date);

CREATE INDEX room_in_booking_id_room_id_booking_index
    ON room_in_booking (id_room, id_booking);

CREATE INDEX room_id_hotel_id_room_category_index
    ON room (id_hotel, id_room_category);

CREATE INDEX room_category_name_id_room_category_index
    ON room_category (name);

CREATE INDEX hotel_name_index
    ON hotel (name);