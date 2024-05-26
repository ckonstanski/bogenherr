drop function auth.insert_user_role_group (
    p_user_id bigint,
    p_role_group_name character varying
);

create or replace function auth.insert_user_role_group (
    p_user_id bigint,
    p_role_group_name character varying
)
returns bigint
as $$
declare
  l_role_group_id bigint;
  l_user_role_group_id bigint;
begin
    select rg.id into l_role_group_id
    from auth.role_groups rg
    where rg.name = p_role_group_name;

    if(l_role_group_id is not null) then
        select urg.id into l_user_role_group_id
        from auth.users_role_groups urg
        where urg.user_id = p_user_id
            and urg.role_group_id = l_role_group_id;

        if(l_user_role_group_id is null) then
            insert into auth.users_role_groups (
                user_id,
                role_group_id
            ) values (
                p_user_id,
                l_role_group_id
            );

            select urg.id into l_user_role_group_id
            from auth.users_role_groups urg
            where urg.user_id = p_user_id
                and urg.role_group_id = l_role_group_id;
        end if;
    end if;

    return l_user_role_group_id;
end;
$$ language plpgsql;
