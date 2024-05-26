drop function auth.delete_role_groups_for_user (
    p_user_id bigint
);

create or replace function auth.delete_role_groups_for_user (
    p_user_id bigint
)
returns void
as $$
begin
    delete from auth.users_role_groups urg
    where user_id = p_user_id;

    return;
end;
$$ language plpgsql;
