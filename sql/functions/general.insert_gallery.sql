drop function general.insert_gallery (
    p_description text,
    p_filename character varying,
    p_mime_type character varying,
    p_hex text
);

create or replace function general.insert_gallery (
    p_description text,
    p_filename character varying,
    p_mime_type character varying,
    p_hex text
)
returns bigint
as $$
declare
  l_id bigint;
begin
    insert into general.gallery (
        description,
        filename,
        mime_type,
        content
    ) values (
        p_description,
        p_filename,
        p_mime_type,
        decode(p_hex, 'hex')
    ) returning id into l_id;

    return l_id;
end;
$$ language plpgsql;
