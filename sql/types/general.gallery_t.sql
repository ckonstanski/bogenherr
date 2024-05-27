drop type general.gallery_t cascade;

create type general.gallery_t as (
    id bigint,
    description text,
    filename character varying,
    mime_type character varying,
    content text,
    created timestamp without time zone,
    modified timestamp without time zone
);
