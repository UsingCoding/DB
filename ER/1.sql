CREATE TABLE product (
    id_product int auto_increment,
    name varchar(255),
    price decimal(10, 2),
    delay_date DATE default null,
    id_warehouse int,
    primary key (id_product),
    constraint product_warehouse_id_warehouse_fk
    foreign key (id_warehouse) references warehouse(id_warehouse)
);

CREATE TABLE seller (
    id_seller int auto_increment,
    first_name varchar(255),
    last_name varchar(255),
    birthday_date DATE,
    personal_number int,
    primary key (id_seller)
);

CREATE TABLE customer (
    id_customer int auto_increment,
    first_name varchar(255),
    last_name varchar(255),
    birthday_date DATE,
    phone_number varchar(12),
    primary key (id_customer)
);

CREATE TABLE product_reviews (
    id_product_reviews int auto_increment,
    title varchar(70) not null,
    description varchar(255) default null,
    creation_date datetime,
    updated_date datetime,
    id_product int,
    id_customer int,
    primary key (id_product_reviews),
    constraint product_reviews_product_id_product_fk
    foreign key (id_product) references product(id_product),
    constraint product_reviews_customer_id_customer_fk
    foreign key (id_customer) references customer(id_customer)
);

CREATE TABLE warehouse (
    id_warehouse int auto_increment,
    title varchar(255),
    address varchar(255),
    rent_price decimal(10, 2),
    capacity int,
    primary key (id_warehouse)
);

CREATE TABLE sale (
    id_sale int auto_increment,
    id_product int,
    id_seller int,
    id_customer int,
    date datetime,
    primary key (id_sale),
    constraint sale_product_id_product_fk
    foreign key (id_product) references product(id_product),
    constraint sale_seller_id_seller_fk
    foreign key (id_seller) references seller(id_seller),
    constraint sale_customer_id_customer_fk
    foreign key (id_customer) references customer(id_customer)
);