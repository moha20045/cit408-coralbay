# Command Log — Superstore Backup and Restore

**Student:** Mohamed Salem Maidan  
**University:** Atlantis University  
**Course:** CIT 408 — Database Management Operations and Optimization  
**Assignment:** Module 3, Assignment 3.1  
**Date:** October 14–15, 2026

> This is a reconstructed chronological log from the provided terminal screenshots and conversation. Commands that were not fully captured are marked as explanatory or reproducible examples, not falsely claimed as executed. No passwords are included. Commands prefixed with `sudo docker` run on the **Linux host**; `pg_dump`, `pg_restore` and `psql` without `sudo docker` were run **inside the pg18 container**.

## A. Prepare the Linux PostgreSQL instance (migration prerequisite)

```bash
sudo docker ps
```
Confirmed PostgreSQL 18 container `pg18` was running; unprivileged `docker ps` had initially failed due to Docker-socket permission restrictions.

```bash
ls -lh ~/cit408-coralbay/week2/superstore_migration_2026-10-14.backup
mkdir -p ~/db_backups
mv ~/cit408-coralbay/week2/superstore_migration_2026-10-14.backup ~/db_backups/
ls -lh ~/db_backups/
sudo docker cp ~/db_backups/superstore_migration_2026-10-14.backup pg18:/tmp/
sudo docker exec pg18 ls -lh /tmp/superstore_migration_2026-10-14.backup
sudo docker exec pg18 createdb -U postgres superstore
sudo docker exec pg18 pg_restore -U postgres -d superstore --no-owner --no-acl --exit-on-error /tmp/superstore_migration_2026-10-14.backup
sudo docker exec -it pg18 psql -U postgres -d superstore -c "\dt"
sudo docker exec -it pg18 psql -U postgres -d superstore -c "SELECT COUNT(*) FROM public.order_lines;"
```
Transferred the 848 KB Windows migration archive onto the Linux host and into the container, created the database, restored its tables, and verified that `order_lines` contained 9,994 records. The migration archive is separate from the three assessed Week 3 backup files.

## B. Least-privilege backup operator

```bash
sudo docker exec -it pg18 psql -U postgres -d superstore
```
Opened psql with an administrative role inside PostgreSQL 18.

```sql
CREATE ROLE backup_operator WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
\password backup_operator
GRANT CONNECT ON DATABASE superstore TO backup_operator;
GRANT USAGE ON SCHEMA public TO backup_operator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_operator;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO backup_operator;
\du
```
Created a login with database/schema and table/sequence read access, set its password interactively, and displayed roles. No administrative role attributes were granted.

```sql
SELECT
 has_table_privilege('backup_operator', 'public.order_lines', 'SELECT') AS can_read,
 has_table_privilege('backup_operator', 'public.order_lines', 'INSERT') AS can_insert,
 has_table_privilege('backup_operator', 'public.order_lines', 'UPDATE') AS can_update,
 has_table_privilege('backup_operator', 'public.order_lines', 'DELETE') AS can_delete;
\q
```
Verified SELECT=true and INSERT/UPDATE/DELETE=false, then quit psql.

## C. All three required backups

```bash
sudo docker exec pg18 mkdir -p /tmp/week3_backups
sudo docker exec -it pg18 bash
umask 077
```
Created the internal backup staging directory, entered the container and restricted file-creation permissions.

```bash
time pg_dump -h 127.0.0.1 -U backup_operator -d superstore -Fc -f /tmp/week3_backups/superstore_2026-10-14.dump
ls -lh /tmp/week3_backups/
```
Ran a custom-format logical dump as backup_operator; real time **0.329 s**, archive about **851 KiB**.

```bash
time pg_dump -h 127.0.0.1 -U backup_operator -d superstore -Fp -f /tmp/week3_backups/superstore_2026-10-14.sql
```
Ran plain-SQL logical backup as backup_operator; real time **0.180 s**.

```bash
time pg_dumpall -U postgres --roles-only -f /tmp/week3_backups/roles_2026-10-14.sql
ls -lh /tmp/week3_backups/
pg_restore -l /tmp/week3_backups/superstore_2026-10-14.dump | grep -E 'TABLE DATA.*order_lines'
```
Exported cluster roles with an administrative role (real **0.080 s**), verified all three file sizes, and confirmed the custom archive's table of contents includes order_lines data.

## D. Off-container and off-server copies

