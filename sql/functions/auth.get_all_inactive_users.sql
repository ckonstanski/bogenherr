drop function auth.get_all_users ();

create or replace function auth.get_all_users ()
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
    order by u.last_name asc,
        u.first_name asc,
        u.id asc;

    return;
end;
$$ language plpgsql;
