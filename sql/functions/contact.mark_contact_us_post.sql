drop function contact.mark_contact_us_post (
    p_contact_us_post_id int,
    p_user_id int,
    p_read_p bool
);

create or replace function contact.mark_contact_us_post (
    p_contact_us_post_id int,
    p_user_id int,
    p_read_p bool
)
returns void
as $$
declare
  l_id bigint;
begin
    if(p_read_p) then
        select id into l_id
        from contact.contact_us_posts_read
        where contact_us_post_id = p_contact_us_post_id
            and user_id = p_user_id;

        if(l_id is null) then
            insert into contact.contact_us_posts_read (
                contact_us_post_id,
                user_id
            ) values (
                p_contact_us_post_id,
                p_user_id
            );
        end if;
    else
        delete from contact.contact_us_posts_read
        where contact_us_post_id = p_contact_us_post_id
            and user_id = p_user_id;
    end if;
end;
$$ language plpgsql;
