drop table auth.users_role_groups cascade;

create table auth.users_role_groups (
    id serial8 primary key,
    user_id bigint not null references auth.users(id),
    role_group_id bigint not null references auth.role_groups(id)
);
