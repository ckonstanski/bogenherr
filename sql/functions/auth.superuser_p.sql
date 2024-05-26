drop function auth.superuser_p (
    p_user_id bigint
);

create or replace function auth.superuser_p (
    p_user_id bigint
)
returns bool
as $$
declare
    l_user_id bigint;
begin
    with roles as (
        select urg.user_id,
            rg.id as role_group_id,
            rg.name
        from auth.users_role_groups urg
        inner join auth.role_groups_roles rgr
            on urg.role_group_id = rgr.role_group_id
        inner join auth.role_groups rg
            on rgr.role_group_id = rg.id
        where urg.user_id = p_user_id
            and rg.name = 'superuser'
    )
    select user_id into l_user_id
    from roles;

    if(l_user_id is null) then
        return false::bool;
    else
        return true::bool;
    end if;
end;
$$ language plpgsql;
