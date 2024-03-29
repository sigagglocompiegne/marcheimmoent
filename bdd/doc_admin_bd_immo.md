![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base des bâtiments et locaux d'activité #

(reste à venir les éléments descriptifs d'un local qui seront intégrés à cette documentation)

## Principes
 
 **Généralités** :
 
Le service du développement économique exploite déjà une base de données liée à son domaine d'activité à savoir le suivi de la commercialisation du foncier à vocation économique dans les zones aménagées par l'Agglomération de la Région de Compiègne. 

Ce suivi est complété par une information sur les contacts et les emplois par entreprises. Ces données locales viennent enrichir la base SIRENE de l'Insee sur les établissement mise à jour trimestriellement et géolocalisés à l'adresse. L'ensemble de ces informations permet d'extraire des indicateurs de suivis sur les ZAE (zones d'activités économiques).

Une bourse aux locaux (BAL) a également été mise en place pour répondre aux demandes d'entreprises cherchant à s'implanter sur le territoire. Cette BAL ne répond pas entièrement aux attentes du service et une réflexion s'est engagée pour que le service puisse disposer d'une vision globale d'occupation des locaux et de proposer des terrains privés à la vente. 

Cette orientation pourrait également déboucher sur un observatoire des commerces ou locaux de centre-ville à moyen ou long terme.
 
 **Résumé fonctionnel** :
 
La donnée a été construite de façon à pouvoir réaliser un inventaire cartographique des bâtiments et locaux d'activité selon la composition de ces dits bâtiments. 3 scénarii de construction ont été établis en dehors de la gestion des terrains qui se réalise indépendemment.

- le local et le bâtiment en font qu'une seule entité : Local (Bâtiment non divisé)
- le bâtiment contient au moins 2 locaux mais ils ne sont identifiables (localisation ou numérisation impossible) : Local non identifié dans un bâtiment divisible
- le bâtiment est composé d'au moins 2 locaux identifiables (dans ce cas le bâtiment est reconstruit virtuellement par l'association des locaus qui le composent) : Local indépendant divisé

L'adressage des bâtiments a été réalisé sur la Base Adresse Local (BAL) permettant ainsi de récupérer automatiquement les établissemets occupants déjà géolocalisés sur la BAL. La gestion des établissements au local n'est pas encore pris en compte (en cours de réfléxion), seul un attribut permet de saisir librement pour le moment un ocucpant ou une occupation.

En résumer, l'objectif est d'identifier un bâtiment d'activité (réalisé par l'inventaire cartographique), celui-ci contient n locaux d'activités occupés par un établissement. Ces locaux peuvent être ensuite mis sur le marché de la location ou de la vente. Lorsque que celui-ci n'est plus disponible, il n'est plus sur le marché et occupé par un nouvel établissement. L'atteinte d'une connaissance exhausitve des locaux à l'intérieur des bâtiments n'a pas éta fixé à ce stade. Cete base de données s'alimentera avec les données récoltées par le service gestionnaire.

L'inventaire cartographique sera mené en priorité sur les ZAE (zone d'aménagement économique) avant d'être étendu aux autres sites d'activités et éventuellement en centre-ville.

## Modèle relationnel simplifié

![picto](mcd_immo.png)

## Schéma fonctionnel

![picto](schema_fonctionnel_bien_immo_v2.png)

## Dépendances

La base de données du suivi du marché de l'immobilier d'entreprises ne s'appuie sur aucun référentiel préexistant majeurs pour être implémentée. Néanmoins, son usage repose sur des relations avec des listes de valeurs communes ou des référentiels géographiques pouvant perturber son bon fonctionnement au travers de l'application WebSIG développée.

|Schéma | Table/Vue | Description | Usage |
|:---|:---|:---|:---|
|r_objet| lt_src_geom | Liste de valeurs | Valeurs décrivant le référentiel géographique utilisé pour la saisie des objets graphiques|
|m_economie| lk_adresseetablissement | Liste de relation | Relation entre les adresses et les établissements|
|s_sirene| an_etablissement_api | classe d'objets | données de la base de données SIRENE de l'Insee|
|x_apps| xapps_geo_vmr_adresse | classe d'objets | données de la Base Locale des Adresses (BAL)|

