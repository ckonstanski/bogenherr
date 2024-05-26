drop table auth.user_session_objects cascade;

create table auth.user_session_objects (
    id serial8 primary key,
    user_session_id bigint not null references auth.user_sessions(id),
    session_key character varying(255),
    serialization text
);
