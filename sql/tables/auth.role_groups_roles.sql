drop table auth.role_groups_roles cascade;

create table auth.role_groups_roles (
    id serial8 primary key,
    role_group_id bigint not null references auth.role_groups(id),
    role_id bigint not null references auth.roles(id)
);
