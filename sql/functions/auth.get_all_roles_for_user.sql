drop function auth.get_all_roles_for_user (
    p_user_id bigint
);

create or replace function auth.get_all_roles_for_user (
    p_user_id bigint
)
returns setof auth.user_roles_t
as $$
begin
    if auth.superuser_p(p_user_id) = true::bool then
        return query
        with all_user_roles as (
            select null::bigint as user_role_group_id,
                p_user_id as user_id,
                null::bigint as role_group_id,
                null as role_group_name,
                null as role_group_description,
                null::bigint as role_group_role_id,
                null::bigint as role_id,
                '_Public' as role_name,
                null as role_description,
                null::bigint as role_id_exclude,
                null::bigint as role_id_append
            union
            select null::bigint as user_role_group_id,
                p_user_id as user_id,
                rg.id as role_group_id,
                rg.name as role_group_name,
                rg.description as role_group_description,
                rgr.id as role_group_role_id,
                r.id as role_id,
                r.name as role_name,
                r.description as role_description,
                null::bigint as role_id_exclude,
                null::bigint as role_id_append
            from auth.role_groups rg
            inner join auth.role_groups_roles rgr
                on rgr.role_group_id = rg.id
            inner join auth.roles r
                on rgr.role_id = r.id
        )
        select a.user_role_group_id,
            a.user_id,
            a.role_group_id,
            a.role_group_name,
            a.role_group_description,
            a.role_group_role_id,
            a.role_id,
            a.role_name,
            a.role_description
        from (
            select r.user_role_group_id as user_role_group_id,
                r.user_id as user_id,
                r.role_group_id as role_group_id,
                r.role_group_name as role_group_name,
                r.role_group_description as role_group_description,
                r.role_group_role_id as role_group_role_id,
                r.role_id as role_id,
                r.role_name as role_name,
                r.role_description as role_description,
                r.role_id_exclude as role_id_exclude,
                r.role_id_append as role_id_append
            from all_user_roles r
        ) a
        order by role_name asc;
    else
        return query
        with all_user_roles as (
            select null::bigint as user_role_group_id,
                p_user_id as user_id,
                null::bigint as role_group_id,
                null as role_group_name,
                null as role_group_description,
                null::bigint as role_group_role_id,
                null::bigint as role_id,
                '_Public' as role_name,
                null as role_description,
                null::bigint as role_id_exclude,
                null::bigint as role_id_append
            union
            select urg.id as user_role_group_id,
                urg.user_id,
                rg.id as role_group_id,
                rg.name as role_group_name,
                rg.description as role_group_description,
                rgr.id as role_group_role_id,
                r.id as role_id,
                r.name as role_name,
                r.description as role_description,
                null::bigint as role_id_exclude,
                null::bigint as role_id_append
            from auth.users_role_groups urg
            inner join auth.role_groups rg
                on urg.role_group_id = rg.id
            inner join auth.role_groups_roles rgr
                on rgr.role_group_id = rg.id
            inner join auth.roles r
                on rgr.role_id = r.id
            union
            select null::bigint as user_role_group_id,
                ure.user_id,
                null::bigint as role_group_id,
                null as role_group_name,
                null role_group_description,
                null::bigint as role_group_role_id,
                r.id as role_id,
                r.name as role_name,
                r.description role_description,
                ure.role_id as role_id_exclude,
                null::bigint as role_id_append
            from auth.users_roles_exclude ure
            inner join auth.roles r
                on ure.role_id = r.id
            where ure.user_id = p_user_id
            union
            select null::bigint as user_role_group_id,
                ura.user_id,
                null::bigint as role_group_id,
                null as role_group_name,
                null role_group_description,
                null::bigint as role_group_role_id,
                r.id as role_id,
                r.name as role_name,
                r.description role_description,
                null::bigint as role_id_exclude,
                ura.role_id as role_id_append
            from auth.users_roles_append ura
            inner join auth.roles r
                on ura.role_id = r.id
            where ura.user_id = p_user_id
        )
        select a.user_role_group_id,
            a.user_id,
            a.role_group_id,
            a.role_group_name,
            a.role_group_description,
            a.role_group_role_id,
            a.role_id,
            a.role_name,
            a.role_description
        from (
            select r.user_role_group_id as user_role_group_id,
                r.user_id as user_id,
                r.role_group_id as role_group_id,
                r.role_group_name as role_group_name,
                r.role_group_description as role_group_description,
                r.role_group_role_id as role_group_role_id,
                r.role_id as role_id,
                r.role_name as role_name,
                r.role_description as role_description,
                r.role_id_exclude as role_id_exclude,
                r.role_id_append as role_id_append
            from all_user_roles r
            where user_id = p_user_id
        ) a
        where a.role_id_exclude is null
        order by role_name asc;
    end if;

    return;
end;
$$ language plpgsql;
