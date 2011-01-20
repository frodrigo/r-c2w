CREATE TEMP VIEW stats AS
SELECT
  refINSEE,
  name,
  wtype,
  sum(st_length(geom::geography))/1000 AS km
FROM
    rc2w
GROUP BY
    refINSEE,
    wtype,
    name
ORDER BY
    refINSEE,
    wtype
;

COPY (SELECT * FROM stats) TO STDOUT WITH CSV HEADER;
