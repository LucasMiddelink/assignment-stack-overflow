{{ config(materialized="view") }}

with
    source_data as (
        select
            -- Primary key
            id as tag_id,

            -- Tag information
            tag_name,
            count as tag_usage_count

        from {{ source("stackoverflow", "tags") }}

        -- Filter for data quality
        where
            id is not null and tag_name is not null and count is not null and count > 0  -- Only tags that have been used
    ),

    final as (
        select
            *,

            -- Popularity tiers based on actual usage
            case
                when tag_usage_count >= 100000
                then 'high_usage'
                when tag_usage_count >= 10000
                then 'medium_usage'
                else 'low_usage'
            end as tag_popularity_tier,

            -- Clean tag name for display
            tag_name as tag_display_name

        from source_data
    )

select *
from final
