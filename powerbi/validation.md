# Vérification du rapport

Contrôles effectués le 12 octobre 2026 sur `localhost\SQLEXPRESS`, base `DataWeareHouse`, puis sur le modèle chargé dans Power BI Desktop.

## Résultats SQL et DAX

| Indicateur | SQL | DAX Power BI | Résultat |
| --- | ---: | ---: | --- |
| Chiffre d'affaires | 29 356 250 | 29 356 250 | Identique |
| Commandes distinctes | 27 659 | 27 659 | Identique |
| Unités vendues | 60 423 | 60 423 | Identique |
| Clients actifs | 18 484 | 18 484 | Identique |
| Panier moyen | 29 356 250 / 27 659 | 1 061,36338985502 | Identique |
| Lignes sans date | 19 | 19 | Identique |
| CA sans date | 4 992 | 4 992 | Identique |

Les 60 398 lignes de vente sont chargées depuis la vue Gold. Les dimensions contiennent 18 484 clients et 295 produits actuels. Les contrôles SQL n'ont trouvé ni doublon de clé technique dans les dimensions, ni vente sans clé client ou produit.

## Bilan annuel

| Année | CA SQL et DAX | Évolution affichée |
| --- | ---: | ---: |
| Sans date | 4 992 | Non applicable |
| 2010 | 43 419 | Vide : année partielle |
| 2011 | 7 075 088 | Vide : année précédente partielle |
| 2012 | 5 842 231 | -17,43 % |
| 2013 | 16 344 878 | +179,77 % |
| 2014 | 45 642 | Vide : année partielle |
| Total | 29 356 250 | Vide : total multiannuel |

Les lignes sans date contribuent au total général sans filtre temporel. Elles n'apparaissent pas dans les mois datés. Un filtre calendrier exclut ces lignes.

## Vérification Power BI Desktop

- Le projet est ouvert avec succès dans Power BI Desktop.
- L'actualisation des quatre tables réussit.
- Les mesures sont interrogées directement dans le modèle local chargé, et pas seulement vérifiées comme texte.
- La page Synthèse affiche les cartes, la courbe mensuelle, les catégories, les pays et le tableau annuel.
- Les pages Produits et Clients sont ouvertes et contrôlées visuellement avec les données chargées.
- Une version PBIX est enregistrée avec les données importées ; les trois aperçus proviennent de Power BI Desktop.
- Les mesures de croissance renvoient un résultat vide pour les comparaisons incomplètes et le total multiannuel.

## Limites

Ces contrôles vérifient la cohérence entre le rapport et les vues Gold actuelles. Ils ne constituent pas un audit complet de toutes les règles de nettoyage des couches Bronze et Silver. L'actualisation dans Power BI Service n'a pas été configurée ; elle nécessite un accès au SQL Server local, généralement via une passerelle.
