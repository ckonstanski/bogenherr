drop table auth.roles cascade;

create table auth.roles (
    id serial8 primary key,
    name character varying(255) not null,
    description character varying(255)
);