## Séquences 

Il y a 7 séquences. Cinq sont dédiées aux classes métiers et composées d'une lettre et d'un serial afin de mieux les distinguer dans la structure interne des données. La gestion de la base imliquant des écritures d'identifiant métiers dans plusieurs tables, cette structuration de séquences est une aide à l'administration.

Les 2 autres séquences sont uniquement de type serial pour la gestion d'identifiant unique interne à la gestion des classes correspondantes.


## Classes d'objets

L'ensemble des classes d'objets de gestion sont stockés dans le schéma `m_economie` et celles applicatives dans le schéma 
`x_apps`.

 ### classes d'objets de gestion :
  
   `geo_immo_bien` : table des attributs métiers permettant de gérer l'ensemble des éléments de la primitive graphique (terrain, local ou bâtiment contenant un ou des locaux).
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idimmo|Identifiant unique de l'objet|text| |
|idbati|Identifiant unique bu bâtiment|text| |
|idsite|Identifiant du site d'activité d'appartenance|character varying(7)| |
|sup_m2|Superficie de l'objet en m²|integer| |
|ityp|Type d'occupation|character varying(2)| |
|observ|Observations|character varying(1000)| |
|op_sai|Opérateur de saisie|character varying(25)| |
|date_sai|Date de saisie|timestamp without time zone|now()|
|date_maj|Date de mise à jour|timestamp without time zone| |
|src_geom|Source du référentiel géographique pour le positionnement du nœud|character varying(2)|'00'::character varying|
|src_date|Année du référentiel de saisi|integer| |
|insee|Code Insee de la ou des communes d'assises|character varying(25)| |
|commune|Libellé de la ou des communes d'assises|character varying(160)| |
|geom|Attribut de géométrie|USER-DEFINED| |


Particularité(s) à noter : aucune

---
   `an_immo_bien` : table des attributs métiers permettant de gérer l'ensemble des éléments décrivant le bien (terrain ou local)
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idbien|Identifiant unique du bien|text| |
|idimmo|Identifiant unique de l'objet bien|text| |
|tbien|Type de bien|character varying(4)| |
|libelle|Libellé du bien|character varying(254)| |
|pdp|Bien en pas-de-porte|boolean|false|
|lib_occup|Libellé de l'occupant ou détail sur le type d'occupation (si pas un établissement lié)|character varying(150)| |
|adr|Adresse litérale (si différente du bâtiment)|character varying(254)| |
|adrcomp|Complément d'adresse|character varying(100)| |
|surf_p|Surface totale de plancher totale en m²|integer| |
|source|Source de la mise à jour|character varying(254)| |
|refext|Lien vers un site présentant le terrain|character varying(254)| |
|observ|Observations|character varying(1000)| |
|surf_rdc|Surface en rez-de-chaussée|integer|0|
|surf_etag|Surface à l'étage|integer|0|
|surf_mezza|Surface en mezzanine|integer|0|
|surf_acti|Surface  en activité (atelier)|integer|0|
|surf_bur|Surface en bureau|integer|0|


Particularité(s) à noter : aucune

---

 `an_immo_bati` : table des attributs métiers permettant de gérer l'ensemble des éléments décrivant le bâtiment
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idbati|Identifiant du bâtiment|text| |
|idimmo|Identifiant de l'objet|text| |
|ityp|Type d'occupation (incrémentation automatique par la table geo_immo_bien pour la gestion de la liste des domaines des bâtiments pour un type local non identifié)|character varying(2)| |
|libelle|Libellé du bâtiment|character varying(254)| |
|surf_p|Surface de plancher total du bâtiment renseigné par l'utilisateur|integer| |
|mprop|Type de propriétaire (unique ou en copropriété). La valeur true indique qu'il s'agit d'une copropriété|boolean|false|
|observ|Observations|character varying(1000)| |
|bati_nom|Nom d'un bâtiment|boolean|false|


Particularité(s) à noter : cette classe d'objets peut être alimentée indépendemment lorsqu'il s'agit d'un bâtiment reconstruit virtuellement par les locaux qui le composent. Les locaux sont affectés alors à un bâtiment listé comme appartemant au type 22.

