{{ config(materialized="view") }}

with
    source_data as (
        select
            -- Primary key
            id as user_id,

            -- User profile information
            display_name as user_display_name,

            -- User expertise indicators
            reputation,
            up_votes,
            views as profile_views,

            -- User activity timing
            creation_date as user_created_at

        from {{ source("stackoverflow", "users") }}

        -- Filter for data quality
        where id is not null and creation_date is not null
    ),

    final as (
        select
            *,

            -- User expertise level based on reputation
            case
                when reputation >= 10000  then 'expert'
                when reputation >= 2000  then 'experienced'
                when reputation >= 500   then 'active'
                when reputation IS NULL then 'Unknown'
                else 'novice'
            end as user_expertise_level,

            -- Account age in days
            date_diff(current_date(), date(user_created_at), day) as account_age_days,

            -- Extract date for joining to date dimension later
            date(user_created_at) as user_join_date

        from source_data
    )

select *
from final