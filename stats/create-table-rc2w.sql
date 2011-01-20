DROP TABLE IF EXISTS rc2w;
CREATE TABLE rc2w (
    id SERIAL NOT NULL,
    refINSEE int,
    wtype char(1),
    name varchar
);

SELECT AddGeometryColumn('rc2w', 'geom', 4326, 'LINESTRING', 2);
