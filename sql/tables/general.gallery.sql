drop table general.gallery cascade;

create table general.gallery (
    id serial8 primary key,
    description text,
    filename character varying(255),
    mime_type character varying(255),
    video_embed_url character varying(255),
    content bytea,
    created timestamp without time zone not null default now(),
    modified timestamp without time zone not null default now()
);
