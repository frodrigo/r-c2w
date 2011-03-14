CREATE TEMP VIEW gpx_stats AS
SELECT
  refINSEE,
  sum(st_length(geom::geography))/1000 AS km
FROM
    rc2w
WHERE
    refINSEE LIKE '__DEP__%' AND
    st_length(geom::geography)/1000 < 10
GROUP BY
    refINSEE
ORDER BY
    refINSEE
;

COPY (SELECT * FROM gpx_stats) TO STDOUT WITH CSV HEADER;
