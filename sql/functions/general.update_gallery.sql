drop function general.update_gallery (
    p_id bigint,
    p_description text,
    p_filename character varying,
    p_mime_type character varying,
    p_hex text
);

create or replace function general.update_gallery (
    p_id bigint,
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
    select g.id into l_id
    from general.gallery g
    where g.id = p_id;

    if(l_id is not null) then
        update general.gallery
        set description = p_description,
            filename = p_filename,
            mime_type = p_mime_type,
            content = decode(p_hex, 'hex'),
            modified = now()
        where id = p_id;

        select g.id into l_id
        from general.gallery g
        where g.id = p_id;

        return l_id;
    else
        return null;
    end if;
end;
$$ language plpgsql;
