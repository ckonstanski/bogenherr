drop table auth.user_sessions cascade;

create table auth.user_sessions (
    id serial8 primary key,
    sessionid character varying(255) not null,
    datetime bigint not null
);
