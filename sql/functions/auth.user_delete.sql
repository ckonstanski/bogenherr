drop function auth.user_delete (
    p_id bigint
);

create or replace function auth.user_delete (
    p_id bigint
)
returns bool
as $$
declare
    l_id bigint;
    l_result bool;
begin
    if p_id is null then
        l_result := false::bool;
    else
        select id into l_id
        from auth.users
        where id = p_id;

        if l_id is null or l_id != p_id then
            l_result := false::bool;
        else
            delete
            from auth.users_roles_append
            where user_id = l_id;

            delete
            from auth.users_roles_exclude
            where user_id = l_id;

            delete
            from auth.users_role_groups
            where user_id = l_id;

            delete
            from general.roster
            where user_id = l_id;

            delete
            from contact.contact_us_posts_read
            where user_id = l_id;

            delete
            from auth.users
            where id = l_id;

            l_result := true::bool;
        end if;
    end if;

    return l_result;
end;
$$ language plpgsql;
