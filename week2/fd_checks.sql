-- CIT 408 / Module 2 / Assignment 2.1
-- Functional dependency evidence from the real PostgreSQL stage.work_orders_unf.
-- PostgreSQL results captured by build_fd_proofs.py on 2026-10-08 07:32 UTC.
-- Evidence comments must not be edited to imply a result not observed.
-- The staging table is never updated, preserving the depot-phone conflict.
-- The view excludes empty part-code slots (only populated occurrences remain).
-- There are 2,258 populated lines across 1,100 work orders in this dataset.

CREATE TEMP VIEW fd_part_lines AS
SELECT w.work_order_no, p.part_line_no,
       NULLIF(BTRIM(p.part_code), '') AS part_code,
       NULLIF(BTRIM(p.part_name), '') AS part_name,
       NULLIF(BTRIM(p.part_unit_cost), '') AS part_unit_cost,
       NULLIF(BTRIM(p.part_qty), '') AS part_qty,
       NULLIF(BTRIM(p.supplier_id), '') AS supplier_id,
       NULLIF(BTRIM(p.supplier_name), '') AS supplier_name,
       NULLIF(BTRIM(p.supplier_phone), '') AS supplier_phone
FROM stage.work_orders_unf AS w
CROSS JOIN LATERAL (VALUES
 (1, w.part1_code, w.part1_name, w.part1_unit_cost, w.part1_qty, w.part1_supplier_id, w.part1_supplier_name, w.part1_supplier_phone),
 (2, w.part2_code, w.part2_name, w.part2_unit_cost, w.part2_qty, w.part2_supplier_id, w.part2_supplier_name, w.part2_supplier_phone),
 (3, w.part3_code, w.part3_name, w.part3_unit_cost, w.part3_qty, w.part3_supplier_id, w.part3_supplier_name, w.part3_supplier_phone),
 (4, w.part4_code, w.part4_name, w.part4_unit_cost, w.part4_qty, w.part4_supplier_id, w.part4_supplier_name, w.part4_supplier_phone)
) AS p(part_line_no, part_code, part_name, part_unit_cost, part_qty, supplier_id, supplier_name, supplier_phone)
WHERE NULLIF(BTRIM(p.part_code), '') IS NOT NULL;

-- ================================================================
-- 2NF explanation: FD01-FD07 describe work-order-header attributes
-- determined by work_order_no alone, not the 1NF composite key.
-- Moving them to WORK_ORDER_2NF (single-column PK work_order_no)
-- eliminates these partial dependencies; part rows retain their
-- composite PK (work_order_no, part_line_no).
-- ================================================================
-- 3NF explanation: FD08-FD17 and FD20-FD24 are the intermediate
-- determinants in transitive dependency chains relative to the 1NF
-- key. TRUCK, DEPOT, CERTIFICATION, MECHANIC, PART and SUPPLIER
-- separate these attributes. WORK_ORDER keeps depot_code as an FK:
-- a truck can be serviced at more than one depot.
-- ================================================================

-- === Functional dependency proof queries: FD01-FD24 ===

