drop function auth.update_user(
    p_id bigint,
    p_username character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying
);

create or replace function auth.update_user (
    p_id bigint,
    p_username character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying
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
        set username = p_username,
            first_name = p_first_name,
            last_name = p_last_name,
            email = p_email,
            phone = p_phone
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
