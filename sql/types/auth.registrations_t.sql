drop type auth.registrations_t cascade;

create type auth.registrations_t as (
    id bigint,
    hash text,
    first_name character varying,
    last_name character varying,
    email character varying,
    role_groups text,
    created timestamp without time zone,
    valid_for interval
);
