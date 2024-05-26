drop function auth.get_registration_by_id (
    p_id bigint
);

create or replace function auth.get_registration_by_id (
    p_id bigint
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
    where r.id = p_id;

    return;
end;
$$ language plpgsql;
