/*
=====================================================================
Script : Création des tables Silver du Data Warehouse
Base de données : DataWeareHouse
Couche : Silver
=====================================================================

OBJECTIF :
Créer les tables de la couche Silver pour accueillir les données
provenant de la couche Bronze après leur nettoyage, leur validation
et leur transformation.

FONCTIONNEMENT :

1. SÉLECTION DE LA BASE DE DONNÉES
   - Utilise la base de données DataWeareHouse.

2. VÉRIFICATION ET SUPPRESSION
   - OBJECT_ID vérifie si chaque table existe déjà.
   - DROP TABLE supprime la table existante avant sa recréation.
   - Cette opération permet de repartir d'une structure propre.

3. CRÉATION DES TABLES CRM
   - crm_cust_info : informations sur les clients.
   - crm_prd_info : informations sur les produits, avec la catégorie
     associée (cat_id).
   - crm_sales_details : informations sur les commandes et les ventes.

4. CRÉATION DES TABLES ERP
   - erp_cust_az12 : informations complémentaires sur les clients.
   - erp_loc_a101 : informations géographiques des clients.
   - erp_px_cat_g1v2 : catégories et sous-catégories des produits.

5. TYPES DE DONNÉES
   - INT : nombres entiers.
   - NVARCHAR / VARCHAR : données textuelles.
   - DATE : dates sans heure.
   - DECIMAL(10,2) : nombres décimaux adaptés aux montants.
   - DATETIME2 : dates et heures avec une précision élevée.

6. COLONNE DWH_CREATED_AT
   - Ajoutée à chaque table pour suivre la date et l'heure
     d'insertion des lignes.
   - DEFAULT GETDATE() fournit automatiquement une valeur
     lors d'une insertion si aucune valeur n'est spécifiée.

RÉSULTAT ATTENDU :
Six tables Silver sont créées pour accueillir les données
nettoyées et standardisées, avant leur utilisation dans les
transformations suivantes et la construction de la couche Gold.

ATTENTION :
- DROP TABLE supprime la structure et les données existantes.
- Ce script crée uniquement les tables ; il ne charge pas
  et ne nettoie pas encore les données.
- Le chargement et les transformations seront réalisés par
  une procédure stockée dédiée à la couche Silver.

=====================================================================
*/

use DataWeareHouse;
go
IF OBJECT_ID ('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
create table silver.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr varchar(50),
	cst_create_date date,
	dwh_created_at DATETIME2 default GETDATE()
);
go
IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
create table silver.crm_prd_info(
	prd_id int ,
	cat_id NVARCHAR(50),
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost INT,
	prd_line nvarchar(50),
	prd_start_dt date,
	prd_end_dt date,
	dwh_created_at DATETIME2 default GETDATE()
);
go
IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
create table silver.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int ,
	sls_order_dt date ,
	ls_ship_dt date,
	sls_due_dt date ,
	sls_sales int ,
	ls_quantity int ,
	sls_price decimal(10,2),
	dwh_created_at DATETIME2 default GETDATE()
);
go
IF OBJECT_ID ('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
create table silver.erp_cust_az12(
	CID nvarchar(50),
	BDATE date,
	GEN nvarchar(50),
	dwh_created_at DATETIME2 default GETDATE()
);
go
IF OBJECT_ID ('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
create table silver.erp_loc_a101(
	CID nvarchar(50),
	CNTRY nvarchar(50),
	dwh_created_at DATETIME2 default GETDATE()
);
go
IF OBJECT_ID ('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2(
	ID nvarchar(50),
	CAT nvarchar(50),
	SUBCAT nvarchar(50),
	MAINTENANCE nvarchar(50),
	dwh_created_at DATETIME2 default GETDATE()
);