---

 `an_immo_propbati` : table des attributs métiers permettant de gérer l'ensemble des éléments décrivant le propriétaire du bâtiment
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idprop|Identifiant du propriétaire|text| |
|idbati|Identifiant du bâtiment|text| |
|propnom|Nom du propriétaire|character varying(100)| |
|proptel|Téléphone du propriétaire|character varying(14)| |
|proptelp|Téléphone portable du propriétaire|character varying(14)| |
|propmail|Email du propriétaire|character varying(80)| |
|observ|Observations|character varying(1000)| |


Particularité(s) à noter : aucune

---

 `an_immo_propbien` : table des attributs métiers permettant de gérer l'ensemble des éléments décrivant le propriétaire du local ou du terrain
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idprop|Identifiant du propriétaire|text| |
|idbien|Identifiant du bien immobilier ou local|text| |
|propnom|Nom du propriétaire|character varying(100)| |
|proptel|Téléphone du propriétaire|character varying(14)| |
|proptelp|Téléphone portable du propriétaire|character varying(14)| |
|propmail|Email du propriétaire|character varying(80)| |
|observ|Observations|character varying(1000)| |


Particularité(s) à noter : aucune

---

 `an_immo_comm` : table des attributs métiers permettant de gérer l'ensemble des éléments liés à la commercialisation et aux conditions financières de l'occupation actuelle
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idcomm|Identifiant unique de la commercialisation|text| |
|idimmo|Identifiant de l'objet bien|text| |
|idbien|Identifiant du bien|text| |
|prix_a|Prix d'acquisition du bien occupé|integer| |
|prix_am|Prix d'acquisition au m² du bien occupé|integer| |
|loyer_a|Loyer actuel du bien|integer| |
|loyer_am|Loyer actuel du bien au m²|integer| |
|bail_a|Montant du bail actuel du bien|integer| |
|prix|Prix total|integer| |
|prix_m|Prix au m²|integer| |
|loyer|Loyer total|integer| |
|loyer_m|Loyer au m²|integer| |
|bail|Montant du Bail|integer| |
|comm|Nom du commercialisateur|character varying(150)| |
|commtel|Téléphone du commercialisateur|character varying(14)| |
|commtelp|Téléphone portable du commercialisateur|character varying(14)| |
|commmail|Email du commercialisateur|character varying(80)| |
|etat|Etat de la commercialisation|character varying(2)| |
|refext|Référence externe d'un site internet présentant une fiche de commercialisation|character varying(254)| |
|observ|Observations|character varying(1000)| |

Particularité(s) à noter : aucune

