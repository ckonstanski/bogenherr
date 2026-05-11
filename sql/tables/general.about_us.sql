drop table general.about_us cascade;

create table general.about_us (
    id serial8 primary key,
    category character varying(255),
    content text
);
