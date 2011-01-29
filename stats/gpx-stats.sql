DELETE FROM
    rc2w
WHERE
    st_intersects(ST_GeomFromText('LINESTRING (-180 -90, -180 90, 180 90, 180 -90, -180 -90)',4326), geom)
;

CREATE TEMP VIEW gpx_stats AS
SELECT
  refINSEE,
  name,
  wtype,
  sum(st_length(geom::geography))/1000 AS km
FROM
    rc2w
WHERE
    refINSEE LIKE '__DEP__%'
GROUP BY
    refINSEE,
    wtype,
    name
ORDER BY
    refINSEE,
    wtype
;

COPY (SELECT * FROM gpx_stats) TO STDOUT WITH CSV HEADER;
