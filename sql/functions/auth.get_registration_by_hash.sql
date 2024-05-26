drop function auth.get_registration_by_hash (
    p_hash text
);

create or replace function auth.get_registration_by_hash (
    p_hash text
)
returns setof auth.registrations_t
as $$
begin
    return query
    select r.id,
        substring(r.hash::text from 3),
        r.first_name,
        r.last_name,
        r.email,
        r.role_groups,
        r.created,
        (r.created  - (now() - interval '3 days'))::interval as valid_for
    from auth.registrations r
    where r.hash = ('\x' || p_hash)::bytea;

    return;
end;
$$ language plpgsql;
