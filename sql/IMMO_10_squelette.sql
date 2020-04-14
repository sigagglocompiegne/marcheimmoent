                                                                          
/*IMMO V1.0*/
/*Creation du squelette de la structure des données (tables, séquences, triggers,...) */
/*IMMO_10_SQUELETTE.sql */
/*PostGIS*/
/*GeoCompiegnois - http://geo.compiegnois.fr/ */
/*Auteur : Grégory Bodet */

/*
SOMMAIRE :
 - DROP
 - SEQUENCES
 - DOMAINES DE VALEUR
 - CLASSES OBJETS
 - CONTRAINTES
*/


-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                           DROP                                                          ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################


-- VUES 

 (à venir)

-- CLASSES

DROP TABLE IF EXISTS m_economie.geo_immo_objet CASCADE;
DROP TABLE IF EXISTS m_economie.an_immo_bien CASCADE;
DROP TABLE IF EXISTS m_economie.an_immo_bati CASCADE;
DROP TABLE IF EXISTS m_economie.an_immo_prop CASCADE;
DROP TABLE IF EXISTS m_economie.an_immo_comm CASCADE;
DROP TABLE IF EXISTS m_economie.an_immo_media CASCADE;
DROP TABLE IF EXISTS m_economie.lk_immo_objet CASCADE;
DROP TABLE IF EXISTS m_economie.lk_immo_occupant CASCADE;
DROP TABLE IF EXISTS m_economie.lk_immo_bienbati CASCADE;

-- DOMAINES DE VALEUR

DROP TABLE IF EXISTS m_economie.lt_immo_ityp CASCADE;
DROP TABLE IF EXISTS m_economie.lt_immo_dbien CASCADE;
DROP TABLE IF EXISTS m_economie.lt_immo_dbati CASCADE;
DROP TABLE IF EXISTS m_economie.lt_immo_tbien CASCADE;
DROP TABLE IF EXISTS m_economie.lt_immo_etat CASCADE;


--SEQUENCES

DROP SEQUENCE m_economie.geo_immo_objet_seq;
DROP SEQUENCE m_economie.an_immo_bien_seq;
DROP SEQUENCE m_economie.an_immo_comm_seq ;
DROP SEQUENCE m_economie.an_immo_bati_seq;
DROP SEQUENCE m_economie.an_immo_prop_seq;
DROP SEQUENCE m_economie.an_immo_media_seq;

--TRIGGERS

DROP TRIGGER IF EXISTS  ON m_economie. ;



-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                         SEQUENCE                                                        ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################


--############################################################ geo_immo_objet_seq ##################################################

--############################################################ an_immo_bien_seq ##################################################

--############################################################ an_immo_comm_seq ##################################################

--############################################################ an_immo_bati_seq ##################################################

--############################################################ an_immo_prop_seq ##################################################

--############################################################ an_immo_media_seq ##################################################


-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                    DOMAINES DE VALEURS                                                  ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################


--############################################################ lt_immo_ityp ##################################################

CREATE TABLE m_reseau_sec.lt_immo_ityp
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_immo_ityp_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

INSERT INTO m_economie.lt_immo_ityp(code, valeur)
    VALUES
	('10','Terrain vierge'),
	('21','Local (Bâtiment non divisé)'),
	('22','Local indépendant divisé'),
	('23','Local non identifié dans un bâtiment divisible');

COMMENT ON TABLE m_economie.lt_immo_ityp
  IS 'Code permettant de décrire le type d''objet saisie';
COMMENT ON COLUMN m_economie.lt_immo_ityp.code IS 'Code du type d''objet immobilier saisi';
COMMENT ON COLUMN m_economie.lt_immo_ityp.valeur IS 'Valeur du type d''objet immobilier saisi';

--############################################################ lt_immo_dbati ##################################################

CREATE TABLE m_reseau_sec.lt_immo_dbati
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  CONSTRAINT lt_immo_dbati_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

INSERT INTO m_economie.lt_immo_dbati(code, valeur)
    VALUES
	('0','Non renseigné'),
	('1','Double vitrage'),
	('2','Site clôturé'),
	('3','Places de parking'),
	('4','Murs périphériques (bardage métallique…)'),
	('5','Ossature (couverture bac acier…)'),
	('6','Menuiserie aluminium'),
	('7','Accès sécurisé'),
	('8','Système d''alarme'),
	('9','Parties communes'),
	('10','Portes de plain-pied),
	('11','Charge au sol);

COMMENT ON TABLE m_economie.lt_immo_dbati
  IS 'Code permettant de décrire la description du bien';
COMMENT ON COLUMN m_economie.lt_immo_dbati.code IS 'Code du type décrivant des éléments du bâtiment';
COMMENT ON COLUMN m_economie.lt_immo_dbati.valeur IS 'Valeur du type décrivant des éléments du bâtiment';

	
-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                        CLASSES OBJETS                                                   ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################


--################################################################# NAME #######################################################





-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                        CONTRAINTES                                                      ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################




