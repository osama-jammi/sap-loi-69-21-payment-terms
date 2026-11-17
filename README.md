# SAP – Rapport de conformité aux délais de paiement (loi 69-21, Maroc)

Extension SAP S/4HANA écrite en ABAP moderne (CDS, RAP) qui calcule les pénalités de retard de paiement fournisseurs prévues par la loi marocaine 69-21, à partir des vraies factures du système.

## Le problème

Au Maroc, la loi 69-21 impose des délais de paiement entre entreprises : 60 jours par défaut, 120 jours maximum si les parties se sont accordées, comptés à partir de la date de facture. Au-delà, l'entreprise doit payer une pénalité au Trésor : le taux directeur de Bank Al-Maghrib pour le premier mois de retard, puis 0,85 % par mois ou fraction de mois supplémentaire, sur le montant TTC. Les entreprises doivent aussi déclarer leurs délais de paiement à la DGI.

Dans SAP, rien de natif ne calcule cela. Beaucoup d'entreprises le font à la main dans Excel.

> Ce dépôt est un projet technique, pas un conseil juridique. Taux, plafonds et fréquence de déclaration doivent être vérifiés sur les sources officielles (DGI, Bank Al-Maghrib).

## Exemple (couvert par un test unitaire)

Facture de 100 000 MAD TTC payée avec 3 mois de retard, taux directeur 2,25 % :

| Mois de retard | Taux |
|---|---|
| 1er mois | 2,25 % |
| 2e mois | + 0,85 % |
| 3e mois | + 0,85 % |
| **Total** | **3,95 % = 3 950 MAD** |

## Architecture

```
I_OperationalAcctgDocItem  (vue standard SAP, factures fournisseurs)
        │
ZI_PTC_INVOICE             (vue CDS : factures payées + jours de retard)
        │
ZCL_PTC_PENALTY            (calcul de la pénalité, testé en ABAP Unit)
ZPTC_PARAM                 (taux directeur par période de validité)
        │
ZCL_PTC_RUN                (rapport console par fournisseur et trimestre)
ZCL_PTC_QUERY / ZC_PTC_SUMMARY / ZUI_PTC_SUMMARY  (entité personnalisée + service OData V4)
```

Principes : clean core (aucun objet standard modifié, uniquement des vues et API publiées), taux lu dans une table et non écrit dans le code, logique de calcul séparée de l'accès aux données.

## Contenu du dépôt (`src/`)

| Fichier | Rôle |
|---|---|
| `zcl_ptc_penalty.clas.abap` + `.testclasses.abap` | Calcul de la pénalité et tests unitaires |
| `zi_ptc_invoice.ddls.asddls` | Vue CDS des factures fournisseurs payées avec jours de retard |
| `zptc_param.tabl.astabl` | Table de paramètres (taux directeur, délai par défaut) |
| `zcl_ptc_init_param.clas.abap` | Remplit la table de paramètres |
| `zcl_ptc_run.clas.abap` | Rapport console : pénalités par fournisseur et par trimestre |
| `zc_ptc_summary.ddls.asddls` | Entité personnalisée pour l'écran Fiori |
| `zcl_ptc_query.clas.abap` | Fournit les données de l'entité personnalisée |
| `zui_ptc_summary.srvd.srvdsrv` | Définition du service OData |

## Version démo (sans données comptables réelles)

Si la vue standard `I_OperationalAcctgDocItem` n'est pas disponible ou si le système ne contient aucune facture fournisseur, le dossier `src/demo/` fournit une alternative :

| Fichier | Rôle |
|---|---|
| `zptc_invoice.tabl.astabl` | Table de factures fournisseurs fictives |
| `zcl_ptc_fill_invoice.clas.abap` | Remplit la table (24 factures, 3 fournisseurs, retards variés) |
| `zi_ptc_invoice.ddls.asddls` | Version de `ZI_PTC_INVOICE` qui lit cette table à la place de la vue standard |

Marche à suivre : activer la table, exécuter `ZCL_PTC_FILL_INVOICE` (F9), puis remplacer le code de `ZI_PTC_INVOICE` par celui de `src/demo/`. Le reste du projet ne change pas. Les données sont fictives.

## Utilisation

1. Importer les objets dans un package (ou les recréer dans ADT / Eclipse).
2. Activer la table `ZPTC_PARAM`, puis exécuter `ZCL_PTC_INIT_PARAM` (F9) pour y mettre le taux.
3. Exécuter `ZCL_PTC_RUN` (F9) : la console affiche, par fournisseur et par trimestre, le nombre de factures payées en retard, le montant et la pénalité, avec le total à payer au Trésor.
4. Tests : exécuter les tests unitaires de `ZCL_PTC_PENALTY` (Ctrl + Shift + F10).

Testé sur un système SAP Education S/4HANA (Eclipse ADT).

## État du projet

Fait :
- Calcul de pénalité avec tests unitaires
- Lecture des factures fournisseurs réelles via une vue CDS
- Taux directeur paramétrable par période
- Regroupement par fournisseur et par trimestre
- Entité personnalisée et service OData définis

Limites connues :
- La publication du service OData échoue sur le système de formation utilisé (tous les mandants ont le rôle « Customizing »), donc l'écran Fiori n'a pas été démontré.
- Le nombre de mois est approximé par tranches de 30 jours.
- Le délai convenu (60/120 jours) et les montants en litige ne sont pas encore pris en compte.
- Le filtre par fournisseur n'est pas appliqué dans `ZCL_PTC_QUERY`.

Prochaines étapes :
- Version avec une table `Z` source de données, pour publier l'écran Fiori sur SAP BTP ABAP Environment (essai gratuit)
- Délai convenu par fournisseur et montant en litige
- Export Excel pour la déclaration

## Captures

Voir le dossier `docs/` (test unitaire, console, limite de publication).

## Licence

MIT, voir [LICENSE](LICENSE).
