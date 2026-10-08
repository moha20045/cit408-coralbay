
# CIT 408 - Module 2, Assignment 2.1

## Fleet Work Orders Normalization

Instructor: Professor Luis De Leon

### Assignment Summary

This project analyzes 1,100 Coral Bay fleet work orders
and develops a database normalization design through 3NF.

### Completed Work

- Activity 2.2: 16/16
- Imported 1,100 work orders into PostgreSQL 18
- Completed five exploration queries
- Identified and tested 24 functional dependencies
- Executed 10 supporting database checks
- Documented the DEP-FLL phone number conflict
- Created the 1NF, 2NF, and 3NF designs
- Created the final eight-table ERD

### Data Conflict

DEP-FLL contains two recorded phone numbers.

- (954) 555-0118: 266 work orders
- (954) 555-0181: 2 work orders

Affected work orders: WO-50041 and WO-50047.

The majority value is provisional pending verification
with the depot. Original staging records remain unchanged.

### Submission Files

- simulator_results.png
- explore.sql
- dependencies.md
- fd_checks.sql
- design.md
- erd.png

Supporting files include fd_results.txt and the
PostgreSQL verification script.

### GitHub Repository

https://github.com/moha20045/cit408-coralbay/tree/main/week2
