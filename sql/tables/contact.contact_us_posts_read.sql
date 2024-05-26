drop table contact.contact_us_posts_read cascade;

create table contact.contact_us_posts_read (
    id serial8 primary key,
    contact_us_post_id bigint not null references contact.contact_us_posts(id),
    user_id bigint not null references auth.users(id)
);
