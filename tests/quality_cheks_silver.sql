/*
=====================================================================
Script : Contrôle de la qualité des données (Data Quality Checks)
Base de données : DataWeareHouse
Couches vérifiées : Bronze et Silver
=====================================================================

OBJECTIF :
Vérifier la qualité, la cohérence, la standardisation et la fiabilité
des données provenant des systèmes CRM et ERP avant et après leur
transformation dans le Data Warehouse.

1. CONTRÔLE DES CLIENTS (crm_cust_info)
   - Recherche les identifiants clients dupliqués ou NULL.
   - Détecte les espaces inutiles dans les données textuelles.
   - Vérifie les données chargées dans la couche Silver.
   - Contrôle la standardisation du genre et du statut matrimonial.

2. CONTRÔLE DES PRODUITS (crm_prd_info)
   - Vérifie l'unicité des identifiants produits.
   - Détecte les noms de produits contenant des espaces inutiles.
   - Recherche les coûts négatifs ou NULL.
   - Vérifie les différentes valeurs de la gamme de produits.
   - Examine les données transformées dans la couche Silver.

3. CONTRÔLE DES VENTES (crm_sales_details)
   - Identifie les dates de commande, d'expédition et d'échéance
     invalides ou situées hors de la période autorisée.
   - Vérifie la cohérence chronologique des dates.
   - Contrôle la cohérence entre les ventes, les quantités
     et les prix unitaires.
   - Identifie les montants de vente NULL, nuls ou négatifs.
   - Compare les données brutes avec les données de la couche Silver.

4. CONTRÔLE DES CLIENTS ERP (erp_cust_az12)
   - Vérifie les correspondances entre les identifiants clients
     provenant des systèmes CRM et ERP.
   - Recherche les valeurs distinctes du genre.
   - Examine les données transformées dans la couche Silver.

5. CONTRÔLE DES LOCALISATIONS ERP (erp_loc_a101)
   - Recherche les pays NULL ou contenant des espaces inutiles.
   - Vérifie les identifiants ERP qui ne correspondent pas
     aux clés clients présentes dans la couche Silver.

6. CONTRÔLE DES CATÉGORIES ERP (erp_px_cat_g1v2)
   - Détecte les espaces inutiles dans les identifiants,
     les catégories, les sous-catégories et les informations
     de maintenance.
   - Vérifie les différentes valeurs présentes dans ces colonnes.
   - Examine les données chargées dans la couche Silver.

7. COMPARAISON BRONZE / SILVER
   - Vérifie si les transformations réalisées dans la couche Silver
     ont permis de nettoyer et de standardiser les données.
   - Identifie les anomalies qui nécessitent une correction
     des règles de transformation.

RÉSULTAT ATTENDU :
Détecter les anomalies de données, vérifier les règles métier
et s'assurer que les données Silver sont suffisamment propres
et cohérentes pour les traitements analytiques ultérieurs.

REMARQUE :
Ce script effectue uniquement des contrôles avec des requêtes SELECT.
Il ne corrige ni ne supprime directement les anomalies détectées.

=====================================================================
*/

-- checking the customer
use DataWeareHouse ;
GO
-- check for duplicate keys
SELECT cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;
-- check for unwanted spaces
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr !=TRIM(cst_gndr);

-- cheking the table in the silver
SELECT * 
FROM silver.crm_cust_info ;

-- check for duplicate keys

SELECT cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;

-- check for unwanted spaces

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr !=TRIM(cst_gndr);

-- check for data standarization 
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- cheking the products
--cheking duplicates keys
SELECT prd_id,
COUNT(prd_id)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING count(prd_id)!=1 OR prd_id IS NULL ;

-- chaking unwanted spaces in product name

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE TRIM(prd_nm)!=prd_nm;

-- cheking cost
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL;

-- checking for standarization 
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- data quality check products
SELECT * FROM silver.crm_prd_info;

-- cheking the sales 

-- checking the dates 

select NULLIF(sls_order_dt,0) 
from bronze.crm_sales_details
where sls_order_dt<=0 or len(sls_order_dt)!=8 or sls_order_dt > 20500101 or sls_order_dt <19000101;

select NULLIF(ls_ship_dt,0) 
from bronze.crm_sales_details
where ls_ship_dt<=0 or len(ls_ship_dt)!=8 or ls_ship_dt > 20500101 or ls_ship_dt <19000101;
 

select NULLIF(sls_due_dt,0) 
from bronze.crm_sales_details
where sls_due_dt<=0 or len(sls_due_dt)!=8 or sls_due_dt > 20500101 or sls_due_dt <19000101;

select * from bronze.crm_sales_details
where sls_order_dt>ls_ship_dt or ls_ship_dt>sls_due_dt ;

-- check the sales due the business rules 

select 
sls_sales as old_sales,
ls_quantity,
sls_price as old_sls_price,
case when sls_sales is null or sls_sales<=0 or abs(ls_quantity)*abs(sls_price)!=abs(sls_sales) then abs(ls_quantity)*abs(sls_price)
	else sls_sales
end as sls_sales,
case when sls_price is null or sls_price<=0 then sls_sales/ nullif(ls_quantity,0)
	 else sls_price
end as sls_price 
from bronze.crm_sales_details
where ls_quantity*sls_price !=sls_sales or sls_sales is null or sls_sales<=0 
order by sls_sales,ls_quantity,sls_price ;

--checking the health of the sales in the silver 

select *
from silver.crm_sales_details ;

-- cheking the cust_az

select count(CID) from bronze.erp_cust_az12
where CID  in (select cst_key from silver.crm_cust_info)
;
select count(CID) from bronze.erp_cust_az12
where CID not in (select cst_key from silver.crm_cust_info)
;
select * from silver.crm_cust_info;
-- checkin data stondarization
select distinct GEN from bronze.erp_cust_az12;


-- checking the health of erp_cust_az12
select * from silver.erp_cust_az12 ;

-- chekin erp_loc_a101

select * from silver.crm_cust_info;

select distinct CNTRY
from bronze.erp_loc_a101
where CNTRY not like TRIM(CNTRY) or CNTRY is null;


-- checking the health 
select CID from silver.erp_loc_a101
where CID not in (select cst_key from  silver.crm_cust_info) ;


-- cheking px_catg1v2
select * from bronze.erp_px_cat_g1v2;
-- cheking unwamted spaces
select * from bronze.erp_px_cat_g1v2
where ID!=trim(ID);
select * from bronze.erp_px_cat_g1v2
where CAT!=trim(CAT);
select * from bronze.erp_px_cat_g1v2
where SUBCAT!=trim(SUBCAT) or MAINTENANCE!=trim(MAINTENANCE) ;

-- chcking normalization
select distinct MAINTENANCE from bronze.erp_px_cat_g1v2 ;
select distinct CAT from bronze.erp_px_cat_g1v2 ;
select distinct SUBCAT from bronze.erp_px_cat_g1v2 ;

-- check the health
select * from silver.erp_px_cat_g1v2 ;
