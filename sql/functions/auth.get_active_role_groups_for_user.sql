drop function auth.get_active_role_groups_for_user (
    p_user_id bigint
);

create or replace function auth.get_active_role_groups_for_user (
    p_user_id bigint
)
returns setof auth.role_groups_t
as $$
begin
    return query
    select urg.id as user_role_group_id,
        urg.user_id,
        rg.id as role_group_id,
        rg.name,
        rg.description
    from auth.users_role_groups urg
    inner join auth.role_groups rg
        on urg.role_group_id = rg.id
    where urg.user_id = p_user_id
    order by rg.name asc;

    return;
end;
$$ language plpgsql;
