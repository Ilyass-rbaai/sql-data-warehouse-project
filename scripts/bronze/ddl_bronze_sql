/*
=============================================================
Script : Création des tables Bronze du Data Warehouse
Base de données : DataWeareHouse
=============================================================

Objectif :
Préparer la couche Bronze de la Medallion Architecture
en créant les tables nécessaires pour stocker les données
brutes provenant des systèmes CRM et ERP.

Fonctionnement :
1. Sélectionne la base de données DataWeareHouse.
2. Vérifie si chaque table existe déjà dans le schéma Bronze.
3. Si une table existe, la supprime pour éviter les conflits.
4. Crée les tables avec les colonnes et les types de données
   nécessaires au stockage des données sources.

Tables CRM :
- crm_cust_info     : informations sur les clients.
- crm_prd_info      : informations sur les produits.
- crm_sales_details : détails des ventes, commandes, clients,
                      produits, dates et montants.

Tables ERP :
- erp_cust_az12     : informations complémentaires sur les
                      clients, notamment leur date de naissance
                      et leur genre.
- erp_loc_a101      : informations géographiques des clients.
- erp_px_cat_g1v2   : catégories, sous-catégories de produits
                      et informations de maintenance.

Remarque :
La suppression puis la recréation des tables entraîne la perte
des données déjà présentes dans ces tables.

=============================================================
*/

use DataWeareHouse;
go
IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
create table bronze.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr varchar(50),
	cst_create_date date

);
go
IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
create table bronze.crm_prd_info(
	prd_id int ,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost float,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
);
go
IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
create table bronze.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int ,
	sls_order_dt int ,
	ls_ship_dt int,
	sls_due_dt int ,
	sls_sales int ,
	ls_quantity int ,
	sls_price decimal(10,2)
);
go
IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
	CID nvarchar(50),
	BDATE date,
	GEN nvarchar(50)
);
go
IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
create table bronze.erp_loc_a101(
	CID nvarchar(50),
	CNTRY nvarchar(50)
);
go
IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2(
	ID nvarchar(50),
	CAT nvarchar(50),
	SUBCAT nvarchar(50),
	MAINTENANCE nvarchar(50)
);