---

 `an_immo_desc` : table des attributs métiers permettant de gérer les éléments descriptifs d'un local (non encore implémenté, en attente des éléments du service métier)
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|iddesc|Identifiant unique de la description|text| |
|idbien|Identifiant du bien|text| |
|observ|Observations (éléments descriptifs de l'ancienne bourse aux locaux pour le moment)|character varying(1000)| |

Particularité(s) à noter : aucune

---

`lk_immo_batiadr` : table de liens permettant l'affectation du bâtiment à une adresse de la BAL
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|id|Identifiant unique de l'occupation|integer|nextval('m_economie.lk_immo_batiadr_seq'::regclass)|
|idbati|Identifiant du bâtiment|text| |
|id_adresse|Identifiant adresse de la BAL|bigint| |

Particularité(s) à noter : aucune

---

`an_immo_media` : table permettant de gérer les documents joints aux locaux et aux bâtiments
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|id|Identifiant de l'objet saisi|text| |
|media|Champ Média de GEO|text| |
|miniature|Champ miniature de GEO|bytea| |
|n_fichier|Nom du fichier|text| |
|t_fichier|Type de média dans GEO|text| |
|op_sai|Opérateur de saisie (par défaut login de connexion à GEO)|character varying(20)| |
|date_sai|Date de la saisie du document|timestamp without time zone| |
|l_doc|Titre du document ou légère description|character varying(100)| |
|alaune|Gestion des photographies en une des annonces immobilières|booléen|false|
|gid|Compteur (identifiant interne)|integer|nextval('m_economie.an_immo_media_seq'::regclass)|

Particularité(s) à noter : aucune

### classes d'objets de gestions métiers sont classés dans le schéma m_economie :

`geo_v_immo_bien_terrain` : vue permettant de gérer l'insertion et la mise jour des biens de type terrain.

`geo_v_immo_bien_locident` : vue permettant de gérer l'insertion et la mise jour les locaux identifiés reconstruisant le bâtiment qui s'en composent.

`geo_v_immo_bien_locnonident` : vue permettant de gérer l'insertion et la mise jour les locaux non identifiables dans un même bâtiment (1 à n locaux).

`an_v_immo_bien_locnonident` : vue complémentaire à la précedent permettant de gérer l'insertion et la mise jour des n locaux.

### classes d'objets applicatives métiers sont classés dans le schéma x_apps :
 
`x_apps.xapps_geo_vmr_immo_bati` : Vue matérialisée rafraichie à chaque insertion ou modification présentant le bâtiment reconstitué à partir des locaux indépendant divisés d'un même bâtiment (pour la cartographie GEO de l'application et permettant de gérer l'affichage des libellés des bâtimnents) 

`x_apps.xapps_geo_vmr_immo_etat` : Vue matérialisée rafraichie à chaque insertion ou modification présentant l'état de disponibilités d'un local/terrain (en vente, en location) et intégrée à la cartographie de l'application GEO 

`x_apps.xapps_an_vmr_immo_bati` : vue matérialisée rafraichie à chaque insertion ou modification pour le calcul de statistiques remontées aux bâtiments (nb de locaux saisis et surface de plancher total saisie pour chaque local appartenant aux bâtiments)

### classes d'objets applicatives grands publics sont classés dans le schéma x_apps_public :

Sans objet


### classes d'objets opendata sont classés dans le schéma x_opendata :

Sans objet

---

## Liste de valeurs

`lt_immo_ityp` : Liste des types de biens immobilier saisis

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code interne des types de bien saisi |character(2)| |
|valeur|Libellé des types de bien saisi |character varying(80)| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ code 

Valeurs possibles :

|Code|Valeur|
|:---|:---|
|10|Terrain|
|21|Local (Bâtiment non divisé)|
|22|Local indépendant divisé|
|23|Local non identifié dans un bâtiment divisible|

---

`lt_immo_tbien` : Liste des usages des biens immobilier propre aux types saisis

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code interne des usages des biens|character(2)| |
|valeur|Libellé des usages des biens |character varying(80)| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ code 
* Afin d'effectuer des filtres diversifiés dans l'application WebSIG, les types de biens pour les locaux ont été dupliqués mais reste unique. A l'exploitation, bien intégrer l'ensemble des codes pour les valeurs communes.

Valeurs possibles :

|Code|Valeur|
|:---|:---|
|1010|Terrain vierge|
|1110|Parking|
|1210|Surface de dépôt ou de stockage|
|1310|Surface agricole|
|1410|Terrain avec bâtiment léger en activité|
|2021|Bureau|
|2121|Commerce|
|2221|Activité|
|2022|Bureau|
|2122|Commerce|
|2222|Activité|
|2023|Bureau|
|2123|Commerce|
|2223|Activité|

---

`lt_immo_etat` : Liste des valeurs décrivant l'état de disponibilité d'un bien

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code interne des disponibilités du bien|character(2)| |
|valeur|Libellé des disponibilités du bien |character varying(80)| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ code 

Valeurs possibles :

|Code|Valeur|
|:---|:---|
|10|Disponible à la vente (vacant)|
|20|Disponible à la vente (occupé)|
|30|Disponible à la location|
|40|Disponible à la vente ou à la location|
|ZZ|Non concerné (occupé)|

## Projet QGIS pour la gestion

Un Projet QGIS été réalisé pour la saisie de l'inventaire cartographique propre au service SIG et stockée ici
Y:\Ressources\4-Partage\3-Procedures\QGIS\ECO_MARCHE_IMMO.qgs


## Export Open Data

Sans objet

---





