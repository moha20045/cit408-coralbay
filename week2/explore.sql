
-- Query 1: Count all work orders
SELECT COUNT(*) AS total_work_orders
FROM stage.work_orders_unf;

-- Query 2: Count unique trucks, depots, and mechanics
SELECT
    COUNT(DISTINCT truck_id) AS trucks,
    COUNT(DISTINCT depot_code) AS depots,
    COUNT(DISTINCT mechanic_id) AS mechanics
FROM stage.work_orders_unf;

-- Query 3: Display five sample work orders
SELECT
    work_order_no,
    open_date,
    truck_id,
    depot_code,
    mechanic_id,
    problem_description
FROM stage.work_orders_unf
LIMIT 5;

-- Query 4: Count empty part slots
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(part1_code), '') IS NULL
    ) AS empty_part1,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(part2_code), '') IS NULL
    ) AS empty_part2,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(part3_code), '') IS NULL
    ) AS empty_part3,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(part4_code), '') IS NULL
    ) AS empty_part4
FROM stage.work_orders_unf;

-- Query 5: Check duplicate work order numbers
SELECT
    work_order_no,
    COUNT(*) AS occurrences
FROM stage.work_orders_unf
GROUP BY work_order_no
HAVING COUNT(*) > 1;
