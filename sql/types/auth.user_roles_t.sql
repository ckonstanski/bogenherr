drop type auth.user_roles_t cascade;

CREATE TYPE auth.user_roles_t AS (
    user_role_group_id bigint,
    user_id bigint,
    role_group_id bigint,
    role_group_name character varying,
    role_group_description character varying,
    role_group_role_id bigint,
    role_id bigint,
    role_name character varying,
    role_description character varying
);
