
# CIT 408 - Module 2, Assignment 2.1
## Coral Bay Fleet Work Orders
### Normalization Design: 1NF, 2NF, and 3NF

## 1. Introduction

The original work orders spreadsheet contains 1,100
records. Each work order includes information about
the truck, depot, mechanic, and parts used.

The main normalization problem is that parts are stored
in four repeating column groups. The same truck,
depot, mechanic, and supplier details also appear
multiple times.

The purpose of this design is to remove repeating
groups, reduce duplicate information, and prevent
update, insertion, and deletion anomalies.

## 2. First Normal Form (1NF)

The original spreadsheet is not in 1NF because it has
four groups of part columns.

The first step is to unpivot those groups so each
part occurrence becomes a separate row.

Table: WORK_ORDER_PARTS_1NF

Columns:
- work_order_no
- part_line_no
- open_date
- close_date
- truck_id
- truck_vin
- truck_make
- truck_model
- truck_year
- depot_code
- depot_name
- depot_city
- depot_phone
- mechanic_id
- mechanic_name
- mechanic_cert_level
- cert_hourly_rate
- labor_hours
- problem_description
- part_code
- part_name
- part_unit_cost
- part_qty
- supplier_id
- supplier_name
- supplier_phone

Primary key:
(work_order_no, part_line_no)

Foreign keys:
None in this initial single-table design.

A uniqueness test using GROUP BY and HAVING returned
zero duplicate primary-key combinations.

Every work order has at least one populated part slot,
so all 1,100 work orders can be represented.

The table is in 1NF, but it still contains partial and
transitive dependencies.

## 3. Second Normal Form (2NF)

The second step removes partial dependencies.

Work-order information depends on work_order_no,
not on the complete composite key.

Part-line information depends on the combination of
work_order_no and part_line_no.

Table: WORK_ORDER_2NF

Columns:
- work_order_no (PK)
- open_date
- close_date
- truck_id
- truck_vin
- truck_make
- truck_model
- truck_year
- depot_code
- depot_name
- depot_city
- depot_phone
- mechanic_id
- mechanic_name
- mechanic_cert_level
- cert_hourly_rate
- labor_hours
- problem_description

Primary key: work_order_no
Foreign keys: None at this stage.

Table: WORK_ORDER_PART_2NF

Columns:
- work_order_no (PK, FK)
- part_line_no (PK)
- part_code
- part_name
- part_unit_cost
- part_qty
- supplier_id
- supplier_name
- supplier_phone

Primary key:
(work_order_no, part_line_no)

Foreign key:
work_order_no references WORK_ORDER_2NF(work_order_no).

The partial dependencies have been removed.

However, these tables still contain transitive
dependencies.

For example:
truck_id -> truck_vin
mechanic_id -> mechanic_cert_level
mechanic_cert_level -> cert_hourly_rate
part_code -> supplier_id
supplier_id -> supplier_phone

These relationships must be addressed in 3NF.

## 4. Third Normal Form (3NF)

The final step removes transitive dependencies.

### Table 1: TRUCK

Columns:
- truck_id (PK)
- truck_vin
- truck_make
- truck_model
- truck_year

Primary key: truck_id
Foreign keys: None

### Table 2: DEPOT

Columns:
- depot_code (PK)
- depot_name
- depot_city
- depot_phone

Primary key: depot_code
Foreign keys: None

### Table 3: CERTIFICATION

Columns:
- mechanic_cert_level (PK)
- cert_hourly_rate

Primary key: mechanic_cert_level
Foreign keys: None

### Table 4: MECHANIC

Columns:
- mechanic_id (PK)
- mechanic_name
- mechanic_cert_level (FK)

Primary key: mechanic_id

Foreign key:
mechanic_cert_level references
CERTIFICATION(mechanic_cert_level).

### Table 5: SUPPLIER

Columns:
- supplier_id (PK)
- supplier_name
- supplier_phone

Primary key: supplier_id
Foreign keys: None

### Table 6: PART

Columns:
- part_code (PK)
- part_name
- part_unit_cost
- supplier_id (FK)

Primary key: part_code

Foreign key:
supplier_id references SUPPLIER(supplier_id).

### Table 7: WORK_ORDER

Columns:
- work_order_no (PK)
- open_date
- close_date
- truck_id (FK)
- depot_code (FK)
- mechanic_id (FK)
- labor_hours
- problem_description

Primary key: work_order_no

Foreign keys:
truck_id references TRUCK(truck_id).
depot_code references DEPOT(depot_code).
mechanic_id references MECHANIC(mechanic_id).

### Table 8: WORK_ORDER_PART

Columns:
- work_order_no (PK, FK)
- part_line_no (PK)
- part_code (FK)
- part_qty

Primary key:
(work_order_no, part_line_no)

Foreign keys:
work_order_no references WORK_ORDER(work_order_no).
part_code references PART(part_code).

## 5. Data Conflict

The functional dependency

depot_code -> depot_phone

has one identified conflict.

Depot: DEP-FLL

Phone number A:
(954) 555-0118
Found in 266 work orders.

Phone number B:
(954) 555-0181
Found in 2 work orders.

Affected work orders:
WO-50041
WO-50047

Proposed resolution:

Keep the original CSV unchanged to preserve evidence.

Use (954) 555-0118 provisionally because it appears
in most records. Confirm the number using an
authoritative depot contact record before permanently
correcting the data.

The final DEPOT table must contain only one verified
phone number for each depot code.

## 6. Final Dependency Review

The final design uses eight tables.

Truck attributes depend on truck_id.

Depot attributes depend on depot_code.

Certification rates depend on mechanic_cert_level.

Mechanic names and certification assignments depend
on mechanic_id.

Supplier attributes depend on supplier_id.

Part attributes and the supplier reference depend
on part_code.

Work-order attributes depend on work_order_no.

Part-line attributes depend on the composite key
(work_order_no, part_line_no).

The depot is referenced from WORK_ORDER, not TRUCK,
because the dataset shows that trucks can receive
maintenance at multiple depots.

The proposed design eliminates the identified partial
and transitive dependencies while retaining the
relationships between work orders, trucks, depots,
mechanics, parts, and suppliers.

## 7. Conclusion

The original flat spreadsheet repeats part columns
and descriptive information across work orders.

The 1NF design removes repeating part groups.

The 2NF design separates work-order headers from
individual part lines.

The 3NF design separates truck, depot, mechanic,
certification, part, and supplier details into
their own tables.

This structure reduces duplicated information and
makes the maintenance records easier to update and
manage consistently.
