/*IMMO V1.0*/
/*Creation des vues et triggers nécessaires à la gestion via l'application web-métier */
/*IMMO_20_VUES_GESTION.sql */
/*PostGIS*/
/* GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet*/


-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                           DROP                                                          ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################

-- TRIGGERS

DROP TRIGGER IF EXISTS t_t1_gestion_immolocnonident_bien ON m_economie.an_v_immo_bien_locnonident;
DROP TRIGGER IF EXISTS t_t1_gestion_immolocident ON m_economie.geo_v_immo_bien_locident;
DROP TRIGGER IF EXISTS t_t2_refresh_stat_bati ON m_economie.geo_v_immo_bien_locident;
DROP TRIGGER IF EXISTS t_t1_gestion_immolocnonident ON m_economie.geo_v_immo_bien_locnonident;
DROP TRIGGER IF EXISTS t_t2_refresh_stat_bati ON m_economie.geo_v_immo_bien_locnonident;
DROP TRIGGER IF EXISTS t_t2_refresh_stat_bati ON m_economie.geo_v_immo_bien_locunique;
DROP TRIGGER IF EXISTS t_t1_gestion_immoterrain ON m_economie.geo_v_immo_bien_terrain;

--VUES

DROP VIEW IF EXISTS x_apps.xapps_an_vmr_immo_bati;
DROP VIEW IF EXISTS an_v_immo_bien_locnonident;
DROP VIEW IF EXISTS geo_v_immo_bien_locident;
DROP VIEW IF EXISTS geo_v_immo_bien_locnonident;
DROP VIEW IF EXISTS geo_v_immo_bien_terrain;

--FONCTIONS

DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immo_insertbati();
DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immo_statbati();
DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immolocident();
DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immolocnonident();
DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immolocnonident_bien();
DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immoterrain();
DROP FUNCTION IF EXISTS m_economie.ft_m_gestion_immo_libelle();

-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      FONCTIONS                                                            ###
-- ###                                                                                                                           ###
-- #################################################################################################################################

-- ############################################################ ft_m_gestion_immo_insertbati #########################################     

-- FUNCTION: m_economie.ft_m_gestion_immo_insertbati()

-- DROP FUNCTION m_economie.ft_m_gestion_immo_insertbati();

CREATE FUNCTION m_economie.ft_m_gestion_immo_insertbati()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN

IF NEW.idbati IS NULL OR NEW.idbati = '' OR NEW.idbati NOT LIKE 'BA%' THEN    
     
	 NEW.idbati := 'BA' || (SELECT nextval('m_economie.an_immo_bati_seq'::regclass));
	 NEW.ityp := '22'; -- force le type d''occupation à local divisé dans un bâtiment pour gérer l'affichage du bâtiment dans la liste de choix
		       -- à l'enregistrement le bâtiment prendra la valeur définitf de l'occupation de l'objet saisi avec le trigger after
     NEW.libelle := NEW.libelle;
	
END IF ;
     return new ;

END;

$BODY$;

COMMENT ON FUNCTION m_economie.ft_m_gestion_immo_insertbati()
    IS 'Fonction gérant l''insertion d'' un nouvel identifiant du bâtiment (cas d''ajout de valeur depuis GEO)';


-- ############################################################ ft_m_gestion_immo_statbati #########################################                                        
                                        
-- FUNCTION: m_economie.ft_m_gestion_immo_statbati()

-- DROP FUNCTION m_economie.ft_m_gestion_immo_statbati();

CREATE FUNCTION m_economie.ft_m_gestion_immo_statbati()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN
-- rafraichissement de la vue matérialisée permettant de calculer les surfaces au sol, planché et nb de biens aux bâtiments (déduit de la saisie utilisateur)
REFRESH MATERIALIZED VIEW x_apps.xapps_an_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_etat;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_loc;

return new;

END;

$BODY$;



-- ############################################################ ft_m_gestion_immolocident #########################################
                                        

-- FUNCTION: m_economie.ft_m_gestion_immolocident()

-- DROP FUNCTION m_economie.ft_m_gestion_immolocident();

CREATE FUNCTION m_economie.ft_m_gestion_immolocident()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE v_idimmo text;
DECLARE v_idbien text;
--DECLARE v_idbati text;
DECLARE v_idprop text;
DECLARE v_idcomm text;
DECLARE v_iddesc text;

BEGIN

IF (TG_OP='INSERT') then

v_idimmo := ('O'::text || nextval('m_economie.geo_immo_bien_seq'::regclass));
v_idbien := ('B'::text || nextval('m_economie.an_immo_bien_seq'::regclass));
--v_idbati := ('BA'::text || nextval('m_economie.an_immo_bati_seq'::regclass));
v_idprop := ('P'::text || nextval('m_economie.an_immo_prop_seq'::regclass));
v_idcomm := ('C'::text || nextval('m_economie.an_immo_comm_seq'::regclass));
v_iddesc := ('D'::text || nextval('m_economie.an_immo_desc_seq'::regclass));

