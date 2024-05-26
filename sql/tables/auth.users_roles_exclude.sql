drop table auth.users_roles_exclude cascade;

create table auth.users_roles_exclude (
    id serial8 primary key,
    user_id bigint not null references auth.users(id),
    role_id bigint not null references auth.roles(id)
);
