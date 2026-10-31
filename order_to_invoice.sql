-- =====================================================================
-- Order-to-Invoice System: Sharma Stationery (case study)
-- Works in SQLite / DB Browser for SQLite (free). Run the whole file.
-- Steps: 1) messy staging data  2) clean tables  3) migrate  4) reports
-- =====================================================================

DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS staging_orders;

-- ---------------------------------------------------------------------
-- STEP 1: Messy data, as it would come from the old Excel sheet
-- Problems on purpose: 1 duplicate row, names in different formats,
-- missing phone, missing price, missing payment status.
-- ---------------------------------------------------------------------
CREATE TABLE staging_orders (
    order_ref       TEXT,
    order_date      TEXT,
    customer_name   TEXT,
    phone           TEXT,
    product_name    TEXT,
    qty             INTEGER,
    unit_price      REAL,
    payment_status  TEXT
);

INSERT INTO staging_orders VALUES
('ORD001','2026-10-01','Rahul Patil','9890011111','A4 Paper Ream',5,260,'Paid'),
('ORD001','2026-10-01','Rahul Patil','9890011111','A4 Paper Ream',5,260,'Paid'),
('ORD002','2026-10-02',' Anita Deshmukh','9890022222','Blue Pen Box',10,120,'Paid'),
('ORD003','2026-10-03','Suresh Kale',NULL,'Notebook',20,45,'Pending'),
('ORD004','2026-10-05','anita deshmukh','9890022222','Stapler',2,150,'Paid'),
('ORD005','2026-10-06','Meera Joshi','9890033333','File Folder',15,35,'Pending'),
('ORD006','2026-10-08','rahul patil ','9890011111','Notebook',10,45,'Paid'),
('ORD007','2026-10-09','Vikram More','9890044444','A4 Paper Ream',8,260,'Pending'),
('ORD008','2026-10-12','Meera Joshi','9890033333','Blue Pen Box',4,120,'Paid'),
('ORD009','2026-10-14','Suresh Kale','9890055555','Stapler',1,150,'Paid'),
('ORD010','2026-10-15','Neha Kulkarni','9890066666','File Folder',30,35,NULL),
('ORD011','2026-10-18','Vikram More','9890044444','Notebook',25,45,'Paid'),
('ORD012','2026-10-20','Neha Kulkarni','9890066666','Blue Pen Box',6,NULL,'Paid');

-- ---------------------------------------------------------------------
-- STEP 2: Clean tables (the design from the BRD, section 7)
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT NOT NULL UNIQUE,
    phone        TEXT
);

CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name  TEXT NOT NULL UNIQUE,
    price         REAL NOT NULL,
    stock_qty     INTEGER DEFAULT 0
);

CREATE TABLE orders (
    order_id     TEXT PRIMARY KEY,          -- primary key blocks duplicate orders (BR-06)
    order_date   TEXT NOT NULL,
    customer_id  INTEGER NOT NULL REFERENCES customers(customer_id),
    product_id   INTEGER NOT NULL REFERENCES products(product_id),
    quantity     INTEGER NOT NULL,
    unit_price   REAL NOT NULL
);

CREATE TABLE invoices (
    invoice_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id    TEXT NOT NULL REFERENCES orders(order_id),
    amount      REAL NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('Paid','Pending'))
);

-- ---------------------------------------------------------------------
-- STEP 3: Migration = clean the staging data and load it
-- ---------------------------------------------------------------------

-- 3a. Customers: one row per person. TRIM + lower() groups name variants;
--     MIN(TRIM(name)) picks the properly written one; MAX(phone) ignores NULLs.
INSERT INTO customers (name, phone)
SELECT MIN(TRIM(customer_name)), MAX(phone)
FROM staging_orders
GROUP BY LOWER(TRIM(customer_name));

-- 3b. Products: one row per product. MAX(unit_price) ignores NULL prices.
INSERT INTO products (product_name, price)
SELECT product_name, MAX(unit_price)
FROM staging_orders
GROUP BY product_name;

-- Opening stock (given by the store keeper)
UPDATE products SET stock_qty = 60 WHERE product_name = 'A4 Paper Ream';
UPDATE products SET stock_qty = 40 WHERE product_name = 'Blue Pen Box';
UPDATE products SET stock_qty = 80 WHERE product_name = 'Notebook';
UPDATE products SET stock_qty = 10 WHERE product_name = 'Stapler';
UPDATE products SET stock_qty = 70 WHERE product_name = 'File Folder';

-- 3c. Orders: DISTINCT removes the duplicate row; missing price is filled
--     from the products table.
INSERT INTO orders (order_id, order_date, customer_id, product_id, quantity, unit_price)
SELECT DISTINCT
    s.order_ref,
    s.order_date,
    c.customer_id,
    p.product_id,
    s.qty,
    COALESCE(s.unit_price, p.price)
FROM staging_orders s
JOIN customers c ON LOWER(TRIM(s.customer_name)) = LOWER(c.name)
JOIN products  p ON s.product_name = p.product_name;

-- 3d. Invoices: one per order. A missing payment status is treated as Pending.
INSERT INTO invoices (order_id, amount, status)
SELECT DISTINCT
    o.order_id,
    o.quantity * o.unit_price,
    CASE WHEN s.payment_status = 'Paid' THEN 'Paid' ELSE 'Pending' END
FROM orders o
JOIN staging_orders s ON s.order_ref = o.order_id;

-- ---------------------------------------------------------------------
-- STEP 4: Data checks (run these to prove the cleaning worked)
-- ---------------------------------------------------------------------

-- Raw rows vs clean orders (13 raw rows -> 12 orders: 1 duplicate removed)
SELECT (SELECT COUNT(*) FROM staging_orders) AS raw_rows,
       (SELECT COUNT(*) FROM orders)         AS clean_orders,
       (SELECT COUNT(*) FROM customers)      AS customers,
       (SELECT COUNT(*) FROM products)       AS products,
       (SELECT COUNT(*) FROM invoices)       AS invoices;

-- Any customer without a phone? (should return no rows)
SELECT * FROM customers WHERE phone IS NULL;

-- ---------------------------------------------------------------------
-- STEP 5: Business reports (BR-07, BR-08, BR-09)
-- ---------------------------------------------------------------------

-- Report 1: total PAID sales per month
SELECT SUBSTR(o.order_date, 1, 7) AS month,
       SUM(i.amount)              AS paid_sales
FROM invoices i
JOIN orders o ON o.order_id = i.order_id
WHERE i.status = 'Paid'
GROUP BY SUBSTR(o.order_date, 1, 7);

-- Report 2: pending invoices with customer details
SELECT i.invoice_id, o.order_id, c.name, c.phone, i.amount
FROM invoices i
JOIN orders o    ON o.order_id = i.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE i.status = 'Pending'
ORDER BY i.amount DESC;

-- Report 3: remaining stock per product (opening stock minus quantity sold)
SELECT p.product_name,
       p.stock_qty - COALESCE(SUM(o.quantity), 0) AS remaining_stock
FROM products p
LEFT JOIN orders o ON o.product_id = p.product_id
GROUP BY p.product_id
ORDER BY remaining_stock;

-- Report 4: top customers by total purchase amount
SELECT c.name, SUM(i.amount) AS total_purchase
FROM customers c
JOIN orders o   ON o.customer_id = c.customer_id
JOIN invoices i ON i.order_id = o.order_id
GROUP BY c.customer_id
ORDER BY total_purchase DESC;
