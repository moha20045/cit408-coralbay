# Superstore Backup and Recovery Plan

**Student:** Mohamed Salem Maidan  
**University:** Atlantis University  
**Course:** CIT 408 — Database Management Operations and Optimization  
**Assignment:** Module 3, Assignment 3.1  
**Report date:** October 15, 2026

## Objective and scope

Protect the `superstore` PostgreSQL 18 database from hardware failure, erroneous changes, or accidental deletion. The test database has nine tables and 9,994 order-line records. Restore tests were performed on `superstore_restore`, never on the original `superstore` database.

## Recommended backup schedule

- **Daily at 01:00:** custom-format logical backup with `pg_dump -Fc` using the restricted `backup_operator` login. Also create a plain SQL backup and role/global backup as appropriate.
- **After each run:** check exit status, generated file size, and archive TOC; alert on failures.
- **Every week:** verify off-server copy and file integrity.
- **Monthly:** restore into an isolated database and compare all nine table counts, sales, and profit. Perform a selective order-line recovery test.

This schedule is a **proposed policy**, not an automation already configured on the server.

## Retention and storage

- Keep 14 daily recovery points, 8 weekly points, and 6 monthly points, subject to available storage and institutional policies.
- Store one access-controlled copy on the database host and another copy on a separate computer, such as the Windows workstation used in this exercise.
- Keep at least one **encrypted off-site** copy. Apply least-privilege access and verify restoration from the off-site copy periodically.
- Keep SQL roles backups private; they may contain credential hashes. **Never commit backup files or secrets to GitHub.**
- Follow a 3-2-1 approach where practical: three copies, two storage types, one off-site.

## Measured test results (October 14–15, 2026)

| Operation | Measured elapsed time |
|---|---:|
| Custom-format dump | 0.329 s |
| Plain-format dump | 0.180 s |
| Roles-only dump | 0.080 s |
| Full restore | 0.376 s |
| Single-table data recovery | 0.335 s |

| File | Size reported by `ls -lh` |
|---|---:|
| `superstore_2026-10-14.dump` | 851 KiB (rounded display) |
| `superstore_2026-10-14.sql` | 3.2 MiB (rounded display) |
| `roles_2026-10-14.sql` | 952 bytes |

The Windows transfer UI displayed approximately 851 KB, 3,251 KB and 1 KB respectively. These human-readable sizes are rounded display values rather than byte-accurate measurements.

## Recovery objectives

**RPO (Recovery Point Objective): up to 24 hours**, assuming a successful daily backup schedule and no WAL/PITR capability. The RPO is a design target; a failed or missed backup could extend actual data loss beyond 24 hours.

**RTO (Recovery Time Objective): 60 minutes, proposed target.** The measured PostgreSQL restore took 0.376 seconds for this small test database, but operational recovery also requires incident response, provisioning, backup retrieval, user validation, and reconnecting applications. The one-hour RTO is **not validated end-to-end**; a full incident exercise must measure these steps before the goal can be guaranteed.

## Recovery procedure

1. Confirm incident scope and preserve logs.
2. Obtain a valid copy of the most recent successful backup.
3. Provision PostgreSQL 18 and create an empty target database.
4. Restore custom archive using `pg_restore` with an appropriate administrative role.
5. Run `verify.sql` against both original and restored instances when original remains available.
6. Check all nine row counts, total sales, and total profit to the cent.
7. For table-only incidents, target only the affected table's data rather than overwriting the entire database.
8. Document timing, results, and final incident closure.

## Test conclusions

The test recovered all nine tables (including 9,994 order lines) and reproduced $2,297,200.86 in sales and $286,397.02 in profit. A separate selective restore repopulated 9,994 deleted order lines in 0.335 seconds. The final comparison printed `PASS: All nine table counts match`.

## Limitations

The measured times exclude transfer to Windows, backup retrieval from an off-site location, and server provisioning. Row-count and aggregate reconciliation are valuable but do not prove byte-for-byte data equality. The proposed retention and operational schedule have not been deployed or monitored as part of this assignment.
