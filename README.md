# Retail System Ingestion – Sample Data

Sample project for demonstrating simple data ingestion in Databricks. Repo created for Medium post `Data ingestion in Databricks-Keep It Simple Stupid`.

**Note:** This sample assumes only a **dev environment** is supported.

---

## Prerequisites
- Databricks workspace with Unity Catalog
- Warehouse with `Can use` permission
- Write access to bronze and silver catalogs
- Write access to S3 landing data bucket
- Read access to landing bucket External Location
## Setup

### Virtual environment and dependencies

Create a virtual environment and install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate   # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```
Python >=3.10 is required.

---

## Configuration

Replace the following placeholders with your own values (in `dbt/profiles.yml`, `profiles.yml` and in the dbt model configs):

| Placeholder                     | Description                                                                                    |
|---------------------------------|------------------------------------------------------------------------------------------------|
| `<bronze_catalog_name>`         | Your Databricks Unity Catalog name for bronze catalog                                          |
| `<silver_catalog_name>`         | Your Databricks Unity Catalog name for silver catalog                                            |
| `<dev_workspace_host>`          | Your dev Databricks workspace host, e.g. `dbc-XYZabc12-0000.cloud.databricks.com`              |
| `<dev_workspace_name>`          | Name of your dev databricks workspace (part of `dev_workspace_host`), e.g. `dbc-XYZabc12-0000` |
| `<dev_sql_warehouse_http_path>` | HTTP path of your SQL warehouse (e.g. `/sql/1.0/warehouses/xxx`)                               |
| `<landing_bucket_dev>`          | Your S3 landing bucket                                                                         |

Search the repo for these occurrences and replace them before running dbt.

**Note: `s3://<landing_bucket_dev>/retail_system` must be registered Unity Catalog External Location you have read access to!**

---

## Batch data (`sample_data/batch/users`)

**Location:** `sample_data/batch/users/`  
**Format:** JSON Lines  
**Files:** `users_1.json` (5,000 rows), `users_2.json` (5,000 rows)  
**Columns:** `id`, `firstname`, `lastname`

### Instructions

1. Copy the batch user data to your S3 bucket:
   - Copy `users_1.json` and `users_2.json` from `sample_data/batch/users/` to `"s3://<landing_bucket_dev>/retail_system/batch/users/`.

2. Run `dbt run --select bronze__users+` from `dbt` directory. You should see a table `<bronze_catalog_name>.retail_system.users` and view `<silver_catalog_name>.retail_system.users` with 3 columns: `id`, `first_name`, and `last_name`, with 10,000 rows in total.

---

## Streaming data (`sample_data/streaming/transactions`)

**Location:** `sample_data/streaming/transactions/`  
**Format:** JSON Lines  
**Increments:** Each increment has 100 files; each file has 20 rows. Use one increment at a time to simulate schema evolution.

| Increment   | Columns        | Purpose                         |
|------------|----------------|----------------------------------|
| `increment_1` | `id`, `amount` | Initial schema                   |
| `increment_2` | `id`, `amount`, `date` | Add column `date`         |
| `increment_3` | `id`, `amount`, `date`, `paid` | Add column `paid`   |
| `increment_4` | `id`, `amount`, `paid` | Remove column `date`|

### Instructions (streaming table / schema evolution)

1. **Copy data from `increment_1` to S3** `s3://<landing_bucket_dev>/retail_system/streaming/transactions/increment_1` and run `dbt run --select bronze__transactions+` from `dbt` directory. You should see a table `<bronze_catalog_name>.retail_system.transactions` and view `<silver_catalog_name>.retail_system.transactions` with **2 columns:** `id` and `amount`.

2. **Copy data from `increment_2` to S3** `s3://<landing_bucket_dev>/retail_system/streaming/transactions/increment_2`  and run `dbt run --select bronze__transactions+` again. You should see a **new column:** `date` in table and view.

3. **Copy data from `increment_3` to S3** `s3://<landing_bucket_dev>/retail_system/streaming/transactions/increment_3`  and run `dbt run --select bronze__transactions+`. You should see a **new column:** `paid` in table and view.

4. **Copy data from `increment_4` to S3** `s3://<landing_bucket_dev>/retail_system/streaming/transactions/increment_3` and run `dbt run --select bronze__transactions`. Schema should not be modified, but new rows have `null` values in `date` column.

This sequence demonstrates how Databricks streaming tables handle adding and removing columns across increments.

---

## Cleanup after testing

After you finish testing, **delete the tables created**. Otherwise, bronze streaming tables with scheduled ingestion will continue to run and **generate ongoing costs**. Remove the tables from your Databricks catalog once you are done.