-- FD01: work_order_no -> open_date [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(open_date::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(open_date::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD01; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD02: work_order_no -> close_date [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(close_date::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(close_date::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD02; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD03: work_order_no -> truck_id [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_id::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_id::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD03; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD04: work_order_no -> depot_code [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_code::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_code::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD04; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD05: work_order_no -> mechanic_id [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_id::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_id::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD05; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD06: work_order_no -> labor_hours [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(labor_hours::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(labor_hours::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD06; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD07: work_order_no -> problem_description [partial]
SELECT work_order_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(problem_description::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(problem_description::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD07; 2026-10-08 07:32 UTC):
--  work_order_no | distinct_values 
-- ---------------+-----------------
-- (0 rows)

-- FD08: truck_id -> truck_vin [transitive chain]
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_vin::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_vin::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD08; 2026-10-08 07:32 UTC):
--  truck_id | distinct_values 
-- ----------+-----------------
-- (0 rows)

-- FD09: truck_id -> truck_make [transitive chain]
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_make::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_make::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD09; 2026-10-08 07:32 UTC):
--  truck_id | distinct_values 
-- ----------+-----------------
-- (0 rows)

-- FD10: truck_id -> truck_model [transitive chain]
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_model::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_model::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD10; 2026-10-08 07:32 UTC):
--  truck_id | distinct_values 
-- ----------+-----------------
-- (0 rows)

-- FD11: truck_id -> truck_year [transitive chain]
SELECT truck_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_year::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(truck_year::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD11; 2026-10-08 07:32 UTC):
--  truck_id | distinct_values 
-- ----------+-----------------
-- (0 rows)

-- FD12: depot_code -> depot_name [transitive chain]
SELECT depot_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_name::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY depot_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_name::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD12; 2026-10-08 07:32 UTC):
--  depot_code | distinct_values 
-- ------------+-----------------
-- (0 rows)

-- FD13: depot_code -> depot_city [transitive chain]
SELECT depot_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_city::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY depot_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_city::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD13; 2026-10-08 07:32 UTC):
--  depot_code | distinct_values 
-- ------------+-----------------
-- (0 rows)

-- FD14: depot_code -> depot_phone [transitive chain; data conflict]
SELECT depot_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_phone::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY depot_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(depot_phone::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD14; 2026-10-08 07:32 UTC):
--  depot_code | distinct_values 
-- ------------+-----------------
--  DEP-FLL    |               2
-- (1 row)

-- FD15: mechanic_id -> mechanic_name [transitive chain]
SELECT mechanic_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_name::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY mechanic_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_name::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD15; 2026-10-08 07:32 UTC):
--  mechanic_id | distinct_values 
-- -------------+-----------------
-- (0 rows)

-- FD16: mechanic_id -> mechanic_cert_level [transitive chain]
SELECT mechanic_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_cert_level::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY mechanic_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(mechanic_cert_level::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD16; 2026-10-08 07:32 UTC):
--  mechanic_id | distinct_values 
-- -------------+-----------------
-- (0 rows)

-- FD17: mechanic_cert_level -> cert_hourly_rate [transitive chain]
SELECT mechanic_cert_level, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(cert_hourly_rate::text), ''), '<NULL>')) AS distinct_values
FROM stage.work_orders_unf
GROUP BY mechanic_cert_level
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(cert_hourly_rate::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD17; 2026-10-08 07:32 UTC):
--  mechanic_cert_level | distinct_values 
-- ---------------------+-----------------
-- (0 rows)

-- FD18: work_order_no, part_line_no -> part_code [full; see minimality checks]
SELECT work_order_no, part_line_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_code::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY work_order_no, part_line_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_code::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD18; 2026-10-08 07:32 UTC):
--  work_order_no | part_line_no | distinct_values 
-- ---------------+--------------+-----------------
-- (0 rows)

-- FD19: work_order_no, part_line_no -> part_qty [full; see minimality checks]
SELECT work_order_no, part_line_no, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_qty::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY work_order_no, part_line_no
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_qty::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD19; 2026-10-08 07:32 UTC):
--  work_order_no | part_line_no | distinct_values 
-- ---------------+--------------+-----------------
-- (0 rows)

-- FD20: part_code -> part_name [transitive chain]
SELECT part_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_name::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY part_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_name::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD20; 2026-10-08 07:32 UTC):
--  part_code | distinct_values 
-- -----------+-----------------
-- (0 rows)

-- FD21: part_code -> part_unit_cost [transitive chain]
SELECT part_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_unit_cost::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY part_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(part_unit_cost::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD21; 2026-10-08 07:32 UTC):
--  part_code | distinct_values 
-- -----------+-----------------
-- (0 rows)

-- FD22: part_code -> supplier_id [transitive chain]
SELECT part_code, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_id::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY part_code
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_id::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD22; 2026-10-08 07:32 UTC):
--  part_code | distinct_values 
-- -----------+-----------------
-- (0 rows)

-- FD23: supplier_id -> supplier_name [transitive chain]
SELECT supplier_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_name::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY supplier_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_name::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD23; 2026-10-08 07:32 UTC):
--  supplier_id | distinct_values 
-- -------------+-----------------
-- (0 rows)

-- FD24: supplier_id -> supplier_phone [transitive chain]
SELECT supplier_id, COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_phone::text), ''), '<NULL>')) AS distinct_values
FROM fd_part_lines
GROUP BY supplier_id
HAVING COUNT(DISTINCT COALESCE(NULLIF(BTRIM(supplier_phone::text), ''), '<NULL>')) > 1;
-- Actual PostgreSQL output (FD24; 2026-10-08 07:32 UTC):
--  supplier_id | distinct_values 
-- -------------+-----------------
-- (0 rows)

