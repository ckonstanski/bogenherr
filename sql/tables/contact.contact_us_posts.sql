drop table contact.contact_us_posts cascade;

create table contact.contact_us_posts (
    id serial8 primary key,
    first_name character varying(255) not null,
    last_name character varying(255) not null,
    email character varying(255) not null,
    phone character varying(255),
    submitted timestamp without time zone not null default now(),
    comments text
);
