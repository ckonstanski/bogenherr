drop table auth.role_groups cascade;

create table auth.role_groups (
    id serial8 primary key,
    name character varying(255) not null,
    description character varying(255)
);
