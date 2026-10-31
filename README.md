# Order-to-Invoice System for a Small Business (Case Study)

A business analysis case study for a small stationery shop (Sharma Stationery, a sample business). It covers the full flow: documenting the process, writing a Business Requirement Document (BRD), cleaning messy Excel data, and migrating it into a MySQL database with reports.

## The problem

The shop tracked orders and invoices in Excel. This caused:

- Duplicate order rows
- Customer names typed in different formats (`rahul patil`, `Rahul Patil`)
- Missing phone numbers, prices and payment status
- No easy way to see which invoices were still unpaid

## What I did

1. **Documented the process** and wrote a [BRD](BRD.md) covering scope, stakeholders, as-is and to-be process, 9 business requirements and success criteria.
2. **Designed a relational database** with 4 tables: `customers`, `products`, `orders`, `invoices`.
3. **Cleaned and migrated the data** from a messy staging table (13 raw rows) into the clean tables (12 orders, 6 customers, 5 products, 12 invoices).
4. **Wrote SQL reports** for monthly paid sales, pending invoices, remaining stock and top customers.

## Data cleaning steps

| Problem in raw data | How it was fixed |
| --- | --- |
| 1 duplicate order row | `SELECT DISTINCT` and a primary key on `order_id` |
| Names in different formats | `TRIM` and `LOWER` to group, `MIN(TRIM(name))` to keep the proper form |
| Missing phone number | `MAX(phone)` picks the available number for the customer |
| Missing unit price | Filled from the `products` table using `COALESCE` |
| Missing payment status | Treated as `Pending` using `CASE` |

## Database design

| Table | Key columns |
| --- | --- |
| customers | customer_id, name, phone |
| products | product_id, product_name, price, stock_qty |
| orders | order_id, order_date, customer_id, product_id, quantity, unit_price |
| invoices | invoice_id, order_id, amount, status |

## How to run

1. Install MySQL and MySQL Workbench.
2. Open `order_to_invoice.sql` in Workbench.
3. Run the whole script. It creates the database `sharma_stationery`, loads the messy data, cleans it and runs the reports.

## Sample results

- Paid sales for October 2026: 5,725
- Pending invoices: 4, worth 4,555 in total (largest: Vikram More, 2,080)
- Lowest remaining stock: Stapler (7 left)
- Top customer by purchase amount: Vikram More (3,205)

## Skills shown

SQL, MySQL, database design, data cleaning, data migration, business requirement documentation (BRD), business process analysis, workflow design.

## Files

- `BRD.md`: Business Requirement Document
- `order_to_invoice.sql`: schema, messy data, migration and reports
