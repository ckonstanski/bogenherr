drop function contact.insert_contact_us_post (
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying,
    p_comments text
);

create or replace function contact.insert_contact_us_post (
    p_first_name character varying,
    p_last_name character varying,
    p_email character varying,
    p_phone character varying,
    p_comments text
)
returns bigint
as $$
declare
  l_id bigint;
begin
    insert into contact.contact_us_posts (
        first_name,
        last_name,
        email,
        phone,
        comments
    ) values (
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_comments
    );

    select id into l_id
    from contact.contact_us_posts
    where first_name = p_first_name
        and last_name = p_last_name
        and email = p_email
        and phone = p_phone
        and comments = p_comments;

    return l_id;
end;
$$ language plpgsql;
