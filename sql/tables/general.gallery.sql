drop table general.gallery cascade;

create table general.gallery (
    id serial8 primary key,
    description text,
    filename character varying(255) not null,
    mime_type character varying(255) not null,
    content bytea not null,
    created timestamp without time zone not null default now(),
    modified timestamp without time zone not null default now()
);
