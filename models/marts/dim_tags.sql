{{ config(materialized="table") }}

select
    -- Primary key
    tag_id,

    -- Tag attributes
    tag_name,
    tag_display_name,
    tag_usage_count,
    tag_popularity_tier,

    -- Metadata
    current_timestamp() as dim_created_at,
    current_timestamp() as dim_updated_at

from {{ ref("stg_stackoverflow__tags") }}

-- Only include tags with meaningful usage for analysis
where tag_usage_count >= 10
