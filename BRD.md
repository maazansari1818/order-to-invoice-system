# Business Requirement Document (BRD): Order-to-Invoice System

**Case study business:** Sharma Stationery, a small retail and wholesale stationery shop (sample business for this case study)
**Prepared by:** Maaz Ansari
**Version:** 1.0

## 1. Purpose

Sharma Stationery records orders and invoices in separate Excel sheets, which causes duplicate entries, missing prices and unpaid invoices going unnoticed. This document defines the requirements for one database-backed order-to-invoice process that removes these problems.

## 2. Scope

**In scope:** customer records, product records with stock, order entry, automatic invoice creation, payment status tracking, and basic sales and stock reports.

**Out of scope:** online ordering, GST filing, delivery tracking and accounting integration.

## 3. Stakeholders

| Role | Responsibility |
| --- | --- |
| Shop owner | Approves the process, reviews sales and pending-payment reports |
| Sales staff | Enters customer orders and updates payment status |
| Store keeper | Checks and updates stock levels |
| Customer | Places orders and pays invoices |

## 4. Current Process (As-Is)

1. Customer places an order by phone or in the shop.
2. Staff notes the order in an Excel sheet.
3. Staff manually checks stock with the store keeper.
4. Staff types an invoice in a separate Excel sheet.
5. Payment is collected, and the status is updated only sometimes.

**Problems found:** duplicate order rows, customer names typed in different formats, missing prices and phone numbers, and no clear list of pending invoices.

## 5. Proposed Process (To-Be)

1. Staff searches for the customer. If new, a customer record is created once.
2. Staff selects the product and quantity. Price and stock come from the product table.
3. The system saves the order, and an invoice is created automatically with the amount calculated as quantity × unit price.
4. Payment status is set to Pending or Paid.
5. The owner runs reports for monthly sales, pending invoices and low stock.

## 6. Business Requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| BR-01 | Each customer is stored once, with a standard name format and phone number | High |
| BR-02 | Each product has one standard name, one price and a stock quantity | High |
| BR-03 | Every order links to one customer and one product | High |
| BR-04 | An invoice is created for every order, with amount = quantity × unit price | High |
| BR-05 | Payment status is recorded as Paid or Pending for every invoice | High |
| BR-06 | Duplicate orders are not allowed | High |
| BR-07 | The owner can view total paid sales per month | Medium |
| BR-08 | The owner can view all pending invoices with customer details | Medium |
| BR-09 | The store keeper can view remaining stock per product | Medium |

## 7. Data Requirements

| Table | Key fields |
| --- | --- |
| customers | customer_id, name, phone |
| products | product_id, product_name, price, stock_qty |
| orders | order_id, order_date, customer_id, product_id, quantity, unit_price |
| invoices | invoice_id, order_id, amount, status |

Existing Excel data is cleaned (duplicates removed, names standardised, missing prices filled from the product list) and migrated into these tables.

## 8. Assumptions and Constraints

- Each order contains one product line, to keep the case study simple.
- All prices are in INR and include tax.
- The database is SQL-based and used by one shop.

## 9. Success Criteria

- Zero duplicate orders after migration.
- Every invoice has an amount and a payment status.
- The owner gets the pending-invoice list with one query instead of checking sheets by hand.
