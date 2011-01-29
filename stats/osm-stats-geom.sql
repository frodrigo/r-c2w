DROP VIEW IF EXISTS osm_communes CASCADE;
CREATE VIEW osm_communes AS
SELECT
        relations.tags -> 'ref:INSEE' AS ref,
        relations.tags -> 'name' AS name,
        ST_Polygonize(linestring) AS boundary
FROM
        relations
        JOIN relation_members ON relation_id=relations.id AND member_type='W'
        JOIN ways ON ways.id=relation_members.member_id
WHERE
        relations.tags -> 'admin_level' = '8' AND
        relations.tags -> 'ref:INSEE' LIKE '__DEP__%'
GROUP BY
        relations.id,
        relations.tags -> 'ref:INSEE',
        relations.tags -> 'name'
;


DROP VIEW IF EXISTS osm_stats CASCADE;
CREATE VIEW osm_stats AS
SELECT
        osm_communes.ref AS refINSEE,
        osm_communes.name AS name,
        ST_GeometryN(osm_communes.boundary,1) AS boundary,
        SUM(ST_Length(ST_Intersection(ST_GeometryN(boundary,1),ways.linestring)::geography))/1000 AS osm_km,
        cadastre.km AS cadastre_km,
        SUM(ST_Length(ST_Intersection(ST_GeometryN(boundary,1),ways.linestring)::geography))/1000 / cadastre.km AS ratio
FROM
        ways
        JOIN osm_communes ON ST_Intersects(ST_GeometryN(boundary,1), ways.linestring)
        JOIN cadastre ON osm_communes.ref = cadastre.refINSEE AND cadastre.wtype='l'
WHERE
        ways.tags ? 'highway'
GROUP BY
        osm_communes.ref,
        osm_communes.name,
        osm_communes.boundary,
        cadastre.km
ORDER BY
        osm_communes.ref
;
