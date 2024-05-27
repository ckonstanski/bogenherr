drop function general.get_gallery (
    p_id bigint
);

create or replace function general.get_gallery (
    p_id bigint
)
returns setof general.gallery_t
as $$
begin
    return query
    select g.id,
        g.description,
        g.filename,
        g.mime_type,
        g.video_embed_url,
        case
          when g.content is null then null
          else substring(g.content::text from 3)
        end as content,
        g.created,
        g.modified
    from general.gallery g
    where g.id = p_id;

    return;
end;
$$ language plpgsql;
