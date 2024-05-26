drop function auth.insert_registration (
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_role_groups text
);

create or replace function auth.insert_registration (
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_role_groups text
)
returns bigint
as $$
declare
  l_id bigint;
begin
    insert into auth.registrations (
        hash,
        first_name,
        last_name,
        email,
        role_groups
    ) values (
        digest(concat(cast(current_timestamp as text), random()::text), 'sha512'),
        p_first_name,
        p_last_name,
        p_email,
        p_role_groups
    );

    select id into l_id
    from auth.registrations
    where first_name = p_first_name
        and last_name = p_last_name
        and email = p_email
        and role_groups = p_role_groups;

    return l_id;
end;
$$ language plpgsql;
