/*
    Ce script permet de réinitialiser complètement le Data Warehouse.

    1. Vérifie si la base de données DataWeareHouse existe.
    2. Si elle existe, force la déconnexion des utilisateurs et la supprime.
    3. Crée une nouvelle base de données DataWeareHouse.
    4. Crée les trois schémas de la Medallion Architecture :
       - Bronze : données brutes
       - Silver : données nettoyées et transformées
       - Gold   : données finales prêtes pour l'analyse

    Objectif : préparer une structure propre pour le Data Warehouse.
*/
use master;
go
if exists (select 1 from sys.databases where name='DataWeareHouse')
  begin 
    alter DATABASE DataWeareHouse set single_user with rollback immediate ;
    drop DATABASE DataWearHouse ;
  end ;
create database DataWeareHouse ;
go
use DataWeareHouse ;
go
create schema bronze ;
go
create schema silver ;
go
create schema gold ;
