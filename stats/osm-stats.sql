CREATE TEMP VIEW osm_communes AS
SELECT
	relations.tags -> 'ref:INSEE' AS ref,
	relations.tags -> 'name' as name,
	ST_Polygonize(linestring) as bounday
FROM
	relations
	JOIN relation_members ON relation_id=relations.id AND member_type='W'
	JOIN ways ON ways.id=relation_members.member_id
WHERE
	relations.tags -> 'admin_level' = '8' AND
	relations.tags -> 'ref:INSEE' LIKE '40%'
GROUP BY
	relations.id,
	relations.tags -> 'ref:INSEE',
	relations.tags -> 'name'
;


CREATE TEMP VIEW osm_stats AS
SELECT
	osm_communes.ref as refINSEE,
	osm_communes.name,
	SUM(ST_Length(ST_Intersection(ST_GeometryN(bounday,1),ways.linestring)::geography))/1000 AS km
FROM
	ways
	JOIN osm_communes ON ST_Intersects(ST_GeometryN(bounday,1), ways.linestring)
WHERE
	ways.tags ? 'highway'
GROUP BY
	osm_communes.ref,
	osm_communes.name
ORDER BY
	osm_communes.ref
;


COPY (SELECT * FROM osm_stats) TO stdout WITH CSV HEADER;
