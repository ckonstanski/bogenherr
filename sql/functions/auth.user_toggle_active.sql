drop function auth.user_toggle_active (
    p_id bigint
);

create or replace function auth.user_toggle_active (
    p_id bigint
)
returns bigint
as $$
declare
  l_id bigint;
begin
    select u.id into l_id
    from auth.users u
    where u.id = p_id;

    if(l_id is not null) then
        update auth.users
        set active = not active
        where id = p_id;

        select u.id into l_id
        from auth.users u
        where u.id = p_id;

        return l_id;
    else
        return null;
    end if;
end;
$$ language plpgsql;
