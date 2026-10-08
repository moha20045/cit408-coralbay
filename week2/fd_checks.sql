-- CIT 408 Module 2 / Assignment 2.1
-- Functional dependency checks against stage.work_orders_unf
-- CSV-derived expected results are written below each query.
-- Compare those predictions to the REAL PostgreSQL output before submitting.
-- Keep the original staging table unchanged to preserve the conflicting data.

CREATE TEMP VIEW fd_part_lines AS
SELECT w.work_order_no, p.part_line_no,
       NULLIF(BTRIM(p.part_code), '') AS part_code,
       NULLIF(BTRIM(p.part_name), '') AS part_name,
       NULLIF(BTRIM(p.part_unit_cost), '') AS part_unit_cost,
       NULLIF(BTRIM(p.part_qty), '') AS part_qty,
       NULLIF(BTRIM(p.supplier_id), '') AS supplier_id,
       NULLIF(BTRIM(p.supplier_name), '') AS supplier_name,
       NULLIF(BTRIM(p.supplier_phone), '') AS supplier_phone
FROM stage.work_orders_unf w
CROSS JOIN LATERAL (VALUES
 (1, w.part1_code, w.part1_name, w.part1_unit_cost, w.part1_qty, w.part1_supplier_id, w.part1_supplier_name, w.part1_supplier_phone),
 (2, w.part2_code, w.part2_name, w.part2_unit_cost, w.part2_qty, w.part2_supplier_id, w.part2_supplier_name, w.part2_supplier_phone),
 (3, w.part3_code, w.part3_name, w.part3_unit_cost, w.part3_qty, w.part3_supplier_id, w.part3_supplier_name, w.part3_supplier_phone),
 (4, w.part4_code, w.part4_name, w.part4_unit_cost, w.part4_qty, w.part4_supplier_id, w.part4_supplier_name, w.part4_supplier_phone)
) AS p(part_line_no, part_code, part_name, part_unit_cost, part_qty, supplier_id, supplier_name, supplier_phone)
WHERE NULLIF(BTRIM(p.part_code), '') IS NOT NULL;

-- FD01: work_order_no -> open_date
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(open_date::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(open_date::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD02: work_order_no -> close_date
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(close_date::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(close_date::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD03: work_order_no -> truck_id
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_id::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_id::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD04: work_order_no -> depot_code
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_code::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_code::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD05: work_order_no -> mechanic_id
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_id::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_id::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD06: work_order_no -> labor_hours
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(labor_hours::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(labor_hours::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD07: work_order_no -> problem_description
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(problem_description::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(problem_description::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD08: truck_id -> truck_vin
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_vin::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_vin::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD09: truck_id -> truck_make
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_make::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_make::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD10: truck_id -> truck_model
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_model::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_model::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD11: truck_id -> truck_year
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_year::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_year::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD12: depot_code -> depot_name
SELECT depot_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_name::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY depot_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_name::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD13: depot_code -> depot_city
SELECT depot_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_city::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY depot_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_city::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD14: depot_code -> depot_phone
SELECT depot_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_phone::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY depot_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_phone::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 1 violating group(s).
-- DEP-FLL | 2 distinct values

-- FD15: mechanic_id -> mechanic_name
SELECT mechanic_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_name::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY mechanic_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_name::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD16: mechanic_id -> mechanic_cert_level
SELECT mechanic_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_cert_level::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY mechanic_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_cert_level::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD17: mechanic_cert_level -> cert_hourly_rate
SELECT mechanic_cert_level, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(cert_hourly_rate::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY mechanic_cert_level
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(cert_hourly_rate::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD18: work_order_no, part_line_no -> part_code
SELECT work_order_no, part_line_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_code::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY work_order_no, part_line_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_code::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD19: work_order_no, part_line_no -> part_qty
SELECT work_order_no, part_line_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_qty::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY work_order_no, part_line_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_qty::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD20: part_code -> part_name
SELECT part_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_name::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY part_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_name::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD21: part_code -> part_unit_cost
SELECT part_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_unit_cost::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY part_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_unit_cost::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD22: part_code -> supplier_id
SELECT part_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_id::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY part_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_id::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD23: supplier_id -> supplier_name
SELECT supplier_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_name::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY supplier_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_name::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- FD24: supplier_id -> supplier_phone
SELECT supplier_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_phone::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY supplier_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_phone::text), ''), '<NULL>')) > 1;
-- CSV precheck expected: 0 violating group(s).
-- Expected PostgreSQL display: (0 rows)

-- Verify 1NF key uniqueness and non-NULL key attributes.
SELECT work_order_no, part_line_no, COUNT(*) AS occurrences
FROM fd_part_lines
GROUP BY work_order_no, part_line_no
HAVING COUNT(*) > 1;
-- Previously observed in PostgreSQL: (0 rows).

-- Investigate both phone numbers and identify affected work orders.
SELECT depot_code, depot_phone, COUNT(*) AS work_order_count,
       STRING_AGG(work_order_no, ', ' ORDER BY work_order_no) AS affected_orders
FROM stage.work_orders_unf
WHERE depot_code = 'DEP-FLL'
GROUP BY depot_code, depot_phone
ORDER BY depot_phone;
-- Previously observed:
-- DEP-FLL | (954) 555-0118 | 266 work orders
-- DEP-FLL | (954) 555-0181 | 2 work orders: WO-50041, WO-50047

-- Extra minimality checks for the claimed FULL dependencies:
-- If either determinant component is unnecessary, the proposed FD is not full.
SELECT work_order_no, COUNT(DISTINCT part_qty) AS quantity_variants
FROM fd_part_lines GROUP BY work_order_no
HAVING COUNT(DISTINCT part_qty) > 1 LIMIT 10;
SELECT part_line_no, COUNT(DISTINCT part_qty) AS quantity_variants
FROM fd_part_lines GROUP BY part_line_no
HAVING COUNT(DISTINCT part_qty) > 1;

SELECT work_order_no, COUNT(DISTINCT part_code) AS part_variants
FROM fd_part_lines GROUP BY work_order_no
HAVING COUNT(DISTINCT part_code) > 1 LIMIT 10;
SELECT part_line_no, COUNT(DISTINCT part_code) AS part_variants
FROM fd_part_lines GROUP BY part_line_no
HAVING COUNT(DISTINCT part_code) > 1;

-- Review whether truck_id -> depot_code also holds, and if so whether it is a BUSINESS rule.
-- Apparent dependencies in a finite sample are not automatically permanent policies.
SELECT truck_id, COUNT(DISTINCT depot_code) AS depots
FROM stage.work_orders_unf GROUP BY truck_id
HAVING COUNT(DISTINCT depot_code) > 1;

