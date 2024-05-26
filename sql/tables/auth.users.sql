drop table auth.users cascade;

create table auth.users (
    id serial8 primary key,
    username character varying(255) not null,
    pwd bytea,
    first_name character varying(255) not null,
    last_name character varying(255) not null,
    email character varying(255) not null,
    phone character varying(255),
    active bool,
    created timestamp without time zone not null default now()
);
