drop function auth.upsert_user (
    p_id bigint,
    p_username character varying,
    p_pwd character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying,
    p_active boolean
);

create or replace function auth.upsert_user (
    p_id bigint,
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
begin
    if(p_id is null) then
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

        select id into p_id
        from auth.users
        where username = p_username
            and pwd = digest(p_pwd, 'sha512')
            and first_name = p_first_name
            and last_name = p_last_name
            and email = p_email
            and phone = p_phone;
    else
        update auth.users
        set username = p_username,
            pwd = digest(p_pwd, 'sha512'),
            first_name = p_first_name,
            last_name = p_last_name,
            email = p_email,
            phone = p_phone,
            active = p_active
        where id = p_id;
    end if;

    return p_id;
end;
$$ language plpgsql;