INSERT INTO m_economie.geo_immo_bien (idimmo,idbati,idsite,sup_m2,ityp,observ,op_sai,date_sai,date_maj,src_geom,src_date,insee,commune,geom)
SELECT v_idimmo,NEW.bati_appart,
(SELECT DISTINCT idsite FROM r_objet.geo_objet_ope WHERE st_intersects(geo_objet_ope.geom,ST_PointOnSurface(NEW.geom)) = true AND idsite <> '60159ak'),
st_area(NEW.geom),'22',NEW.observ_obj,NEW.op_sai,now(),null,NEW.src_geom,NEW.src_date,
(select string_agg(insee, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
(select string_agg(commune, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
NEW.geom;

INSERT INTO m_economie.an_immo_bien (idbien,idimmo,tbien,libelle,pdp,lib_occup,adr,adrcomp,surf_p,source,refext,observ,surf_rdc,surf_etag,surf_mezza,surf_acti,surf_bur,op_sai,date_sai)
SELECT v_idbien,v_idimmo,NEW.tbien,NEW.libelle,false,NEW.lib_occup,NEW.adr,NEW.adrcomp,NEW.surf_p,NEW.source,NEW.refext_bien,NEW.observ_bien,
NEW.surf_rdc,NEW.surf_etag,NEW.surf_mezza,NEW.surf_acti,NEW.surf_bur,NEW.op_sai_bien,now();

INSERT INTO m_economie.an_immo_desc (iddesc,idbien,observ)
SELECT v_iddesc,v_idbien,NEW.observ_desc;

INSERT INTO m_economie.an_immo_comm (idcomm,idimmo,idbien,prix_a,prix_am,loyer_a,loyer_am,bail_a,prix,prix_m,loyer,loyer_m,bail,comm,commtel,commtelp,commmail,etat,refext,observ,loyer_amp,loyer_mp) 
SELECT v_idcomm,v_idimmo,v_idbien,NEW.prix_a,NEW.prix_am,NEW.loyer_a,NEW.loyer_am,NEW.bail_a,NEW.prix,NEW.prix_m,NEW.loyer,NEW.loyer_m,NEW.bail,NEW.comm,NEW.commtel,NEW.commtelp,NEW.commmail,NEW.etat,
NEW.refext_comm,NEW.observ_comm,NEW.loyer_amp,NEW.loyer_mp;

IF (SELECT COUNT(*) FROM m_economie.an_immo_propbati WHERE idbati = NEW.bati_appart) = 0 THEN
INSERT INTO m_economie.an_immo_propbati (idprop,idbati,propnom,proptel,proptelp,propmail,observ)
SELECT v_idprop,NEW.bati_appart,NEW.propnom_bati,NEW.proptel_bati,NEW.proptelp_bati,NEW.propmail_bati,NEW.observ_propbati;
END IF;

INSERT INTO m_economie.an_immo_propbien (idprop,idbien,propnom,proptel,proptelp,propmail,observ)
SELECT v_idprop,v_idbien,NEW.propnom_bien,NEW.proptel_bien,NEW.proptelp_bien,NEW.propmail_bien,NEW.observ_propbien;

/*
INSERT INTO m_economie.an_immo_bati (idbati,idimmo,ityp,libelle,surf_p,mprop,observ)
SELECT NEW.bati_appart,v_idimmo,'22',NEW.libelle_bati,NEW.surf_pbati,NEW.mprop,NEW.observ_bati;
*/

UPDATE m_economie.an_immo_bati SET idimmo = v_idimmo WHERE idbati = NEW.bati_appart AND idimmo IS NULL;
UPDATE m_economie.an_immo_bati SET surf_p = NEW.surf_pbati WHERE idbati = NEW.bati_appart AND surf_p IS NULL;

-- si l'identifiant adresse est saisie (uniquement via Gabarit QGIS interne au service SIG)
IF NEW.id_adresse > 0 THEN
INSERT INTO  m_economie.lk_immo_batiadr (id,idbati,id_adresse)
SELECT nextval('m_economie.lk_immo_batiadr_seq'::regclass),NEW.bati_appart,NEW.id_adresse;

END IF;

END IF;

IF (TG_OP='UPDATE') then

UPDATE  m_economie.geo_immo_bien SET
idsite = (SELECT DISTINCT idsite FROM r_objet.geo_objet_ope WHERE st_intersects(geo_objet_ope.geom,ST_PointOnSurface(NEW.geom)) = true AND idsite <> '60159ak'),
sup_m2 = st_area(NEW.geom),
observ = NEW.observ_obj,
op_sai = NEW.op_sai,
date_maj = now(),
src_geom = NEW.src_geom,
src_date = NEW.src_date,
insee = (select string_agg(insee, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
commune = (select string_agg(commune, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
geom = NEW.GEOM
WHERE idimmo = NEW.idimmo;

-- si l'identifiant adresse est modifié sans existance préalable (uniquement via Gabarit QGIS interne au service SIG)
IF (NEW.id_adresse IS NOT NULL AND OLD.id_adresse IS NULL)  THEN
INSERT INTO  m_economie.lk_immo_batiadr (id,idbati,id_adresse)
SELECT nextval('m_economie.lk_immo_batiadr_seq'::regclass),NEW.idbati,NEW.id_adresse;
END IF;

-- si l'identifiant adresse est modifié avec une existance préalable (uniquement via Gabarit QGIS interne au service SIG)
IF OLD.id_adresse IS NOT NULL AND OLD.id_adresse <> NEW.id_adresse THEN
UPDATE m_economie.lk_immo_batiadr SET id_adresse = NEW.id_adresse WHERE idbati = NEW.idbati;
END IF;

UPDATE  m_economie.an_immo_bien SET
tbien = NEW.tbien,
libelle = NEW.libelle,
lib_occup = NEW.lib_occup,
adr = NEW.adr,
adrcomp = NEW.adrcomp,
surf_p = NEW.surf_p,
source = NEW.source,
refext = NEW.refext_bien,
observ = NEW.observ_bien,
surf_rdc = NEW.surf_rdc,
surf_etag = NEW.surf_etag,
surf_mezza = NEW.surf_mezza,
surf_acti = NEW.surf_acti,
surf_bur = NEW.surf_bur,
op_sai = NEW.op_sai_bien,
date_maj = now()
WHERE idbien = NEW.idbien;

UPDATE  m_economie.an_immo_desc SET
observ = NEW.observ_desc
WHERE idbien = NEW.idbien;

UPDATE  m_economie.an_immo_comm SET
prix_a = NEW.prix_a,
prix_am = NEW.prix_am,
loyer_a = NEW.loyer_a,
loyer_am = NEW.loyer_am,
bail_a = NEW.bail_a,
prix = NEW.prix,
prix_m = NEW.prix_m,
loyer = NEW.loyer,
loyer_m = NEW.loyer_m,
bail = NEW.bail,
comm = NEW.comm,
commtel = NEW.commtel,
commtelp = NEW.commtelp,
commmail = NEW.commmail,
etat = NEW.etat,
refext = NEW.refext_comm,
observ = NEW.observ_comm,
loyer_amp = NEW.loyer_amp,
loyer_mp = NEW.loyer_mp
WHERE idcomm = NEW.idcomm;

UPDATE  m_economie.an_immo_propbati SET
propnom = NEW.propnom_bati,
proptel = NEW.proptel_bati,
proptelp = NEW.proptelp_bati,
propmail = NEW.propmail_bati,
observ = NEW.observ_propbati
WHERE idbati = NEW.idbati;

UPDATE  m_economie.an_immo_propbien SET
propnom = NEW.propnom_bien,
proptel = NEW.proptel_bien,
proptelp = NEW.proptelp_bien,
propmail = NEW.propmail_bien,
observ = NEW.observ_propbien
WHERE idbien = NEW.idbien;

UPDATE  m_economie.an_immo_bati SET
libelle = NEW.libelle_bati,
surf_p = NEW.surf_pbati,
mprop = NEW.mprop,
observ = NEW.observ_bati,
bati_nom = NEW.bati_nom
WHERE idbati = NEW.idbati;

END IF;

IF (TG_OP='DELETE') then

DELETE FROM m_economie.geo_immo_bien WHERE idimmo = OLD.idimmo;
DELETE FROM m_economie.an_immo_bien WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_desc WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_comm WHERE idcomm = OLD.idcomm;
DELETE FROM m_economie.an_immo_media WHERE id = OLD.idbien;
DELETE FROM m_economie.an_immo_propbien WHERE idbien = OLD.idbien;

IF (SELECT COUNT(*) FROM m_economie.geo_immo_bien WHERE idbati = OLD.idbati) = 0 THEN
DELETE FROM m_economie.an_immo_propbati WHERE idbati = OLD.idbati;
DELETE FROM m_economie.an_immo_bati WHERE idbati = OLD.idbati;
DELETE FROM m_economie.an_immo_media WHERE id = OLD.idbati;
DELETE FROM m_economie.lk_immo_batiadr WHERE idbati = OLD.idbati;

END IF;

REFRESH MATERIALIZED VIEW x_apps.xapps_an_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_etat;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_loc;
											   
END IF;

RETURN NEW;

END;

$BODY$;



-- ############################################################ ft_m_gestion_immolocnonident #########################################                                                                                          
                                                                                           
-- FUNCTION: m_economie.ft_m_gestion_immolocnonident()

-- DROP FUNCTION m_economie.ft_m_gestion_immolocnonident();

CREATE FUNCTION m_economie.ft_m_gestion_immolocnonident()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE v_idimmo text;
--DECLARE v_idbien text;
DECLARE v_idbati text;
DECLARE v_idprop text;
--DECLARE v_idcomm text;

BEGIN

IF (TG_OP='INSERT') then

v_idimmo := ('O'::text || nextval('m_economie.geo_immo_bien_seq'::regclass));
--v_idbien := ('B'::text || nextval('m_economie.an_immo_bien_seq'::regclass));
v_idbati := ('BA'::text || nextval('m_economie.an_immo_bati_seq'::regclass));
v_idprop := ('P'::text || nextval('m_economie.an_immo_prop_seq'::regclass));
--v_idcomm := ('C'::text || nextval('m_economie.an_immo_comm_seq'::regclass));

INSERT INTO m_economie.geo_immo_bien (idimmo,idbati,idsite,sup_m2,ityp,observ,op_sai,date_sai,date_maj,src_geom,src_date,insee,commune,geom)
SELECT v_idimmo,v_idbati,
(SELECT DISTINCT idsite FROM r_objet.geo_objet_ope WHERE st_intersects(geo_objet_ope.geom,ST_PointOnSurface(NEW.geom)) = true AND idsite <> '60159ak'),
st_area(NEW.geom),'23',NEW.observ_obj,NEW.op_sai,now(),null,NEW.src_geom,NEW.src_date,
(select string_agg(insee, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
(select string_agg(commune, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
NEW.geom;

/*
INSERT INTO m_economie.an_immo_bien (idbien,idimmo,tbien,libelle,pdp,lib_occup,bal,adr,adrcomp,surf_p,source,refext,observ)
SELECT v_idbien,v_idimmo,NEW.tbien,NEW.libelle,false,NEW.lib_occup,null,NEW.adr,NEW.adrcomp,NEW.surf_p,NEW.source,NEW.refext_bien,NEW.observ_bien;
*/

/*
INSERT INTO m_economie.an_immo_comm (idcomm,idimmo,idbien,prix_a,prix_am,loyer_a,loyer_am,bail_a,prix,prix_m,loyer,loyer_m,bail,comm,commtel,commtelp,commmail,etat,refext,observ) 
SELECT v_idcomm,v_idimmo,v_idbien,NEW.prix_a,NEW.prix_am,NEW.loyer_a,NEW.loyer_am,NEW.bail_a,NEW.prix,NEW.prix_m,NEW.loyer,NEW.loyer_m,NEW.bail,NEW.comm,NEW.commtel,NEW.commtelp,NEW.commmail,NEW.etat,NEW.refext_comm,NEW.observ_comm;
*/

INSERT INTO m_economie.an_immo_propbati (idprop,idbati,propnom,proptel,proptelp,propmail,observ)
SELECT v_idprop,v_idbati,NEW.propnom,NEW.proptel,NEW.proptelp,NEW.propmail,NEW.observ_prop;

INSERT INTO m_economie.an_immo_bati (idbati,idimmo,ityp,libelle,surf_p,mprop,observ,bati_nom)
SELECT v_idbati,v_idimmo,'23',NEW.libelle_bati,NEW.surf_pbati,NEW.mprop,NEW.observ_bati,NEW.bati_nom;

-- si l'identifiant adresse est saisie (uniquement via Gabarit QGIS interne au service SIG)
IF NEW.id_adresse > 0 THEN
INSERT INTO  m_economie.lk_immo_batiadr (id,idbati,id_adresse)
SELECT nextval('m_economie.lk_immo_batiadr_seq'::regclass),v_idbati,NEW.id_adresse;

END IF;

END IF;

IF (TG_OP='UPDATE') then

UPDATE  m_economie.geo_immo_bien SET
idsite = (SELECT DISTINCT idsite FROM r_objet.geo_objet_ope WHERE st_intersects(geo_objet_ope.geom,ST_PointOnSurface(NEW.geom)) = true AND idsite <> '60159ak'),
sup_m2 = st_area(NEW.geom),
observ = NEW.observ_obj,
op_sai = NEW.op_sai,
date_maj = now(),
src_geom = NEW.src_geom,
src_date = NEW.src_date,
insee = (select string_agg(insee, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
commune = (select string_agg(commune, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
geom = NEW.GEOM
WHERE idimmo = NEW.idimmo;

-- si l'identifiant adresse est modifié sans existance préalable (uniquement via Gabarit QGIS interne au service SIG)
IF (NEW.id_adresse IS NOT NULL AND OLD.id_adresse IS NULL)  THEN
INSERT INTO  m_economie.lk_immo_batiadr (id,idbati,id_adresse)
SELECT nextval('m_economie.lk_immo_batiadr_seq'::regclass),NEW.idbati,NEW.id_adresse;
END IF;

-- si l'identifiant adresse est modifié avec une existance préalable (uniquement via Gabarit QGIS interne au service SIG)
IF OLD.id_adresse IS NOT NULL AND OLD.id_adresse <> NEW.id_adresse THEN
UPDATE m_economie.lk_immo_batiadr SET id_adresse = NEW.id_adresse WHERE idbati = NEW.idbati;
END IF;

UPDATE  m_economie.an_immo_propbati SET
propnom = NEW.propnom,
proptel = NEW.proptel,
proptelp = NEW.proptelp,
propmail = NEW.propmail,
observ = NEW.observ_prop
WHERE idprop = NEW.idprop;

UPDATE  m_economie.an_immo_bati SET
libelle = NEW.libelle_bati,
surf_p = NEW.surf_pbati,
mprop = NEW.mprop,
observ = NEW.observ_bati,
bati_nom = NEW.bati_nom
WHERE idbati = NEW.idbati;

END IF;

IF (TG_OP='DELETE') then

DELETE FROM m_economie.an_immo_propbien WHERE idbien IN (SELECT idbien FROM m_economie.an_immo_bien bi WHERE bi.idimmo = OLD.idimmo);
DELETE FROM m_economie.an_immo_desc WHERE idbien IN (SELECT idbien FROM m_economie.an_immo_bien bi WHERE bi.idimmo = OLD.idimmo);
DELETE FROM m_economie.an_immo_media WHERE id IN (SELECT idbien FROM m_economie.an_immo_bien bi WHERE bi.idimmo = OLD.idimmo);
DELETE FROM m_economie.geo_immo_bien WHERE idimmo = OLD.idimmo;
DELETE FROM m_economie.an_immo_propbati WHERE idprop = OLD.idprop;
DELETE FROM m_economie.an_immo_bati WHERE idbati = OLD.idbati;
DELETE FROM m_economie.lk_immo_batiadr WHERE idbati = OLD.idbati;
DELETE FROM m_economie.an_immo_media WHERE id = OLD.idbati;
DELETE FROM m_economie.an_immo_bien WHERE idimmo = OLD.idimmo;
DELETE FROM m_economie.an_immo_comm WHERE idimmo = OLD.idimmo;

END IF;
											   
REFRESH MATERIALIZED VIEW x_apps.xapps_an_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_etat;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_loc;

RETURN NEW;

END;

$BODY$;


-- ############################################################ ft_m_gestion_immolocnonident_bien #########################################      
                                                                                           
-- FUNCTION: m_economie.ft_m_gestion_immolocnonident_bien()

-- DROP FUNCTION m_economie.ft_m_gestion_immolocnonident_bien();

CREATE FUNCTION m_economie.ft_m_gestion_immolocnonident_bien()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

--DECLARE v_idimmo text;
DECLARE v_idbien text;
--DECLARE v_idbati text;
DECLARE v_idprop text;
DECLARE v_idcomm text;
DECLARE v_iddesc text;

BEGIN

IF (TG_OP='INSERT') then

-- v_idimmo := ('O'::text || nextval('m_economie.geo_immo_bien_seq'::regclass));
v_idbien := ('B'::text || nextval('m_economie.an_immo_bien_seq'::regclass));
-- v_idbati := ('BA'::text || nextval('m_economie.an_immo_bati_seq'::regclass));
v_idprop := ('P'::text || nextval('m_economie.an_immo_prop_seq'::regclass));
v_idcomm := ('C'::text || nextval('m_economie.an_immo_comm_seq'::regclass));
v_iddesc := ('D'::text || nextval('m_economie.an_immo_desc_seq'::regclass));

INSERT INTO m_economie.an_immo_bien (idbien,idimmo,tbien,libelle,pdp,lib_occup,adr,adrcomp,surf_p,source,refext,observ,surf_rdc,surf_etag,surf_mezza,surf_acti,surf_bur,op_sai,date_sai)
SELECT v_idbien,NEW.idimmo,NEW.tbien,NEW.libelle,NEW.pdp,NEW.lib_occup,NEW.adr,NEW.adrcomp,NEW.surf_p,NEW.source,NEW.refext_bien,NEW.observ_bien,
NEW.surf_rdc,NEW.surf_etag,NEW.surf_mezza,NEW.surf_acti,NEW.surf_bur,NEW.op_sai_bien,now();

INSERT INTO m_economie.an_immo_desc (iddesc,idbien,observ) 
SELECT v_iddesc,v_idbien,NEW.observ_desc;

INSERT INTO m_economie.an_immo_comm (idcomm,idimmo,idbien,prix_a,prix_am,loyer_a,loyer_am,bail_a,prix,prix_m,loyer,loyer_m,bail,comm,commtel,commtelp,commmail,etat,refext,observ,loyer_amp,loyer_mp) 
SELECT v_idcomm,NEW.idimmo,v_idbien,NEW.prix_a,NEW.prix_am,NEW.loyer_a,NEW.loyer_am,NEW.bail_a,NEW.prix,NEW.prix_m,NEW.loyer,NEW.loyer_m,NEW.bail,NEW.comm,NEW.commtel,NEW.commtelp,NEW.commmail,
NEW.etat,NEW.refext_comm,NEW.observ_comm,NEW.loyer_amp,NEW.loyer_mp;

INSERT INTO m_economie.an_immo_propbien (idprop,idbien,propnom,proptel,proptelp,propmail,observ)
SELECT v_idprop,v_idbien,NEW.propnom_bien,NEW.proptel_bien,NEW.proptelp_bien,NEW.propmail_bien,NEW.observ_propbien;

END IF;

IF (TG_OP='UPDATE') then
UPDATE  m_economie.an_immo_bien SET
tbien = NEW.tbien,
libelle = NEW.libelle,
pdp = NEW.pdp,
lib_occup = NEW.lib_occup,
adr = NEW.adr,
adrcomp = NEW.adrcomp,
surf_p = NEW.surf_p,
source = NEW.source,
refext = NEW.refext_bien,
observ = NEW.observ_bien,
surf_rdc = NEW.surf_rdc,
surf_etag = NEW.surf_etag,
surf_mezza = NEW.surf_mezza,
surf_acti = NEW.surf_acti,
surf_bur = NEW.surf_bur,
op_sai = NEW.op_sai_bien,
date_maj = now()
WHERE idbien = NEW.idbien;

UPDATE  m_economie.an_immo_desc SET
observ = NEW.observ_desc
WHERE idbien = NEW.idbien;

UPDATE  m_economie.an_immo_propbien SET
propnom = NEW.propnom_bien,
proptel = NEW.proptel_bien,
proptelp = NEW.proptelp_bien,
propmail = NEW.propmail_bien,
observ = NEW.observ_propbien
WHERE idprop = NEW.idprop_bien;

UPDATE  m_economie.an_immo_comm SET
prix_a = NEW.prix_a,
prix_am = NEW.prix_am,
loyer_a = NEW.loyer_a,
loyer_am = NEW.loyer_am,
bail_a = NEW.bail_a,
prix = NEW.prix,
prix_m = NEW.prix_m,
loyer = NEW.loyer,
loyer_m = NEW.loyer_m,
bail = NEW.bail,
comm = NEW.comm,
commtel = NEW.commtel,
commtelp = NEW.commtelp,
commmail = NEW.commmail,
etat = NEW.etat,
refext = NEW.refext_comm,
observ = NEW.observ_comm,
loyer_amp = NEW.loyer_amp,
loyer_mp = NEW.loyer_mp
WHERE idcomm = NEW.idcomm;

END IF;

IF (TG_OP='DELETE') then

DELETE FROM m_economie.an_immo_bien WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_comm WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_desc WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_propbien WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_media WHERE id = OLD.idbien;

END IF;

REFRESH MATERIALIZED VIEW x_apps.xapps_an_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_etat;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_loc;
				  
RETURN NEW;

END;

$BODY$;

-- FUNCTION: m_economie.ft_m_gestion_immoterrain()

-- DROP FUNCTION m_economie.ft_m_gestion_immoterrain();

CREATE FUNCTION m_economie.ft_m_gestion_immoterrain()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE v_idimmo text;
DECLARE v_idbien text;
DECLARE v_idprop text;
DECLARE v_idcomm text;

BEGIN

IF (TG_OP='INSERT') then

v_idimmo := ('O'::text || nextval('m_economie.geo_immo_bien_seq'::regclass));
v_idbien := ('B'::text || nextval('m_economie.an_immo_bien_seq'::regclass));
v_idprop := ('P'::text || nextval('m_economie.an_immo_prop_seq'::regclass));
v_idcomm := ('C'::text || nextval('m_economie.an_immo_comm_seq'::regclass));

INSERT INTO m_economie.geo_immo_bien (idimmo,idbati,idsite,sup_m2,ityp,observ,op_sai,date_sai,date_maj,src_geom,src_date,insee,commune,geom)
SELECT v_idimmo,null,
(SELECT DISTINCT idsite FROM r_objet.geo_objet_ope WHERE st_intersects(geo_objet_ope.geom,ST_PointOnSurface(NEW.geom)) = true AND idsite <> '60159ak'),
st_area(NEW.geom),'10',NEW.observ_obj,NEW.op_sai,now(),null,NEW.src_geom,NEW.src_date,
(select string_agg(insee, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
(select string_agg(commune, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
NEW.geom;

INSERT INTO m_economie.an_immo_bien (idbien,idimmo,tbien,libelle,pdp,lib_occup,adr,adrcomp,surf_p,source,refext,observ,op_sai,date_sai)
SELECT v_idbien,v_idimmo,NEW.tbien,NEW.libelle,false,NEW.lib_occup,NEW.adr,NEW.adrcomp,NEW.surf_p,NEW.source,NEW.refext_bien,NEW.observ_bien,NEW.op_sai_bien,now();

INSERT INTO m_economie.an_immo_comm (idcomm,idimmo,idbien,prix_a,prix_am,loyer_a,loyer_am,bail_a,prix,prix_m,loyer,loyer_m,bail,comm,commtel,commtelp,commmail,etat,refext,observ,loyer_amp,loyer_mp) 
SELECT v_idcomm,v_idimmo,v_idbien,NEW.prix_a,NEW.prix_am,NEW.loyer_a,NEW.loyer_am,NEW.bail_a,NEW.prix,NEW.prix_m,NEW.loyer,NEW.loyer_m,NEW.bail,NEW.comm,NEW.commtel,NEW.commtelp,NEW.commmail,NEW.etat,
NEW.refext_comm,NEW.observ_comm,NEW.loyer_amp,NEW.loyer_mp;

INSERT INTO m_economie.an_immo_propbien (idprop,idbien,propnom,proptel,proptelp,propmail,observ)
SELECT v_idprop,v_idbien,NEW.propnom,NEW.proptel,NEW.proptelp,NEW.propmail,NEW.observ_prop;

END IF;

IF (TG_OP='UPDATE') then

UPDATE  m_economie.geo_immo_bien SET
idsite = (SELECT DISTINCT idsite FROM r_objet.geo_objet_ope WHERE st_intersects(geo_objet_ope.geom,ST_PointOnSurface(NEW.geom)) = true AND idsite <> '60159ak'),
sup_m2 = st_area(NEW.geom),
observ = NEW.observ_obj,
op_sai = NEW.op_sai,
date_maj = now(),
src_geom = NEW.src_geom,
src_date = NEW.src_date,
insee = (select string_agg(insee, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
commune = (select string_agg(commune, ', ') from r_osm.geo_osm_commune where st_intersects(NEW.geom,geom)),
geom = NEW.GEOM
WHERE idimmo = NEW.idimmo;

UPDATE  m_economie.an_immo_bien SET
tbien = NEW.tbien,
libelle = NEW.libelle,
lib_occup = NEW.lib_occup,
adr = NEW.adr,
adrcomp = NEW.adrcomp,
surf_p = NEW.surf_p,
source = NEW.source,
refext = NEW.refext_bien,
observ = NEW.observ_bien,
op_sai = NEW.op_sai_bien,
date_maj = now()
WHERE idbien = NEW.idbien;

UPDATE  m_economie.an_immo_comm SET
prix_a = NEW.prix_a,
prix_am = NEW.prix_am,
loyer_a = NEW.loyer_a,
loyer_am = NEW.loyer_am,
bail_a = NEW.bail_a,
prix = NEW.prix,
prix_m = NEW.prix_m,
loyer = NEW.loyer,
loyer_m = NEW.loyer_m,
bail = NEW.bail,
comm = NEW.comm,
commtel = NEW.commtel,
commtelp = NEW.commtelp,
commmail = NEW.commmail,
etat = NEW.etat,
refext = NEW.refext_comm,
observ = NEW.observ_comm,
loyer_amp = NEW.loyer_amp,
loyer_mp = NEW.loyer_mp
WHERE idcomm = NEW.idcomm;

UPDATE  m_economie.an_immo_propbien SET
propnom = NEW.propnom,
proptel = NEW.proptel,
proptelp = NEW.proptelp,
propmail = NEW.propmail,
observ = NEW.observ_prop
WHERE idprop = NEW.idprop;

END IF;

IF (TG_OP='DELETE') then

DELETE FROM m_economie.geo_immo_bien WHERE idimmo = OLD.idimmo;
DELETE FROM m_economie.an_immo_bien WHERE idbien = OLD.idbien;
DELETE FROM m_economie.an_immo_comm WHERE idcomm = OLD.idcomm;
DELETE FROM m_economie.an_immo_propbien WHERE idprop = OLD.idprop;
DELETE FROM m_economie.an_immo_media WHERE id = OLD.idimmo;

END IF;

REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_etat;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_bati;
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_loc;
											   
RETURN NEW;

END;

$BODY$;

 -- ############################################################ ft_m_gestion_immo_libelle #########################################    
											   
-- FUNCTION: m_economie.ft_m_gestion_immo_libelle()

-- DROP FUNCTION m_economie.ft_m_gestion_immo_libelle();

CREATE FUNCTION m_economie.ft_m_gestion_immo_libelle()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN
-- rafraichissement de la vue matérialisée permettant de gérer l'affichage des libellés sur la carte
REFRESH MATERIALIZED VIEW x_apps.xapps_geo_vmr_immo_bati;

return new;

END;

$BODY$;

-- Trigger: t_t1_refresh_libelle

-- DROP TRIGGER t_t1_refresh_libelle ON m_economie.lk_immo_batiadr;

CREATE TRIGGER t_t1_refresh_libelle
    AFTER INSERT OR DELETE OR UPDATE 
    ON m_economie.lk_immo_batiadr
    FOR EACH ROW
    EXECUTE PROCEDURE m_economie.ft_m_gestion_immo_libelle();

										   
                                        
-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      VUES DE GESTION                                                      ###
-- ###                                                                                                                           ###
-- #################################################################################################################################

-- ############################################################ an_v_immo_bien_locnonident #########################################

-- View: m_economie.an_v_immo_bien_locnonident

-- DROP VIEW m_economie.an_v_immo_bien_locnonident;

CREATE OR REPLACE VIEW m_economie.an_v_immo_bien_locnonident
 AS
 SELECT gbi.idimmo,
    ba.mprop,
    abi.idbien,
    abi.tbien,
    abi.libelle,
    abi.pdp,
    abi.lib_occup,
    abi.adr,
    abi.adrcomp,
    abi.surf_p,
    abi.source,
    abi.refext AS refext_bien,
    abi.observ AS observ_bien,
    abi.surf_rdc,
    abi.surf_etag,
    abi.surf_mezza,
    abi.surf_acti,
    abi.surf_bur,
    com.idcomm,
    com.prix_a,
    com.prix_am,
    com.loyer_a,
    com.loyer_am,
    com.bail_a,
    com.prix,
    com.prix_m,
    com.loyer,
    com.loyer_m,
    com.bail,
    com.comm,
    com.commtel,
    com.commtelp,
    com.commmail,
    com.etat,
    com.refext AS refext_comm,
    com.observ AS observ_comm,
    pbi.idprop AS idprop_bien,
    pbi.propnom AS propnom_bien,
    pbi.proptel AS proptel_bien,
    pbi.proptelp AS proptelp_bien,
    pbi.propmail AS propmail_bien,
    pbi.observ AS observ_propbien
   FROM m_economie.geo_immo_bien gbi,
    m_economie.an_immo_bien abi,
    m_economie.an_immo_comm com,
    m_economie.an_immo_propbien pbi,
    m_economie.an_immo_bati ba
  WHERE gbi.ityp::text = '23'::text AND gbi.idimmo = abi.idimmo AND abi.idbien = com.idbien AND abi.idbien = pbi.idbien AND gbi.idbati = ba.idbati;

-- ############################################################ geo_v_immo_bien_locident ######################################### 
											   
-- View: m_economie.geo_v_immo_bien_locident

-- DROP VIEW m_economie.geo_v_immo_bien_locident;

CREATE OR REPLACE VIEW m_economie.geo_v_immo_bien_locident
 AS
 
 SELECT DISTINCT gbi.idimmo,
    gbi.idbati,
    abi.idbien,
    gbi.idsite,
    gbi.sup_m2,
    '22'::character varying(2) AS ityp,
    gbi.observ AS observ_obj,
    gbi.op_sai,
    gbi.date_sai,
    gbi.date_maj,
    gbi.src_geom,
    gbi.src_date,
    gbi.insee,
    gbi.commune,
    null::integer AS id_adresse,
	string_agg(a.id_adresse::text,' ,') AS bal,
    abi.tbien,
    abi.libelle,
    abi.pdp,
    abi.lib_occup,
    abi.adr,
    abi.adrcomp,
    abi.surf_p,
    abi.source,
    abi.refext AS refext_bien,
    abi.observ AS observ_bien,
    abi.surf_rdc,
    abi.surf_etag,
    abi.surf_mezza,
    abi.surf_acti,
    abi.surf_bur,
    cbi.idcomm,
    cbi.prix_a,
    cbi.prix_am,
    cbi.loyer_a,
    cbi.loyer_am,
    cbi.bail_a,
    cbi.prix,
    cbi.prix_m,
    cbi.loyer,
    cbi.loyer_m,
    cbi.bail,
    cbi.comm,
    cbi.commtel,
    cbi.commtelp,
    cbi.commmail,
    cbi.etat,
    cbi.refext AS refext_comm,
    cbi.observ AS observ_comm,
    ba.idbati AS bati_appart,
    ba.libelle AS libelle_bati,
    ba.bati_nom,
    ba.surf_p AS surf_pbati,
    ba.mprop,
    ba.observ AS observ_bati,
    pba.idprop AS idprop_bati,
    pba.propnom AS propnom_bati,
    pba.proptel AS proptel_bati,
    pba.proptelp AS proptelp_bati,
    pba.propmail AS propmail_bati,
    pba.observ AS observ_propbati,
    pbi.idprop AS idprop_bien,
    pbi.propnom AS propnom_bien,
    pbi.proptel AS proptel_bien,
    pbi.proptelp AS proptelp_bien,
    pbi.propmail AS propmail_bien,
    pbi.observ AS observ_propbien,
    gbi.geom
   FROM m_economie.geo_immo_bien gbi
     LEFT JOIN m_economie.lk_immo_batiadr a ON gbi.idbati = a.idbati,
    m_economie.an_immo_bien abi,
    m_economie.an_immo_comm cbi,
    m_economie.an_immo_bati ba,
    m_economie.an_immo_propbati pba,
    m_economie.an_immo_propbien pbi
  WHERE gbi.ityp::text = '22'::text AND gbi.idimmo = abi.idimmo AND abi.idbien = cbi.idbien AND gbi.idbati = pba.idbati AND gbi.idbati = ba.idbati AND abi.idbien = pbi.idbien
  GROUP BY gbi.idimmo, abi.idbien,cbi.idcomm,ba.idbati,pba.idprop,pbi.idprop;
  
  

COMMENT ON VIEW m_economie.geo_v_immo_bien_locident
    IS 'Vue éditable des locaux identifiés reconstituant le bâtiment';


CREATE TRIGGER t_t1_gestion_immolocident
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_economie.geo_v_immo_bien_locident
    FOR EACH ROW
    EXECUTE PROCEDURE m_economie.ft_m_gestion_immolocident();


CREATE TRIGGER t_t2_refresh_stat_bati
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_economie.geo_v_immo_bien_locident
    FOR EACH ROW
    EXECUTE PROCEDURE m_economie.ft_m_gestion_immo_statbati();





-- ############################################################ geo_v_immo_bien_locnonident #########################################

-- View: m_economie.geo_v_immo_bien_locnonident

-- DROP VIEW m_economie.geo_v_immo_bien_locnonident;

CREATE OR REPLACE VIEW m_economie.geo_v_immo_bien_locnonident
 AS
 
 SELECT 
    gbi.idimmo,
    gbi.idbati,
    gbi.idsite,
    gbi.sup_m2,
    '23'::character varying(2) AS ityp,
    gbi.observ AS observ_obj,
    gbi.op_sai,
    gbi.date_sai,
    gbi.date_maj,
    gbi.src_geom,
    gbi.src_date,
    gbi.insee,
    gbi.commune,
    null::integer AS id_adresse,
    string_agg(a.id_adresse::text,' ,') AS bal,
    ba.libelle AS libelle_bati,
    ba.bati_nom,
    ba.surf_p AS surf_pbati,
    ba.mprop,
    ba.observ AS observ_bati,
    pba.idprop,
    pba.propnom,
    pba.proptel,
    pba.proptelp,
    pba.propmail,
    pba.observ AS observ_prop,
    gbi.geom
   FROM m_economie.geo_immo_bien gbi
     LEFT JOIN m_economie.lk_immo_batiadr a ON gbi.idbati = a.idbati,
    m_economie.an_immo_bati ba,
    m_economie.an_immo_propbati pba
  WHERE gbi.ityp::text = '23'::text AND gbi.idbati = pba.idbati AND gbi.idbati = ba.idbati
  GROUP BY gbi.idimmo, ba.libelle,ba.surf_p,ba.mprop,ba.observ,pba.idprop,pba.propnom,pba.proptel,pba.proptelp,pba.propmail,pba.observ;
  
  
COMMENT ON VIEW m_economie.geo_v_immo_bien_locnonident
    IS 'Vue éditable des locaux non identifiés dans un bâtiment divisible';


CREATE TRIGGER t_t1_gestion_immolocnonident
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_economie.geo_v_immo_bien_locnonident
    FOR EACH ROW
    EXECUTE PROCEDURE m_economie.ft_m_gestion_immolocnonident();


CREATE TRIGGER t_t2_refresh_stat_bati
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_economie.geo_v_immo_bien_locnonident
    FOR EACH ROW
    EXECUTE PROCEDURE m_economie.ft_m_gestion_immo_statbati();



-- ############################################################ geo_v_immo_bien_terrain #########################################

-- View: m_economie.geo_v_immo_bien_terrain

-- DROP VIEW m_economie.geo_v_immo_bien_terrain;

CREATE OR REPLACE VIEW m_economie.geo_v_immo_bien_terrain
 AS
 SELECT gbi.idimmo,
    gbi.idbati,
    abi.idbien,
    gbi.idsite,
    gbi.sup_m2,
    '10'::character varying(2) AS ityp,
    gbi.observ AS observ_obj,
    gbi.op_sai,
    gbi.date_sai,
    gbi.date_maj,
    gbi.src_geom,
    gbi.src_date,
    gbi.insee,
    gbi.commune,
    abi.tbien,
    abi.libelle,
    abi.pdp,
    abi.lib_occup,
    abi.adr,
    abi.adrcomp,
    abi.surf_p,
    abi.source,
    abi.refext AS refext_bien,
    abi.observ AS observ_bien,
    cbi.idcomm,
    cbi.prix_a,
    cbi.prix_am,
    cbi.loyer_a,
    cbi.loyer_am,
    cbi.bail_a,
    cbi.prix,
    cbi.prix_m,
    cbi.loyer,
    cbi.loyer_m,
    cbi.bail,
    cbi.comm,
    cbi.commtel,
    cbi.commtelp,
    cbi.commmail,
    cbi.etat,
    cbi.refext AS refext_comm,
    cbi.observ AS observ_comm,
    pbi.idprop,
    pbi.propnom,
    pbi.proptel,
    pbi.proptelp,
    pbi.propmail,
    pbi.observ AS observ_prop,
    gbi.geom
   FROM m_economie.geo_immo_bien gbi,
    m_economie.an_immo_bien abi,
    m_economie.an_immo_comm cbi,
    m_economie.an_immo_propbien pbi
  WHERE gbi.ityp::text = '10'::text AND gbi.idimmo = abi.idimmo AND abi.idbien = cbi.idbien AND abi.idbien = pbi.idbien;


COMMENT ON VIEW m_economie.geo_v_immo_bien_terrain
    IS 'Vue éditable des terrains du marché immobilier';


CREATE TRIGGER t_t1_gestion_immoterrain
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_economie.geo_v_immo_bien_terrain
    FOR EACH ROW
    EXECUTE PROCEDURE m_economie.ft_m_gestion_immoterrain();



