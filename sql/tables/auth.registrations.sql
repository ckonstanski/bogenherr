drop table auth.registrations cascade;

create table auth.registrations (
    id serial8 primary key,
    hash bytea not null,
    first_name character varying(255) not null,
    last_name character varying(255) not null,
    email character varying(255) not null,
    role_groups text,
    created timestamp without time zone not null default now()
);
