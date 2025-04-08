//view postgres rest


-- 1. Deploy PostgrREST Service (localhost:3000)
-- 2. Check Oracle ACL Security settings on REST host and port
-- 3. Connect to HTTP with Oracle 21c XE
--------------------------------------------------------------------------------------------------------------------------------
---- Create REST REMOTE Views: Postgres Data Source
--------------------------------------------------------------------------------------------------------------------------------
--- Direct Data Source Access --------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW customers_view AS
with rest_doc as
    (SELECT HTTPURITYPE.createuri('http://localhost:3000/customers')
    .getclob() as doc from dual)
SELECT
  customer_id, first_name, last_name, email, phone, registration_date
FROM  JSON_TABLE( (select doc from rest_doc) , '$[*]'
            COLUMNS (
                customer_id             number(6)    PATH '$.customer_id'
                , first_name              varchar2(30) PATH '$.first_name'
                , last_name              varchar2(30) PATH '$.last_name'
                , email              varchar2(30) PATH '$.email'
                , phone              varchar2(30) PATH '$.phone'
                , registration_date              varchar2(30) PATH '$.registration_date')
);
--- select view customers-view
SELECT * FROM customers_view;

CREATE OR REPLACE VIEW products_view AS
with rest_doc as
    (SELECT HTTPURITYPE.createuri('http://localhost:3000/products')
    .getclob() as doc from dual)
SELECT
  product_id, product_name, category, price, stock
FROM  JSON_TABLE( (select doc from rest_doc) , '$[*]'
            COLUMNS (
                product_id             number    PATH '$.product_id'
                , product_name              varchar2(30) PATH '$.product_name'
                , category              varchar2(30) PATH '$.category'
                , price              NUMBER(10,2) PATH '$.price'
                , stock              number PATH '$.stock')
);
---select products
SELECT * FROM products_view;


CREATE OR REPLACE VIEW orders_view AS
with rest_doc as
    (SELECT HTTPURITYPE.createuri('http://localhost:3000/orders')
    .getclob() as doc from dual)
SELECT
  order_id, customer_id, order_date, total_amount
FROM  JSON_TABLE( (select doc from rest_doc) , '$[*]'
            COLUMNS (
                order_id             number(6)    PATH '$.order_id'
                , customer_id              varchar2(30) PATH '$.customer_id'
                , order_date              varchar2(30) PATH '$.order_date'
                , total_amount              NUMBER(10,2) PATH '$.total_amount')
);
--- select orders
SELECT * FROM orders_view;

CREATE OR REPLACE VIEW order_items_view AS
with rest_doc as
    (SELECT HTTPURITYPE.createuri('http://localhost:3000/order_items')
    .getclob() as doc from dual)
SELECT
  order_item_id, order_id, product_id, quantity, unit_price
FROM  JSON_TABLE( (select doc from rest_doc) , '$[*]'
            COLUMNS (
             order_item_id             number(6)    PATH '$.order_item_id'
               , order_id             number(6)    PATH '$.order_id'
               , product_id             number(6)    PATH '$.product_id'
                , quantity              number(6) PATH '$.quantity'
                , unit_price            NUMBER(10,2)  PATH '$.unit_price')
);
--- select orders
SELECT * FROM order_items_view;
