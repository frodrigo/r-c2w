SELECT AddGeometryColumn('rc2w', 'bbox', 4326, 'POLYGON', 2);
ALTER TABLE rc2w DROP CONSTRAINT enforce_geotype_bbox;
UPDATE rc2w SET bbox = ST_Envelope(geom);
CREATE INDEX rc2w_bbox_index ON rc2w(bbox);

DELETE FROM
    rc2w
WHERE
    ST_Envelope(ST_GeomFromText('LINESTRING (-180 -90, -180 90)',4326)) && bbox OR
    ST_Envelope(ST_GeomFromText('LINESTRING (-180 90, 180 90)',4326)) && bbox OR
    ST_Envelope(ST_GeomFromText('LINESTRING (180 90, 180 -90)',4326)) && bbox OR
    ST_Envelope(ST_GeomFromText('LINESTRING (180 -90, -180 -90)',4326)) && bbox
;
