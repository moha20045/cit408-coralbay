
# CIT 408 - Module 2, Assignment 2.1
## Coral Bay Fleet Work Orders
### Functional Dependency Analysis

## 1. First Normal Form (1NF)

The original CSV contains 1,100 work orders. Parts are
stored in four repeating column groups, from part1_code
through part4_supplier_phone.

These repeating groups violate 1NF. Each part occurrence
should be represented as a separate row.

Proposed composite primary key:
(work_order_no, part_line_no)

The uniqueness query returned zero duplicate keys.

## 2. Partial Dependencies

Relative to the composite 1NF key:

work_order_no -> open_date
work_order_no -> close_date
work_order_no -> truck_id
work_order_no -> depot_code
work_order_no -> mechanic_id
work_order_no -> labor_hours
work_order_no -> problem_description

These are partial dependencies because work_order_no
is only one component of the composite key.

## 3. Full Dependencies

(work_order_no, part_line_no) -> part_code
(work_order_no, part_line_no) -> part_qty

These describe the part assigned to each line and its
quantity. The complete key identifies the part occurrence.

These are the intended full dependencies under the
proposed business model. The uniqueness tests alone
do not establish minimality.

## 4. Transitive Dependencies

Truck:
truck_id -> truck_vin
truck_id -> truck_make
truck_id -> truck_model
truck_id -> truck_year

Depot:
depot_code -> depot_name
depot_code -> depot_city
depot_code -> depot_phone

Mechanic:
mechanic_id -> mechanic_name
mechanic_id -> mechanic_cert_level

Certification:
mechanic_cert_level -> cert_hourly_rate

Part:
part_code -> part_name
part_code -> part_unit_cost
part_code -> supplier_id

Supplier:
supplier_id -> supplier_name
supplier_id -> supplier_phone

These are transitive dependencies relative to the 1NF
key because the descriptive attributes are determined
through other non-key attributes.

The part attributes above refer to the corresponding
part1 through part4 fields after unpivoting.

## 5. Dependency Chains

work_order_no -> truck_id -> truck_vin,
truck_make, truck_model, truck_year

work_order_no -> depot_code -> depot_name,
depot_city, depot_phone

work_order_no -> mechanic_id -> mechanic_name,
mechanic_cert_level -> cert_hourly_rate

(work_order_no, part_line_no) -> part_code ->
supplier_id -> supplier_name, supplier_phone

These chains must be separated properly in 3NF.

## 6. Conflicting Data

Dependency:
depot_code -> depot_phone

Conflicting depot: DEP-FLL

Phone number 1:
(954) 555-0118
Occurrences: 266 work orders

Phone number 2:
(954) 555-0181
Occurrences: 2 work orders

Affected work orders:
WO-50041
WO-50047

The dependency test returned one depot with two
different phone numbers.

Resolution:
Keep the raw CSV unchanged as evidence of the conflict.

Provisionally use (954) 555-0118 because it is the
majority value. Confirm the correct number against
the depot's authoritative contact information before
permanently correcting the data.

## 7. Summary

The 1NF composite key is:
(work_order_no, part_line_no)

The identified partial dependencies will be separated
during 2NF normalization.

The identified transitive dependencies will be separated
during 3NF normalization.

The raw data contains one identified conflicting
depot-phone relationship that requires resolution.
