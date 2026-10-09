# CIT 408 · Module 2 · Assignment 2.3 — Superstore 3NF design

## Source, staging and load

The original 21-column Superstore CSV was loaded into `public.staging\_superstore` in the PostgreSQL 18 `superstore` database. The first UTF-8 import failed on byte `0xA0` (line 13); selecting `WIN1252` in pgAdmin Import/Export succeeded. `SELECT COUNT(\*)` returned **9,994** records. Raw staging fields were intentionally stored as `TEXT`; typed fields are enforced in the final tables.

## First normal form and line key

The source records are individual order lines, with a single value per field. The `row\_id` uniqueness query found 9,994 distinct values across 9,994 records; the duplicate query returned zero groups; missing/blank `row\_id` count was zero. `row\_id` is therefore the order-line primary key. There are only **5,009** distinct order IDs: `order\_id` cannot be the line key, because an order contains multiple lines.

## Functional dependency tests

Queries and exact SQL used to investigate these relationships are in `fd\_checks.sql`. `GROUP BY ... HAVING COUNT(DISTINCT ...) > 1` returns conflicting determinants. `COUNT(DISTINCT ...)` ignores SQL nulls, so separate missing-value checks are also included.

|Candidate dependency|Observed dataset evidence|Design decision|
|-|-|-|
|`customer\_id → customer\_name`|0 conflicting IDs|Customer name stored in `customers`|
|`customer\_id → segment`|0 conflicts|Segment stored in `customers`|
|`order\_id → order\_date, ship\_date, ship\_mode, customer\_id`|0 conflicting orders in combined check|Stored in `orders`|
|`order\_id → country, city, state, postal\_code, region`|0 conflicting orders in combined check|`orders` references `locations`|
|`product\_id → product\_name`|**32** product IDs identify two different names each|Do **not** make source `product\_id` unique|
|`(product\_id, product\_name) → category, sub\_category`|0 conflicts|Use unique pair and a surrogate `product\_key`|
|`postal\_code → city`|Does **not** hold: `92024` maps to Encinitas and San Diego (California)|`postal\_code` is not a location key|
|`state → region`|0 conflicts|`states` contains one region per state|
|`sub\_category → category`|0 conflicts|`subcategories` references `categories`|

In particular, the source had **1,862 distinct source product IDs**, but **1,894 distinct `(product\_id,product\_name)` records**. The pair preserves the 32 collisions without losing sales. `92024` was shared by Encinitas and San Diego; the location key uses the full `(country,state,city,postal\_code)` tuple, with an internal `location\_id` used for foreign keys. Exactly **632** such tuples were observed. The lack of conflicting states for `92024` does not establish that all postal codes must identify exactly one state in other datasets.

## 2NF

A partial dependency requires a composite candidate key. The `order\_lines` key is a single `row\_id`, and its numeric sales-line measures relate to that line. Order attributes, customer details, product descriptions and locations were split into tables to avoid repeated attributes in a single denormalized row. The product entity uses a single surrogate primary key but retains `UNIQUE (product\_id, product\_name)` as an alternate candidate key.

## 3NF

The decomposition puts non-key information with its determinant. Customer name/segment depend on the customer; order-level information depends on the order; `region` depends on `state`; category depends on subcategory; product names and subcategory references live with distinct product records. An order line stores only its `row\_id`, `order\_id`, `product\_key`, and its sales measures. Referential integrity is enforced by seven foreign keys.

## Final normalized tables

**All listed foreign-key fields are `NOT NULL`.** `IDENTITY` columns use database-generated surrogate IDs.

|Table|Columns and types|Primary key|Foreign keys and other constraints|
|-|-|-|-|
|`customers`|`customer\_id TEXT`, `customer\_name TEXT`, `segment TEXT`|`customer\_id`|name, segment NOT NULL|
|`states`|`state TEXT`, `region TEXT`|`state`|region NOT NULL|
|`locations`|`location\_id BIGINT IDENTITY`, `country TEXT`, `state TEXT`, `city TEXT`, `postal\_code TEXT`|`location\_id`|`state → states(state)`; unique `(country,state,city,postal\_code)`|
|`orders`|`order\_id TEXT`, `order\_date DATE`, `ship\_date DATE`, `ship\_mode TEXT`, `customer\_id TEXT`, `location\_id BIGINT`|`order\_id`|`customer\_id → customers(customer\_id)`; `location\_id → locations(location\_id)`; CHECK `ship\_date >= order\_date`|
|`categories`|`category\_id BIGINT IDENTITY`, `category\_name TEXT`|`category\_id`|category\_name UNIQUE|
|`subcategories`|`subcategory\_id BIGINT IDENTITY`, `subcategory\_name TEXT`, `category\_id BIGINT`|`subcategory\_id`|`category\_id → categories(category\_id)`; subcategory\_name UNIQUE|
|`products`|`product\_key BIGINT IDENTITY`, `product\_id TEXT`, `product\_name TEXT`, `subcategory\_id BIGINT`|`product\_key`|`subcategory\_id → subcategories(subcategory\_id)`; unique `(product\_id,product\_name)`|
|`order\_lines`|`row\_id INTEGER`, `order\_id TEXT`, `product\_key BIGINT`, `sales NUMERIC(18,6)`, `quantity INTEGER`, `discount NUMERIC(7,6)`, `profit NUMERIC(18,6)`|`row\_id`|`order\_id → orders(order\_id)`; `product\_key → products(product\_key)`; CHECK `quantity > 0`, CHECK `discount BETWEEN 0 AND 1`|

**Staging**: `staging\_superstore` contains all 21 original CSV fields as TEXT; it is intentionally not part of the normalized ERD.

## Loading and validation results

Source missing-value checks reported zero missing order IDs, customer IDs, product IDs, product names, order dates, sales, quantities, cities, states, regions, subcategories, ship dates, ship modes, discounts, profits and postal codes. No orders had ship dates earlier than their order dates in the observed test.

|Table|Observed rows|
|-|-:|
|`categories`|3|
|`customers`|793|
|`locations`|632|
|`order\_lines`|9,994|
|`orders`|5,009|
|`products`|1,894|
|`staging\_superstore`|9,994|
|`states`|49|
|`subcategories`|17|

A join through all eight normalized tables produced **9,994** lines, matching staging. The staging sales sum was **2,297,200.8603**, matching the normalized join sum **2,297,200.860300**. A test insert using `product\_key = -999999` was rejected with PostgreSQL **SQLSTATE 23503**, demonstrating enforced foreign-key integrity. The final ERD shows the seven foreign-key relationships.

## Reproducibility

1. Execute the database creation and staging DDL from `load.sql`, observing the instruction to connect to the correct database; import the actual course CSV with `WIN1252` encoding.
2. Run `fd\_checks.sql` and record results before deciding keys (results here describe the supplied dataset).
3. Execute `create\_tables.sql` once on an empty normalized schema.
4. Execute `load\_data.sql` once.
5. Execute `verify.sql`, saving pgAdmin results and the expected `23503` error screenshot. The failing statement must be run separately; `ROLLBACK` follows it.

**Scope:** The dependencies were tested against this file. They are not universal business rules for all retail records. No source rows were merged or deleted.

