# Naming Conventions

This document describes the naming conventions currently used in the SQL Server data warehouse and its Power BI report. It distinguishes established patterns from existing naming inconsistencies.

## 1. General Principles

- Use lowercase `snake_case` for SQL object names and business column aliases.
- Identify each warehouse layer through its schema: `bronze`, `silver`, or `gold`.
- Use fully qualified object names, such as `silver.crm_cust_info`.
- Preserve source identifiers in Bronze and Silver to support traceability.
- Use descriptive English names in Gold.
- Use French display names in Power BI.

The current database name is `DataWeareHouse`. Scripts and connection settings must use this exact spelling consistently.

Some source columns retain uppercase names, such as `CID`, `BDATE`, `GEN`, and `CNTRY`.

## 2. Bronze and Silver Tables

Bronze stores raw source records. Silver stores cleaned and transformed records.

Both layers follow this pattern:

`<schema>.<source_system>_<source_entity>`

| Source | Bronze table | Silver table |
| --- | --- | --- |
| CRM customers | `bronze.crm_cust_info` | `silver.crm_cust_info` |
| CRM products | `bronze.crm_prd_info` | `silver.crm_prd_info` |
| CRM sales | `bronze.crm_sales_details` | `silver.crm_sales_details` |
| ERP customer details | `bronze.erp_cust_az12` | `silver.erp_cust_az12` |
| ERP customer locations | `bronze.erp_loc_a101` | `silver.erp_loc_a101` |
| ERP product categories | `bronze.erp_px_cat_g1v2` | `silver.erp_px_cat_g1v2` |

The `crm_` and `erp_` prefixes identify the source system. Entity names retain the identifiers used in the source files, normalized for SQL table naming.

## 3. Gold Views

Gold exposes business-oriented views over Silver. These objects are logical views rather than separately loaded physical tables.

Naming pattern:

`gold.<role>_<business_entity>`

| Prefix | Meaning | Existing objects |
| --- | --- | --- |
| `dim_` | Descriptive dimension view | `gold.dim_customers`, `gold.dim_products` |
| `fact_` | Transaction-level fact view | `gold.fact_sales` |

There are currently no `report_` objects in the warehouse.

## 4. Column Names

### Source Columns

Bronze and Silver retain source-oriented names and abbreviations.

| Prefix or identifier | Purpose | Examples |
| --- | --- | --- |
| `cst_` | CRM customer attributes | `cst_id`, `cst_firstname`, `cst_create_date` |
| `prd_` | CRM product attributes | `prd_id`, `prd_nm`, `prd_start_dt` |
| `sls_` | CRM sales attributes | `sls_ord_num`, `sls_sales`, `sls_price` |
| ERP identifiers | Source-specific attributes | `CID`, `BDATE`, `GEN`, `CNTRY` |

The sales columns `ls_ship_dt` and `ls_quantity` currently use `ls_` rather than `sls_`. Documentation and queries must reflect these existing names until they are corrected consistently.

### Gold Business Columns

Gold replaces source abbreviations with readable business aliases.

Examples include:

- Customer attributes: `customer_id`, `customer_number`, `first_name`, `country`.
- Product attributes: `product_id`, `product_number`, `product_name`, `category`.
- Sales attributes: `order_number`, `order_date`, `shipping_date`, `sales_amount`, `quantity`, `price`.

### Dimension Keys

Generated dimension keys use the suffix `_key`.

| Dimension | Current key name |
| --- | --- |
| Customers | `customer_key` |
| Products | `produt_key` |

These keys are generated with `ROW_NUMBER()` in the dimension views and referenced by `gold.fact_sales`. They are logical analytical keys; the views do not enforce primary-key or foreign-key constraints.

Their values can change when source records change. They should not be treated as persistent identifiers across independent refreshes.

### Technical Metadata

System-generated warehouse metadata uses the prefix `dwh_`.

The current implementation adds the following column to all six Silver tables:

| Column | Type | Purpose |
| --- | --- | --- |
| `dwh_created_at` | `DATETIME2` | Records the insertion timestamp using `DEFAULT GETDATE()` |

Bronze tables currently have no `dwh_` metadata column.

## 5. Stored Procedures

Layer-loading procedures follow this pattern:

`<schema>.load_<layer>`

| Procedure | Responsibility |
| --- | --- |
| `bronze.load_bronze` | Loads the six source CSV files into Bronze |
| `silver.load_silver` | Cleans and transforms Bronze data into Silver |

There is no `gold.load_gold` procedure because Gold consists of views over Silver.

## 6. Power BI Names

The report uses French table, column, measure, and page names for presentation.

| SQL object | Power BI table |
| --- | --- |
| `gold.dim_customers` | `Clients` |
| `gold.dim_products` | `Produits` |
| `gold.fact_sales` | `Ventes` |
| Date table created in Power BI | `Calendrier` |

Measures use descriptive business labels, such as `Chiffre d’affaires`, `Commandes`, `Unités vendues`, and `Panier moyen`.

The report contains three pages: sales overview, product performance, and customer analysis.

## 7. Existing Naming Inconsistencies

The following spellings are present in the current implementation:

| Current name | Recommended standardized name |
| --- | --- |
| `produt_key` | `product_key` |
| `prroduct_line` | `product_line` |
| `ls_ship_dt` | `sls_ship_dt` |
| `ls_quantity` | `sls_quantity` |

Any future renaming must update the SQL definitions, loading procedures, validation queries, Power Query transformations, and documentation together.

This document records the current implementation; the recommended names above have not yet been applied.