-- === 1NF key and populated part slot checks ===

-- KEY_UNIQUENESS: A 1NF key cannot repeat.
SELECT work_order_no, part_line_no, COUNT(*) AS occurrences
FROM fd_part_lines
GROUP BY work_order_no, part_line_no
HAVING COUNT(*) > 1;
-- Actual PostgreSQL output (KEY_UNIQUENESS; 2026-10-08 07:32 UTC):
--  work_order_no | part_line_no | occurrences 
-- ---------------+--------------+-------------
-- (0 rows)

-- KEY_NULLS: Both components of the 1NF composite key must be non-NULL.
SELECT
  COUNT(*) AS populated_lines,
  COUNT(*) FILTER (WHERE work_order_no IS NULL OR part_line_no IS NULL) AS null_key_components
FROM fd_part_lines;
-- Actual PostgreSQL output (KEY_NULLS; 2026-10-08 07:32 UTC):
--  populated_lines | null_key_components 
-- -----------------+---------------------
--             2258 |                   0
-- (1 row)

-- PART_SLOTS: Confirms only numbered slots 1-4 are used; totals should sum to 2,258.
SELECT part_line_no, COUNT(*) AS populated_lines
FROM fd_part_lines
GROUP BY part_line_no
ORDER BY part_line_no;
-- Actual PostgreSQL output (PART_SLOTS; 2026-10-08 07:32 UTC):
--  part_line_no | populated_lines 
-- --------------+-----------------
--             1 |            1100
--             2 |             714
--             3 |             330
--             4 |             114
-- (4 rows)

-- === Depot telephone conflict and resolution rule ===

-- DEPOT_PHONE_COUNTS: Frequency evidence supporting a PROVISIONAL canonical-phone rule.
SELECT depot_code, depot_phone, COUNT(*) AS work_order_count
FROM stage.work_orders_unf
WHERE depot_code = 'DEP-FLL'
GROUP BY depot_code, depot_phone
ORDER BY depot_phone;
-- Actual PostgreSQL output (DEPOT_PHONE_COUNTS; 2026-10-08 07:32 UTC):
--  depot_code |  depot_phone   | work_order_count 
-- ------------+----------------+------------------
--  DEP-FLL    | (954) 555-0118 |              266
--  DEP-FLL    | (954) 555-0181 |                2
-- (2 rows)

-- DEPOT_AFFECTED: Lists anomalous work orders; verify the phone against the depot master record.
SELECT work_order_no, depot_code, depot_phone
FROM stage.work_orders_unf
WHERE depot_code = 'DEP-FLL' AND depot_phone = '(954) 555-0181'
ORDER BY work_order_no;
-- Actual PostgreSQL output (DEPOT_AFFECTED; 2026-10-08 07:32 UTC):
--  work_order_no | depot_code |  depot_phone   
-- ---------------+------------+----------------
--  WO-50041      | DEP-FLL    | (954) 555-0181
--  WO-50047      | DEP-FLL    | (954) 555-0181
-- (2 rows)
-- Resolution policy: The 266-record value (954) 555-0118 is the
-- PROVISIONAL canonical DEP-FLL phone, not independently established
-- as the official number. Flag WO-50041 and WO-50047 (0181) for
-- maintenance-team verification against the official depot contact
-- record. Preserve the raw staging data without alteration. After
-- verification, DEPOT will store exactly one confirmed phone per code.

-- === FULL-dependency minimality counterexamples ===

-- QTY_BY_ORDER: Counterexamples to work_order_no alone determining part_qty (FD19 minimality).
SELECT work_order_no, COUNT(DISTINCT part_qty) AS quantity_variants
FROM fd_part_lines
GROUP BY work_order_no
HAVING COUNT(DISTINCT part_qty) > 1
ORDER BY work_order_no LIMIT 10;
-- Actual PostgreSQL output (QTY_BY_ORDER; 2026-10-08 07:32 UTC):
--  work_order_no | quantity_variants 
-- ---------------+-------------------
--  WO-50001      |                 2
--  WO-50003      |                 2
--  WO-50005      |                 2
--  WO-50006      |                 2
--  WO-50007      |                 3
--  WO-50008      |                 2
--  WO-50009      |                 2
--  WO-50012      |                 2
--  WO-50014      |                 4
--  WO-50015      |                 3
-- (10 rows)
-- Interpretation: Listed counterexamples show work_order_no
-- alone does not determine the value on all part lines.

