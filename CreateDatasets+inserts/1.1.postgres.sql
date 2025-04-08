-- DROP existing tables (dacă există)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Tabela "customers": informații despre clienți
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    registration_date DATE DEFAULT CURRENT_DATE
);

-- Tabela "products": informații despre produse
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);

-- Tabela "orders": informații despre comenzi
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Tabela "order_items": detalii ale comenzilor
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

--------------------------------------------------
-- Inserare în tabelul "customers" (20 de înregistrări)
INSERT INTO customers (first_name, last_name, email, phone, registration_date) VALUES
('Ana', 'Ionescu', 'ana.ionescu@example.com', '0722000001', '2023-01-05'),
('Bogdan', 'Popa', 'bogdan.popa@example.com', '0722000002', '2023-01-06'),
('Carmen', 'Georgescu', 'carmen.georgescu@example.com', '0722000003', '2023-01-07'),
('Dan', 'Marinescu', 'dan.marinescu@example.com', '0722000004', '2023-01-08'),
('Elena', 'Stan', 'elena.stan@example.com', '0722000005', '2023-01-09'),
('Florin', 'Dumitru', 'florin.dumitru@example.com', '0722000006', '2023-01-10'),
('Gabriela', 'Vasilescu', 'gabriela.vasilescu@example.com', '0722000007', '2023-01-11'),
('Horia', 'Nistor', 'horia.nistor@example.com', '0722000008', '2023-01-12'),
('Ioana', 'Radu', 'ioana.radu@example.com', '0722000009', '2023-01-13'),
('Jules', 'Costache', 'jules.costache@example.com', '0722000010', '2023-01-14'),
('Karla', 'Iliescu', 'karla.iliescu@example.com', '0722000011', '2023-01-15'),
('Luca', 'Munteanu', 'luca.munteanu@example.com', '0722000012', '2023-01-16'),
('Mara', 'Stanciu', 'mara.stanciu@example.com', '0722000013', '2023-01-17'),
('Nicu', 'Petrescu', 'nicu.petrescu@example.com', '0722000014', '2023-01-18'),
('Oana', 'Barbu', 'oana.barbu@example.com', '0722000015', '2023-01-19'),
('Paul', 'Iacob', 'paul.iacob@example.com', '0722000016', '2023-01-20'),
('Roxana', 'Vladescu', 'roxana.vladescu@example.com', '0722000017', '2023-01-21'),
('Stefan', 'Morar', 'stefan.morar@example.com', '0722000018', '2023-01-22'),
('Tudor', 'Cernat', 'tudor.cernat@example.com', '0722000019', '2023-01-23'),
('Valentina', 'Dima', 'valentina.dima@example.com', '0722000020', '2023-01-24');

--------------------------------------------------
-- Inserare în tabelul "products" (20 de înregistrări)
INSERT INTO products (product_name, category, price, stock) VALUES
('Smartphone X', 'Electronice', 299.99, 150),
('Laptop Pro', 'Calculatoare', 1200.00, 80),
('Tablet Z', 'Electronice', 450.50, 200),
('Smartwatch A', 'Accesorii', 199.99, 300),
('Căști Wireless', 'Accesorii', 89.99, 250),
('Camera HD', 'Electronice', 350.00, 90),
('Monitor 24"', 'Calculatoare', 220.00, 75),
('Imprimantă Laser', 'Office', 180.00, 60),
('Router Wi-Fi', 'Rețea', 75.50, 120),
('SSD 500GB', 'Calculatoare', 99.99, 300),
('Mouse Ergonomic', 'Accesorii', 25.00, 500),
('Tastatură Mecanică', 'Accesorii', 70.00, 400),
('Disc extern 1TB', 'Calculatoare', 150.00, 180),
('Webcam Full HD', 'Accesorii', 55.00, 210),
('Sistem audio', 'Electronice', 120.00, 140),
('HDMI Cable', 'Accesorii', 15.00, 600),
('Power Bank', 'Accesorii', 45.00, 350),
('Mouse Pad', 'Accesorii', 10.00, 700),
('Laptop Stand', 'Office', 30.00, 400),
('USB Hub', 'Calculatoare', 20.00, 500);

--------------------------------------------------
-- Inserare în tabelul "orders" (20 de înregistrări)
-- Se presupune că fiecare comandă aparține unui client existent
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2023-06-01 10:00:00', 599.98),
(2, '2023-06-02 11:15:00', 1200.00),
(3, '2023-06-03 09:30:00', 299.99),
(4, '2023-06-04 14:45:00', 450.50),
(5, '2023-06-05 16:20:00', 199.99),
(6, '2023-06-06 08:55:00', 89.99),
(7, '2023-06-07 12:10:00', 350.00),
(8, '2023-06-08 15:30:00', 220.00),
(9, '2023-06-09 17:05:00', 180.00),
(10, '2023-06-10 10:40:00', 75.50),
(11, '2023-06-11 09:15:00', 99.99),
(12, '2023-06-12 11:30:00', 25.00),
(13, '2023-06-13 14:00:00', 70.00),
(14, '2023-06-14 16:45:00', 150.00),
(15, '2023-06-15 10:30:00', 55.00),
(16, '2023-06-16 13:20:00', 120.00),
(17, '2023-06-17 15:00:00', 15.00),
(18, '2023-06-18 09:45:00', 45.00),
(19, '2023-06-19 11:10:00', 10.00),
(20, '2023-06-20 14:30:00', 30.00);

--------------------------------------------------
-- Inserare în tabelul "order_items" (20 de înregistrări)
-- Se asociază fiecare înregistrare cu o comandă și un produs existent
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 299.99),
(2, 2, 1, 1200.00),
(3, 1, 1, 299.99),
(4, 3, 1, 450.50),
(5, 4, 1, 199.99),
(6, 5, 1, 89.99),
(7, 6, 1, 350.00),
(8, 7, 1, 220.00),
(9, 8, 1, 180.00),
(10, 9, 1, 75.50),
(11, 10, 1, 99.99),
(12, 11, 1, 25.00),
(13, 12, 1, 70.00),
(14, 13, 1, 150.00),
(15, 14, 1, 55.00),
(16, 15, 1, 120.00),
(17, 16, 1, 15.00),
(18, 17, 1, 45.00),
(19, 18, 1, 10.00),
(20, 19, 1, 30.00);
