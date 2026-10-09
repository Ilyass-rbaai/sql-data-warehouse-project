/*
=====================================================================
Procédure stockée : bronze.load_bronze
Base de données   : DataWeareHouse
Couche            : Bronze
=====================================================================

OBJECTIF :
Charger les données brutes depuis les fichiers CSV des systèmes
CRM et ERP vers les tables de la couche Bronze du Data Warehouse.

FONCTIONNEMENT :

1. INITIALISATION
   - Déclare les variables permettant de mesurer les durées
     d'exécution.
   - Enregistre l'heure de début du chargement global.

2. CHARGEMENT DES TABLES CRM
   - crm_cust_info     : informations sur les clients.
   - crm_prd_info      : informations sur les produits.
   - crm_sales_details : détails des ventes.

3. CHARGEMENT DES TABLES ERP
   - erp_cust_az12   : données complémentaires sur les clients.
   - erp_loc_a101    : informations géographiques des clients.
   - erp_px_cat_g1v2 : catégories et sous-catégories des produits.

4. POUR CHAQUE TABLE
   - TRUNCATE TABLE : supprime toutes les données existantes
     de la table sans supprimer sa structure.
   - BULK INSERT    : importe les données depuis le fichier CSV.
   - FIRSTROW = 2   : ignore la première ligne contenant les en-têtes.
   - FIELDTERMINATOR = ',' : indique que les colonnes sont séparées
     par des virgules.
   - TABLOCK        : demande un verrou de table pendant l'import.
   - DATEDIFF       : calcule la durée du chargement en secondes.
   - PRINT          : affiche les étapes et les durées dans
     l'onglet Messages de SQL Server Management Studio (SSMS).

5. GESTION DES ERREURS
   - BEGIN TRY : exécute les opérations de chargement.
   - BEGIN CATCH : intercepte les erreurs survenues et affiche
     leur message, leur numéro et leur état.

6. SUIVI DES PERFORMANCES
   - Calcule la durée de chargement de chaque table.
   - Calcule et affiche la durée totale du chargement Bronze.

RÉSULTAT ATTENDU :
Les six tables Bronze sont alimentées avec les données des fichiers
CSV sources, prêtes pour les prochaines étapes de transformation
et de nettoyage dans la couche Silver.

ATTENTION :
- TRUNCATE TABLE efface les données précédentes avant chaque import.
- En cas d'échec, une table peut rester vide ou partiellement chargée.
- Les chemins des fichiers doivent être accessibles par le service
  SQL Server, et pas seulement par l'utilisateur Windows.
- Le bloc CATCH affiche les erreurs, mais ne les relance pas
  automatiquement à l'appelant.

=====================================================================
*/
use DataWeareHouse;
go
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	
	BEGIN TRY
		DECLARE @START_DATE DATETIME , @END_DATE DATETIME, @batch_time_start DATETIME,@batch_time_end DATETIME;
		PRINT '=======================================================';
		PRINT 'LOADING BRONZE LAYER';
	


		PRINT '-------------------------------------------------------';
		PRINT 'LOADING CAM TABLES';
		PRINT '-------------------------------------------------------';
		SET @batch_time_start=GETDATE();
		SET @START_DATE=GETDATE();

		PRINT '>>>>>>> TRUNCATING DATA:bronze.crm_cust_info'
		PRINT '-------------------------------------------------------';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>>>>>> INSERTING DATA:bronze.crm_cust_info'
		PRINT '-------------------------------------------------------';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\HP\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @END_DATE=GETDATE();
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_DATE,@END_DATE) AS NVARCHAR)+' SECONDS';

		SET @START_DATE=GETDATE();
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> TRUNCATING DATA:bronze.crm_prd_info'
		PRINT '-------------------------------------------------------';
		TRUNCATE TABLE bronze.crm_prd_info ;
		PRINT '>>>>>>> INSERTING DATA:bronze.crm_prd_info'
		PRINT '-------------------------------------------------------';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\HP\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @END_DATE=GETDATE();
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_DATE,@END_DATE) AS NVARCHAR)+' SECONDS';

		SET @START_DATE=GETDATE();
		PRINT '>>>>>>> TRUNCATING DATA:bronze.crm_sales_details'
		PRINT '-------------------------------------------------------';
		TRUNCATE TABLE bronze.crm_sales_details ;
		PRINT '>>>>>>> INSERTING DATA:bronze.crm_sales_details'
		PRINT '-------------------------------------------------------';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\HP\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @END_DATE=GETDATE();
		
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_DATE,@END_DATE) AS NVARCHAR)+' SECONDS';

		PRINT '-------------------------------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '-------------------------------------------------------';


		SET @START_DATE=GETDATE();

		PRINT '>>>>>>> TRUNCATING DATA:bronze.erp_cust_az12'
		PRINT '-------------------------------------------------------';
		TRUNCATE TABLE bronze.erp_cust_az12 ;
		PRINT '>>>>>>> INSERTING DATA:bronze.erp_cust_az12'
		PRINT '-------------------------------------------------------';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\HP\Documents\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @END_DATE=GETDATE();
		
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_DATE,@END_DATE) AS NVARCHAR)+' SECONDS';

		SET @START_DATE=GETDATE();
		PRINT '>>>>>>> TRUNCATING DATA:bronze.erp_loc_a101'
		PRINT '-------------------------------------------------------';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>>>>>>> INSERTING DATA:bronze.erp_loc_a101'
		PRINT '-------------------------------------------------------';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\HP\Documents\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @END_DATE=GETDATE();
		
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_DATE,@END_DATE) AS NVARCHAR)+' SECONDS';

		SET @START_DATE=GETDATE();
		PRINT '>>>>>>> TRUNCATING DATA:bronze.erp_px_cat_g1v2'
		PRINT '-------------------------------------------------------';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2 ;
		PRINT '>>>>>>> INSERTING DATA:bronze.erp_px_cat_g1v2'
		PRINT '-------------------------------------------------------';
		BULK INSERT bronze.erp_px_cat_g1v2
		from 'C:\Users\HP\Documents\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @END_DATE=GETDATE();
		
		PRINT '-------------------------------------------------------';
		PRINT '>>>>>>> LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@START_DATE,@END_DATE) AS NVARCHAR)+' SECONDS';
		SET @batch_time_end =GETDATE()

		PRINT '=======================================================';
		PRINT '>>>>>>> TOTAL LOAD DURATION: '+ CAST(DATEDIFF(SECOND,@batch_time_start,@batch_time_end) AS NVARCHAR)+' SECONDS';
		PRINT '=======================================================';

	END TRY
	BEGIN CATCH
	PRINT '-------------------------------------------------------';
	PRINT 'ERROR DURING LOADING BRONZE LAYER';
	PRINT 'ERROR MESSAGE'+ERROR_MESSAGE();
	PRINT 'ERROR  NUMBER'+ CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'ERROR STATE'+ CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '-------------------------------------------------------'
	END CATCH
END
