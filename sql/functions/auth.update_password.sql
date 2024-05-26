drop function auth.update_password (
    p_id bigint,
    p_pwd character varying
);

create or replace function auth.update_password (
    p_id bigint,
    p_pwd character varying
)
returns bigint
as $$
begin
    update auth.users
    set pwd = digest(p_pwd, 'sha512')
    where id = p_id;

    return p_id;
end;
$$ language plpgsql;