```bash
exit
mkdir -p ~/db_backups/week3
sudo docker cp pg18:/tmp/week3_backups/. ~/db_backups/week3/
sudo chown -R azureuser:azureuser ~/db_backups/week3
chmod 700 ~/db_backups/week3
chmod 600 ~/db_backups/week3/*
ls -lh ~/db_backups/week3/
```
Exited Docker, copied all backup files onto the Linux VM, set restrictive permissions, and checked sizes.

**WinSCP / Windows GUI actions (no shell command):** connected by SFTP; transferred the three backups from `/home/azureuser/db_backups/week3/` to `C:\Users\moham\Downloads\CIT408_Backup_Files\`. The screenshot of both transfer panels showed three files on each side.

## E. Full restore and timing

```bash
sudo docker exec pg18 createdb -U postgres superstore_restore
sudo docker exec -it pg18 bash
time pg_restore -U postgres -d superstore_restore --no-owner --no-acl --exit-on-error /tmp/week3_backups/superstore_2026-10-14.dump
psql -U postgres -d superstore_restore -c "\dt"
psql -U postgres -d superstore_restore -c "SELECT COUNT(*) FROM public.order_lines;"
```
Created a separate target database; restored all archive objects in **0.376 s**, listed nine tables and counted 9,994 order lines.

## F. Counts and financial totals

The following **equivalent** SQL was run separately against `superstore` and `superstore_restore` (the full executed nine-table UNION is preserved in `verify.sql`):

```bash
psql -U postgres -d superstore -c "SELECT ROUND(SUM(sales)::numeric, 2) AS total_sales, ROUND(SUM(profit)::numeric, 2) AS total_profit FROM public.order_lines;"
psql -U postgres -d superstore_restore -c "SELECT ROUND(SUM(sales)::numeric, 2) AS total_sales, ROUND(SUM(profit)::numeric, 2) AS total_profit FROM public.order_lines;"
```
Confirmed **$2,297,200.86** in sales and **$286,397.02** in profit in each database. The nine counts were also compared; see `verification_output.md` and `evidence/07_financial_totals.png`.

## G. Single-table recovery demonstration

```bash
psql -U postgres -d superstore_restore -c "DELETE FROM public.order_lines;"
psql -U postgres -d superstore_restore -c "SELECT COUNT(*) FROM public.order_lines;"
```
Removed exactly **9,994** order-line records **from superstore_restore only** and verified count 0.

```bash
time pg_restore -U postgres -d superstore_restore --data-only --schema=public --table=order_lines --no-owner --no-acl --exit-on-error /tmp/week3_backups/superstore_2026-10-14.dump
psql -U postgres -d superstore_restore -c "SELECT COUNT(*) AS order_lines, ROUND(SUM(sales)::numeric, 2) AS total_sales, ROUND(SUM(profit)::numeric, 2) AS total_profit FROM public.order_lines;"
```
Restored only the deleted table's data in **0.335 s** and confirmed 9,994 rows, $2,297,200.86 sales, and $286,397.02 profit.

## H. Final comparison

```bash
for db in superstore superstore_restore; do
  psql -U postgres -d "$db" -At -c "
    SELECT 'categories', COUNT(*) FROM public.categories
    UNION ALL SELECT 'customers', COUNT(*) FROM public.customers
    UNION ALL SELECT 'locations', COUNT(*) FROM public.locations
    UNION ALL SELECT 'order_lines', COUNT(*) FROM public.order_lines
    UNION ALL SELECT 'orders', COUNT(*) FROM public.orders
    UNION ALL SELECT 'products', COUNT(*) FROM public.products
    UNION ALL SELECT 'staging_superstore', COUNT(*) FROM public.staging_superstore
    UNION ALL SELECT 'states', COUNT(*) FROM public.states
    UNION ALL SELECT 'subcategories', COUNT(*) FROM public.subcategories
    ORDER BY 1;" > "/tmp/${db}_counts.txt"
done

diff -u /tmp/superstore_counts.txt /tmp/superstore_restore_counts.txt \
  && echo "PASS: All nine table counts match"
```
Both output files matched; terminal printed **`PASS: All nine table counts match`**.

## I. Incident Desk Activity 3.2

Completed all six simulator tickets. Shift report score: **18/18**, 6/6 correct methods on first attempt, and 2/2 ordering questions on first attempt. See `evidence/10_activity_3_2_shift_report.png`.

## J. Git upload — still to execute

These commands are **submission instructions, not steps already demonstrated in the screenshots**:

```bash
cd ~/cit408-coralbay
mkdir -p week3/backup
# Copy the delivered documentation and evidence into week3/backup first.
git add week3/backup/
git status
# Confirm no backup archives, role dumps or passwords are staged.
git commit -m "CIT 408 Week 3 - backup and restore evidence"
git push origin main
```
