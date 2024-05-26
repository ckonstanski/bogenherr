drop function auth.get_active_user_by_id (
    p_user_id bigint
);

create or replace function auth.get_active_user_by_id (
    p_user_id bigint
)
returns setof auth.users
as $$
begin
    return query
    select u.id,
        u.username,
        u.pwd,
        u.first_name,
        u.last_name,
        u.email,
        u.phone,
        u.active,
        u.created
    from auth.users u
    where u.id = p_user_id
        and u.active = true;

    return;
end;
$$ language plpgsql;
