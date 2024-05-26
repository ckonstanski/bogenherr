drop function auth.delete_registration (
    p_hash text
);

create or replace function auth.delete_registration (
    p_hash text
)
returns void
as $$
begin
    delete from auth.registrations r
    where r.hash = ('\x' || p_hash)::bytea;
end;
$$ language plpgsql;
