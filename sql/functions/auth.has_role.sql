drop function auth.has_role (
    p_user_id bigint,
    p_role_name character varying
);

create or replace function auth.has_role (
    p_user_id bigint,
    p_role_name character varying
)
returns setof auth.user_roles_t
as $$
begin
    return query
    select user_role_group_id,
        user_id,
        role_group_id,
        role_group_name,
        role_group_description,
        role_group_role_id,
        role_id,
        role_name,
        role_description
    from auth.get_all_roles_for_user(p_user_id)
    where role_name = p_role_name;

    return;
end;
$$ language plpgsql;
