drop function auth.insert_user(
    p_username character varying,
    p_pwd character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying,
    p_active boolean
);

create or replace function auth.insert_user (
    p_username character varying,
    p_pwd character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying,
    p_active boolean
)
returns bigint
as $$
declare
  l_id bigint;
begin
    select u.id into l_id
    from auth.users u
    where u.username = p_username
        and u.pwd = digest(p_pwd, 'sha512');

    if(l_id is null) then
        insert into auth.users (
            username,
            pwd,
            first_name,
            last_name,
            email,
            phone,
            active
        ) values (
            p_username,
            digest(p_pwd, 'sha512'),
            p_first_name,
            p_last_name,
            p_email,
            p_phone,
            p_active
        );

        select u.id into l_id
        from auth.users u
        where u.username = p_username
            and u.pwd = digest(p_pwd, 'sha512');

        return l_id;
    else
        return null;
    end if;
end;
$$ language plpgsql;
