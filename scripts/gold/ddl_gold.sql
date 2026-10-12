/*
=====================================================================
Script : Création des vues Gold du Data Warehouse
Base de données : DataWeareHouse
Couche : Gold
Architecture : Star Schema (schéma en étoile)
=====================================================================

OBJECTIF :
Créer les vues analytiques de la couche Gold à partir des données
nettoyées et transformées de la couche Silver, afin de faciliter
l'analyse des données, la création de rapports et la conception
de tableaux de bord avec des outils comme Power BI.

1. VUE gold.dim_customers (DIMENSION CLIENTS)
   - Combine les informations clients du CRM avec les données ERP.
   - Génère une clé technique customer_key avec ROW_NUMBER().
   - Conserve l'identifiant et le numéro du client.
   - Récupère les noms, le pays, le statut matrimonial,
     le genre, la date de naissance et la date de création.
   - Utilise LEFT JOIN pour enrichir les clients avec les données ERP.
   - Privilégie le genre provenant du CRM lorsqu'il est disponible ;
     sinon, utilise celui de l'ERP.
   - Exclut les clients dont l'identifiant cst_id est NULL.

2. VUE gold.dim_products (DIMENSION PRODUITS)
   - Combine les informations produits du CRM avec les catégories
     provenant de l'ERP.
   - Génère une clé technique product_key avec ROW_NUMBER().
   - Récupère le numéro, le nom, la catégorie, la sous-catégorie,
     les informations de maintenance, la gamme et le coût.
   - Utilise LEFT JOIN pour associer les produits à leurs catégories.
   - Conserve uniquement les versions actuelles des produits,
     pour lesquelles prd_end_dt est NULL.

3. VUE gold.fact_sales (TABLE DE FAITS DES VENTES)
   - Récupère les transactions commerciales depuis Silver.
   - Associe chaque vente à la dimension des produits et à celle
     des clients.
   - Récupère les clés des dimensions pour faciliter les jointures
     analytiques.
   - Conserve les informations de commande, les dates de commande,
     d'expédition et d'échéance, les montants, les quantités
     et les prix.
   - Utilise LEFT JOIN pour conserver les ventes même lorsqu'aucune
     correspondance n'est trouvée dans une dimension.

4. ARCHITECTURE ANALYTIQUE
   - dim_customers : dimension descriptive des clients.
   - dim_products  : dimension descriptive des produits.
   - fact_sales    : faits et mesures associés aux ventes.
   - Ces vues constituent un schéma en étoile destiné à simplifier
     les requêtes analytiques et les modèles Power BI.

5. UTILISATION DES VUES
   - Faciliter les analyses commerciales et le reporting.
   - Analyser les ventes par client, produit, catégorie ou pays.
   - Préparer les données pour la visualisation et les indicateurs
     de performance (KPI).

REMARQUES :
   - CREATE VIEW crée une vue logique ; les données ne sont pas
     stockées physiquement dans la vue.
   - ROW_NUMBER() génère des clés techniques selon l'ordre défini,
     mais ces clés peuvent changer lorsque les données évoluent.
   - Les LEFT JOIN préservent les lignes de gauche même si aucune
     correspondance n'est trouvée dans les dimensions.

=====================================================================
*/

USE DataWeareHouse ;
GO
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.CNTRY AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.GEN,'n/a')
	END  AS gender ,
	ca.BDATE AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca
ON	ci.cst_key=ca.CID 
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key=la.CID  
 where cst_id is not null;


CREATE VIEW gold.dim_products AS
SELECT 
 ROW_NUMBER() OVER(ORDER BY pd.prd_start_dt,pd.prd_key) as produt_key,
 pd.prd_id AS product_id,
  pd.prd_key AS product_number,
 pd.prd_nm AS product_name,
 pd.cat_id AS category_id,
 ct.CAT AS category,
 ct.SUBCAT AS subcategory,
 ct.MAINTENANCE AS maintenance,
 pd.prd_line AS prroduct_line,
 pd.prd_cost AS cost,
 pd.prd_start_dt AS start_date
FROM silver.crm_prd_info pd 
LEFT JOIN silver.erp_px_cat_g1v2 ct
ON pd.cat_id=ct.ID
 WHERE prd_end_dt is null --selecting	 only current data 
 ;
CREATE VIEW gold.fact_sales AS 
SELECT 
	sd.sls_ord_num AS order_number,
	pd.produt_key,
	ct.customer_key,
	sd.sls_order_dt AS order_date,
	sd.ls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.ls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pd
ON sd.sls_prd_key=pd.product_number
LEFT JOIN gold.dim_customers ct
ON sd.sls_cust_id=ct.customer_id;


