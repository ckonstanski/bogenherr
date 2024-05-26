drop function auth.update_profile (
    p_id bigint,
    p_username character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying
);

create or replace function auth.update_profile (
    p_id bigint,
    p_username character varying,
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying
)
returns bigint
as $$
begin
    update auth.users
    set username = p_username,
        pwd = p_pwd,
        first_name = p_first_name,
        last_name = p_last_name,
        email = p_email,
        phone = p_phone
    where id = p_id;

    return p_id;
end;
$$ language plpgsql;
