drop function contact.get_contact_us_posts_by_id_and_read (
    p_user_id bigint,
    p_read bool
);

create or replace function contact.get_contact_us_posts_by_id_and_read (
    p_user_id bigint,
    p_read bool
)
returns setof contact.contact_us_posts
as $$
begin
    return query
    select c.id,
        c.first_name,
        c.last_name,
        c.email,
        c.phone,
        c.submitted,
        c.comments
        from contact.contact_us_posts c
        left outer join contact.contact_us_posts_read cr
            on c.id = cr.contact_us_post_id
        where (p_read = false and cr.user_id is null)
            or (p_read = true and cr.user_id = p_user_id)
        order by c.submitted desc;

    return;
end;
$$ language plpgsql;
