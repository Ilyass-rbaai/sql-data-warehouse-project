/*
=====================================================================
Procédure stockée : silver.load_silver
Base de données   : DataWeareHouse
Couche            : Silver
=====================================================================

OBJECTIF :
Charger les données de la couche Bronze vers la couche Silver en
effectuant les transformations nécessaires pour nettoyer,
standardiser, corriger et améliorer la qualité des données.

FONCTIONNEMENT GÉNÉRAL :

1. INITIALISATION
   - Déclare les variables utilisées pour mesurer les durées
     d'exécution.
   - Enregistre l'heure de début du chargement global.
   - Affiche des messages pour suivre les différentes étapes.

2. TRAITEMENT DES DONNÉES CRM

   a. crm_cust_info :
      - Supprime les données existantes avec TRUNCATE TABLE.
      - Supprime les espaces inutiles dans les prénoms et noms.
      - Standardise les statuts matrimoniaux : M devient Married,
        S devient Singale et les autres valeurs deviennent n/a.
      - Standardise le genre : M devient MALE, F devient FAMALE
        et les autres valeurs deviennent n/a.
      - Utilise ROW_NUMBER() pour conserver le dernier
        enregistrement de chaque client selon sa date de création.

   b. crm_prd_info :
      - Extrait l'identifiant de catégorie depuis la clé produit.
      - Extrait et standardise la clé produit.
      - Remplace les coûts NULL par 0.
      - Convertit les codes de gamme en valeurs descriptives.
      - Convertit les dates de début en type DATE.
      - Calcule la date de fin de chaque produit comme la veille
        de la date de début de sa version suivante, grâce à LEAD().

   c. crm_sales_details :
      - Convertit les dates de commande, d'expédition et d'échéance
        au format DATE.
      - Remplace par NULL les dates dont le format est invalide
        selon les contrôles définis dans le script.
      - Corrige les montants de vente invalides ou incohérents
        en utilisant la quantité et le prix.
      - Calcule le prix à partir du montant des ventes et de la
        quantité lorsque le prix est NULL ou inférieur ou égal à 0.

3. TRAITEMENT DES DONNÉES ERP

   a. erp_cust_az12 :
      - Supprime le préfixe NAS des identifiants qui commencent
        par NAS.
      - Remplace les dates de naissance futures par NULL.
      - Standardise les valeurs du genre en Male, Female ou n/a.

   b. erp_loc_a101 :
      - Supprime les tirets des identifiants clients.
      - Standardise certains noms de pays :
        DE devient Germany et US/USA devient United States.
      - Remplace les pays NULL ou vides par n/a.
      - Conserve les autres pays après suppression des espaces
        en début et en fin.

   c. erp_px_cat_g1v2 :
      - Vide la table Silver existante.
      - Copie les catégories, sous-catégories et informations
        de maintenance depuis la couche Bronze.

4. CHARGEMENT DES TABLES
   - TRUNCATE TABLE supprime les données existantes.
   - INSERT INTO ... SELECT charge les données transformées.
   - Les tables Silver reçoivent les données nettoyées et
     standardisées provenant des tables Bronze.

5. SUIVI DES PERFORMANCES
   - Mesure la durée de chargement de chaque table.
   - Calcule la durée totale d'exécution de la procédure.
   - Affiche les durées en secondes dans l'onglet Messages de SSMS.

RÉSULTAT ATTENDU :
Les six tables Silver sont alimentées avec des données transformées,
standardisées et préparées pour les analyses et les traitements
ultérieurs, notamment la construction de la couche Gold.

POINTS D'ATTENTION :
   - La procédure ne contient pas de TRY...CATCH : une erreur peut
     interrompre son exécution.
   - Les tables sont vidées avant leur rechargement.
   - Les transformations dépendent des règles définies dans le SQL.
   - La procédure ne réalise pas de transaction globale garantissant
     le retour à l'état initial si un chargement échoue.
   - La colonne dwh_created_at utilise sa valeur DEFAULT lors de
     l'insertion, car elle n'est pas explicitement renseignée.

=====================================================================
*/
USE DataWeareHouse;
GO
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	DECLARE @batch_start_time DATETIME ,@batch_end_time DATETIME ,@start_time DATETIME ,@end_time DATETIME;
	SET  @batch_start_time=GETDATE();
	PRINT '===================================================';
	PRINT 'Loading Silver Layer';
	PRINT '===================================================';
	PRINT '>>Truncating Data:silver.crm_cust_info'
	SET @start_time=GETDATE();
	TRUNCATE TABLE silver.crm_cust_info ;
	PRINT '>>Inserting Data Into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	) 
	SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM (cst_lastname) AS cst_lastname,
	-- data normalization and hundling nulls in marital satus
	CASE WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married' 
		WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Singale'
		ELSE 'n/a'
	END cst_marital_status,
	-- data normalization and hundling nulls in customer gender
	CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
		ELSE 'n/a'
	END cst_gndr,
	cst_create_date
	--selecting the recent record by customer 
	FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info)
	 t WHERE flag_last=1;
	 SET @end_time=GETDATE();
	PRINT '-------------------------------------------------------';
	PRINT 'Loading Duration:'+cast(DATEDIFF(second,@start_time,@end_time) as nvarchar)+'seconds'
	PRINT '-------------------------------------------------------';
	SET @start_time=GETDATE();
	 PRINT '>>Truncating Data:silver.crm_prd_info'
	TRUNCATE TABLE silver.crm_prd_info ;
	 PRINT '>>Inserting Data Into: silver.crm_prd_info';
	INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	SELECT prd_id,
	-- EXTRACTING PRODUCT CATEGORY ID
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS prd_category,
	-- extracting product key
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key, 
	prd_nm,
	ISNULL(prd_cost,0)AS prd_cost,
	-- map product line codes to descriptive values
	CASE WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line))='S' THEN 'Other sales'
		WHEN UPPER(TRIM(prd_line))='T' THEN 'TOURIN'
		ELSE 'n/a'
	END prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	-- calculate end date as one  day before the next start date 
	CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt 
	FROM bronze.crm_prd_info
	;
	SET @end_time=GETDATE();
	PRINT '-------------------------------------------------------';
	PRINT 'Loading Duration:'+cast(DATEDIFF(second,@start_time,@end_time) as nvarchar)+'seconds'
	PRINT '-------------------------------------------------------';
	SET @start_time=GETDATE();
	PRINT '>>Truncating silver.crm_sales_details'
	TRUNCATE TABLE silver.crm_sales_details ;
	 PRINT '>>Inserting Data Into: silver.crm_sales_details';
	INSERT INTO silver.crm_sales_details 
	(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	ls_ship_dt,
	sls_due_dt,
	sls_sales,
	ls_quantity,
	sls_price
	)
	SELECT sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN LEN(sls_order_dt) !=8 OR sls_order_dt=0 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN LEN(ls_ship_dt) !=8 OR ls_ship_dt=0 THEN NULL
		ELSE CAST(CAST(ls_ship_dt AS VARCHAR) AS DATE)
	END AS ls_ship_dt,
	CASE WHEN LEN(sls_due_dt) !=8 OR sls_due_dt=0 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	case when sls_sales is null or sls_sales<=0 or abs(ls_quantity)*abs(sls_price)!=abs(sls_sales) then abs(ls_quantity)*abs(sls_price)
		else sls_sales
	end as sls_sales,
	ls_quantity,
	case when sls_price is null or sls_price<=0 then sls_sales/ nullif(ls_quantity,0)
		 else sls_price
	end as sls_price 
	FROM bronze.crm_sales_details
	;
	SET @end_time=GETDATE();
	PRINT '-------------------------------------------------------';
	PRINT 'Loading Duration:'+cast(DATEDIFF(second,@start_time,@end_time) as nvarchar)+'seconds'
	PRINT '-------------------------------------------------------';
	SET @start_time=GETDATE();
	PRINT '>>Truncating silver.erp_cust_az12'
	TRUNCATE TABLE silver.erp_cust_az12 ;
	PRINT '>>Inserting Data Into: silver.erp_cust_az12';
	insert into silver.erp_cust_az12(
		CID,
		BDATE,
		GEN
	)
	select 
	case when CID like 'NAS%' then SUBSTRING(CID,4,len(CID))
		ELSE CID
	end as CID,
	case when BDATE>GETDATE() then null
		else BDATE
	end as BDATE,
	case when UPPER(TRIM(GEN))='MALE' or UPPER(TRIM(GEN))='M' then 'Male'
		when UPPER(TRIM(GEN))='FEMALE' or UPPER(TRIM(GEN))='F' then 'Female'
		else 'n/a'
	end as GEN
	
	from bronze.erp_cust_az12
	 ;
	 SET @end_time=GETDATE();
	PRINT '-------------------------------------------------------';
	PRINT 'Loading Duration:'+cast(DATEDIFF(second,@start_time,@end_time) as nvarchar)+'seconds'
	PRINT '-------------------------------------------------------';
	SET @start_time=GETDATE();
	 PRINT '>>Truncating silver.erp_loc_a101'
	TRUNCATE TABLE silver.erp_loc_a101 ;
	 PRINT '>>Inserting Data Into: silver.erp_loc_a101';
	insert into silver.erp_loc_a101(
	 CID,
	 CNTRY
	)
	select 
	REPLACE(CID,'-','') as CID,
	case when trim(CNTRY)= 'DE' then 'Germany'
		when trim(CNTRY) in ('USA','US') then 'United States'
		when trim(CNTRY)= '' or CNTRY is null then 'n/a'
		else trim(CNTRY)
	end as CNTRY
	from bronze.erp_loc_a101;
	SET @end_time=GETDATE();
	PRINT '-------------------------------------------------------';
	PRINT 'Loading Duration:'+cast(DATEDIFF(second,@start_time,@end_time) as nvarchar)+'seconds'
	PRINT '-------------------------------------------------------';
	SET @start_time=GETDATE();
	PRINT '>>Truncating silver.erp_px_cat_g1v2'
	TRUNCATE TABLE silver.erp_px_cat_g1v2 ;
	PRINT '>>Inserting Data Into: silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2 (
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
	)
	select ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	from bronze.erp_px_cat_g1v2;
	SET @end_time=GETDATE();
	PRINT '-------------------------------------------------------';
	PRINT 'Loading Duration:'+cast(DATEDIFF(second,@start_time,@end_time) as nvarchar)+'seconds'
	PRINT '-------------------------------------------------------';
	SET @batch_end_time =GETDATE();
	PRINT '=======================================================';
	PRINT 'Total Loading Duration:'+cast(DATEDIFF(second,@batch_start_time,@batch_end_time) as nvarchar)+'seconds'
	PRINT '=======================================================';
END
