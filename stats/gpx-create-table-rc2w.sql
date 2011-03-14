DROP TABLE IF EXISTS rc2w CASCADE;
CREATE TABLE rc2w (
    id SERIAL NOT NULL,
    refINSEE varchar
);

SELECT AddGeometryColumn('rc2w', 'geom', 4326, 'LINESTRING', 2);
