# Recorded verification output

**Student:** Mohamed Salem Maidan  
**Institution:** Atlantis University  
**Course:** CIT 408 — Database Management Operations and Optimization  
**Assignment:** Week 3 — Backup and Restore Superstore

## Original versus restored table counts

Recorded in terminal screenshots; the final `diff -u` displayed **`PASS: All nine table counts match`** after the single-table rescue.

| Table | Original | Restored |
|---|---:|---:|
| categories | 3 | 3 |
| customers | 793 | 793 |
| locations | 632 | 632 |
| order_lines | 9,994 | 9,994 |
| orders | 5,009 | 5,009 |
| products | 1,894 | 1,894 |
| staging_superstore | 9,994 | 9,994 |
| states | 49 | 49 |
| subcategories | 17 | 17 |

## Financial reconciliation

| Metric | Original `superstore` | `superstore_restore` |
|---|---:|---:|
| Total sales | $2,297,200.86 | $2,297,200.86 |
| Total profit | $286,397.02 | $286,397.02 |

## Single-table rescue

- Deletion: `DELETE 9994` in `superstore_restore` only.
- After deletion: `SELECT COUNT(*) FROM public.order_lines` returned **0**.
- After table-only `pg_restore`: **9,994** order lines, **$2,297,200.86** sales, **$286,397.02** profit.
- Measured table-only recovery: **0.335 seconds**.
- A subsequent comparison of all nine table counts returned **PASS**.

## Evidence references

- `evidence/07_financial_totals.png`
- `evidence/08_single_table_rescue.png`
- `evidence/09_table_counts_diff.png`

These are transcriptions of the supplied screenshots, not independently executed queries by the document author.
