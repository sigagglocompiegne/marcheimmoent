![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation utilisateur du module Marché immobilier dans l'application Activité Economique #

**Initialisation du module Marché Immobilier** :

Afin que l'ensemble des données et des fonctionnalités puissent être accessibles, vous devez initilaiser les informations immobilières dans l'application Activité Economique (cf ci-dessous)

![picto](init_immo_1.png)

- 1 - Ouvrir le menu CARTE
- 2 - Désactiviter le groupe Lots
- 3 - Vous pouvez également désactiver la couche des sites d'activité pour plus de lisibilité
- 4 - Activer le groupe Immobilier

**Pour tous les utilisateurs ayant le droit d'accès à l'application** :

- Documentation disponible :
   * [Accès aux informations d'un bâtiment ou d'un local d'activités](doc_util_util_1.md)
   * [Recherche d'un bien disponible à la vente et/ou à la location](doc_util_util_2.md)

**Pour l'administrateur des données** :

Cette documentation est spécifique aux personnes intégrant de la donnée depuis l'application Web.

- La modification de l'inventaire

Si le bien est déjà saisi, l'accès à ces informations pour compléments ou ajouts d'informations (média, occupants, locaux éventuels pour les bâtiments concernés) est possible par simple clic sur l'objet à partir de la carte. Ce fonctionnel permet d'accéder de nouveau à la fiche d'informations pour la modifier.

- La suppression de l'inventaire

   * pour un terrain : suppression classique de l'objet et des informations liées dans la base
   * pour un local (Bâtiment non divisé) : suppression de l'objet et des informatiosn liées dans la base, y compris les information du bâtiment
   * pour un local indépendant divisé : la suppression de tous les objets (ou locaux) appartenant à un même bâtiment supprime par défaut toutes les informations, y compris celles du bâtiment d'appartenance. Si il reste 1 local d'appartenance, les informations du bâtiment demeurent et le bâtiment est reconstruit virtuellement avec les locaux restant.
   * pour un local non identifié dans un bâtiment divisible : chaque local attaché à un bâtiment peut-être suppprimé indivuellement. La suppression de tous les locaux n'entraine pas ici la suppression des informations du bâtiment. Pour supprimer définitivement ces informations, il faut EDITER la fiche et cliquer sur SUPPRIMER.

Pour supprimer un objet saisi, un simple clic sur l'objet à partir de la carte vous ouvre la fiche d'informations. Rendez la fiche d'informations éditable en cliquant sur EDITER, puis cliquez sur SUPPRIMER. Le développement fonctionnel supprime automatiquement les objets et les informations liées de cette manière :

- La saisie dans l'inventaire

La saisie des objets doit respecter les principes et les règles de modélisation édictées [ici](https://github.com/sigagglocompiegne/marcheimmoent/blob/master/gabarit/livrables.md).

- La documentation ci-après s'attachera à indiquer les outils fonctionnels de l'application Web à utiliser pour la saisie et la gestion des données.
   * [Saisir un bien immobilier de type terrain](doc_util_admin_1.md)
   * [Saisir un bâtiment contenant 1 ou n locaux non identifiables](doc_util_admin_2.md)
   * [Saisir des locaux identifiables reconstruisant le bâtiment](doc_util_admin_3.md)
   * [Gérer les bâtiments d'affectation](doc_util_admin_4.md)
