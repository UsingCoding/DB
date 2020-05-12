# 1. Добавить внешние ключи
ALTER TABLE order
    ADD CONSTRAINT order_dealer_id_dealer_fk
        FOREIGN KEY (id_dealer) REFERENCES dealer;

ALTER TABLE order
    ADD CONSTRAINT order_pharmacy_id_pharmacy_fk
        FOREIGN KEY (id_pharmacy) REFERENCES pharmacy;

ALTER TABLE order
    ADD CONSTRAINT order_production_id_production_fk
        FOREIGN KEY (id_production) REFERENCES production;

ALTER TABLE production
    ADD CONSTRAINT production_company_id_company_fk
        FOREIGN KEY (id_company) REFERENCES company;

ALTER taBle production
    ADD CONSTRAINT production_medicine_id_medicine_fk
        FOREIGN KEY (id_medicine) REFERENCES medicine;

ALTER TABLE dealer
    ADD CONSTRAINT dealer_company_id_company_fk
        FOREIGN KEY (id_company) REFERENCES company;

# 2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов

SELECT pharmacy.name,
       order.date,
       order.quantity
FROM order
         LEFT JOIN pharmacy ON order.id_pharmacy = pharmacy.id_pharmacy
         LEFT JOIN production ON order.id_production = production.id_production
         LEFT JOIN company ON production.id_company = company.id_company
         LEFT JOIN medicine ON production.id_medicine = medicine.id_medicine
WHERE medicine.name = 'Кордеон'
  AND company.name = 'Аргус';

# 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января

SELECT medicine.name
FROM medicine
         except
SELECT medicine.name
FROM medicine
         LEFT JOIN production ON medicine.id_medicine = production.id_medicine
         LEFT JOIN company ON production.id_company = company.id_company
         LEFT JOIN order ON production.id_production = order.id_production
WHERE company.name = 'Фарма'
GROUP BY medicine.name
HAVING MIN(order.date) < CAST('2019-01-25' AS DATE);

# 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов

SELECT company.name,
       MIN(production.rating) AS min_rating,
       MAX(production.rating) AS max_rating
FROM production
         LEFT JOIN company ON production.id_company = company.id_company
         LEFT JOIN order ON production.id_production = order.id_production
GROUP BY company.id_company, company.name
HAVING COUNT(order.id_order) >= 120;

# 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL

SELECT dealer.id_dealer,
       dealer.name,
       pharmacy.name
FROM dealer
         LEFT JOIN company ON dealer.id_company = company.id_company
         LEFT JOIN order ON order.id_dealer = dealer.id_dealer
         LEFT JOIN pharmacy ON pharmacy.id_pharmacy = order.id_pharmacy
WHERE company.name = 'AstraZeneca'
ORDER BY dealer.id_dealer

# 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней

UPDATE production
SET price = price * 0.8
WHERE production.id_production IN (
    SELECT production.id_production
    FROM production
             LEFT JOIN medicine ON production.id_medicine = medicine.id_medicine
    WHERE production.price > CAST(3000 AS DECIMAL) AND medicine.cure_duration <= CAST(7 AS SMALLINT)
);

# 7. Добавить необходимые индексы

CREATE INDEX dealer_id_company_index
    ON dealer (id_company);

CREATE INDEX production_id_company_index
    ON production (id_company);

CREATE INDEX production_id_medicine_index
    ON production (id_medicine);

CREATE INDEX production_rating_index
    ON production (rating);

CREATE INDEX order_date_index
    ON order (date);

CREATE INDEX order_id_dealer_index
    ON order (id_dealer);

CREATE INDEX order_id_pharmacy_index
    ON order (id_pharmacy);

CREATE INDEX order_id_production_index
    ON order (id_production);

CREATE INDEX company_name_index
    ON company (name);

CREATE INDEX medicine_name_index
    ON medicine (name);

