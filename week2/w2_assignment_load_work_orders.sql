-- CIT 408 Module 2 - replacement loader for Coral Bay work orders
-- Reconstructed from the provided CSV; not the instructor's original script.
-- All raw fields stay TEXT to preserve the unnormalized source values.
\set ON_ERROR_STOP on
CREATE SCHEMA IF NOT EXISTS stage;
CREATE TABLE IF NOT EXISTS stage.work_orders_unf (
    "work_order_no" TEXT,
    "open_date" TEXT,
    "close_date" TEXT,
    "truck_id" TEXT,
    "truck_vin" TEXT,
    "truck_make" TEXT,
    "truck_model" TEXT,
    "truck_year" TEXT,
    "depot_code" TEXT,
    "depot_name" TEXT,
    "depot_city" TEXT,
    "depot_phone" TEXT,
    "mechanic_id" TEXT,
    "mechanic_name" TEXT,
    "mechanic_cert_level" TEXT,
    "cert_hourly_rate" TEXT,
    "labor_hours" TEXT,
    "problem_description" TEXT,
    "part1_code" TEXT,
    "part1_name" TEXT,
    "part1_unit_cost" TEXT,
    "part1_qty" TEXT,
    "part1_supplier_id" TEXT,
    "part1_supplier_name" TEXT,
    "part1_supplier_phone" TEXT,
    "part2_code" TEXT,
    "part2_name" TEXT,
    "part2_unit_cost" TEXT,
    "part2_qty" TEXT,
    "part2_supplier_id" TEXT,
    "part2_supplier_name" TEXT,
    "part2_supplier_phone" TEXT,
    "part3_code" TEXT,
    "part3_name" TEXT,
    "part3_unit_cost" TEXT,
    "part3_qty" TEXT,
    "part3_supplier_id" TEXT,
    "part3_supplier_name" TEXT,
    "part3_supplier_phone" TEXT,
    "part4_code" TEXT,
    "part4_name" TEXT,
    "part4_unit_cost" TEXT,
    "part4_qty" TEXT,
    "part4_supplier_id" TEXT,
    "part4_supplier_name" TEXT,
    "part4_supplier_phone" TEXT
);
BEGIN;
TRUNCATE TABLE stage.work_orders_unf;
\copy stage.work_orders_unf ("work_order_no", "open_date", "close_date", "truck_id", "truck_vin", "truck_make", "truck_model", "truck_year", "depot_code", "depot_name", "depot_city", "depot_phone", "mechanic_id", "mechanic_name", "mechanic_cert_level", "cert_hourly_rate", "labor_hours", "problem_description", "part1_code", "part1_name", "part1_unit_cost", "part1_qty", "part1_supplier_id", "part1_supplier_name", "part1_supplier_phone", "part2_code", "part2_name", "part2_unit_cost", "part2_qty", "part2_supplier_id", "part2_supplier_name", "part2_supplier_phone", "part3_code", "part3_name", "part3_unit_cost", "part3_qty", "part3_supplier_id", "part3_supplier_name", "part3_supplier_phone", "part4_code", "part4_name", "part4_unit_cost", "part4_qty", "part4_supplier_id", "part4_supplier_name", "part4_supplier_phone") FROM '/tmp/coralbay_work_orders_unf.csv' WITH (FORMAT csv, HEADER true, NULL '');
DO $$
BEGIN
  IF (SELECT count(*) FROM stage.work_orders_unf) <> 1100 THEN
    RAISE EXCEPTION 'Expected 1100 work orders, found %', (SELECT count(*) FROM stage.work_orders_unf);
  END IF;
END $$;
COMMIT;
SELECT count(*) AS loaded_count FROM stage.work_orders_unf \gset
\echo :loaded_count
