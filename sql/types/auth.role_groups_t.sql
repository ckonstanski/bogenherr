drop type auth.role_groups_t cascade;

CREATE TYPE auth.role_groups_t AS (
    user_role_group_id bigint,
    user_id bigint,
    role_group_id bigint,
    name character varying,
    description character varying
);
