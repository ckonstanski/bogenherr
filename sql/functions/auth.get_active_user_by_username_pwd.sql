drop function auth.get_active_user_by_username_pwd (
    p_username character varying,
    p_pwd character varying
);

create or replace function auth.get_active_user_by_username_pwd (
    p_username character varying,
    p_pwd character varying
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
    where u.username = p_username
        and u.pwd = digest(p_pwd, 'sha512')
        and u.active = true;

    return;
end;
$$ language plpgsql;a