-- QTY_BY_SLOT: Counterexamples to part_line_no alone determining part_qty (FD19 minimality).
SELECT part_line_no, COUNT(DISTINCT part_qty) AS quantity_variants
FROM fd_part_lines
GROUP BY part_line_no
HAVING COUNT(DISTINCT part_qty) > 1
ORDER BY part_line_no;
-- Actual PostgreSQL output (QTY_BY_SLOT; 2026-10-08 07:32 UTC):
--  part_line_no | quantity_variants 
-- --------------+-------------------
--             1 |                 4
--             2 |                 4
--             3 |                 4
--             4 |                 4
-- (4 rows)
-- Interpretation: Multiple distinct values for each slot number
-- mean the slot alone is not a determinant.

-- CODE_BY_ORDER: Counterexamples to work_order_no alone determining part_code (FD18 minimality).
SELECT work_order_no, COUNT(DISTINCT part_code) AS part_variants
FROM fd_part_lines
GROUP BY work_order_no
HAVING COUNT(DISTINCT part_code) > 1
ORDER BY work_order_no LIMIT 10;
-- Actual PostgreSQL output (CODE_BY_ORDER; 2026-10-08 07:32 UTC):
--  work_order_no | part_variants 
-- ---------------+---------------
--  WO-50001      |             2
--  WO-50002      |             2
--  WO-50003      |             2
--  WO-50005      |             2
--  WO-50006      |             3
--  WO-50007      |             4
--  WO-50008      |             3
--  WO-50009      |             2
--  WO-50010      |             2
--  WO-50012      |             2
-- (10 rows)
-- Interpretation: Listed counterexamples show work_order_no
-- alone does not determine the value on all part lines.

-- CODE_BY_SLOT: Counterexamples to part_line_no alone determining part_code (FD18 minimality).
SELECT part_line_no, COUNT(DISTINCT part_code) AS part_variants
FROM fd_part_lines
GROUP BY part_line_no
HAVING COUNT(DISTINCT part_code) > 1
ORDER BY part_line_no;
-- Actual PostgreSQL output (CODE_BY_SLOT; 2026-10-08 07:32 UTC):
--  part_line_no | part_variants 
-- --------------+---------------
--             1 |            24
--             2 |            24
--             3 |            24
--             4 |            24
-- (4 rows)
-- Interpretation: Multiple distinct values for each slot number
-- mean the slot alone is not a determinant.

-- === Negative test: truck_id does NOT determine depot_code ===

-- TRUCK_DEPOT: If rows appear, truck_id does not determine depot_code; depot belongs on WORK_ORDER.
SELECT truck_id, COUNT(DISTINCT depot_code) AS depots
FROM stage.work_orders_unf
GROUP BY truck_id
HAVING COUNT(DISTINCT depot_code) > 1
ORDER BY truck_id;
-- Actual PostgreSQL output (TRUCK_DEPOT; 2026-10-08 07:32 UTC):
--  truck_id | depots 
-- ----------+--------
--  TRK-201  |      4
--  TRK-202  |      4
--  TRK-203  |      4
--  TRK-204  |      4
--  TRK-205  |      4
--  TRK-206  |      4
--  TRK-207  |      4
--  TRK-208  |      4
--  TRK-209  |      4
--  TRK-210  |      4
--  TRK-211  |      4
--  TRK-212  |      4
--  TRK-213  |      4
--  TRK-214  |      4
--  TRK-215  |      4
--  TRK-216  |      4
--  TRK-217  |      4
--  TRK-218  |      4
--  TRK-219  |      4
--  TRK-220  |      4
--  TRK-221  |      4
--  TRK-222  |      4
--  TRK-223  |      4
--  TRK-224  |      4
--  TRK-225  |      4
--  TRK-226  |      4
--  TRK-227  |      4
--  TRK-228  |      4
--  TRK-229  |      4
--  TRK-230  |      4
--  TRK-231  |      4
--  TRK-232  |      4
--  TRK-233  |      4
--  TRK-234  |      4
--  TRK-235  |      4
--  TRK-236  |      4
--  TRK-237  |      4
--  TRK-238  |      4
--  TRK-239  |      4
--  TRK-240  |      4
-- (40 rows)
-- Interpretation: Nonzero results disprove truck_id -> depot_code.
-- Keep depot_code on WORK_ORDER, not permanently on TRUCK.

