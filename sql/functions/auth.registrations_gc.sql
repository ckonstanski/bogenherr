drop function auth.registrations_gc ();

create or replace function auth.registrations_gc ()
returns void
as $$
begin
    delete
    from auth.registrations
    where created < now() - interval '3 days';
end;
$$ language plpgsql;
