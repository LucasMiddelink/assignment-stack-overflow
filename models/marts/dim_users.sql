{{ config(materialized="table") }}

select
    -- Primary key
    user_id,

    -- User attributes
    user_display_name,
    user_expertise_level,
    reputation,
    up_votes,
    profile_views,
    account_age_days,
    user_join_date,

    -- Metadata
    current_timestamp() as dim_created_at,
    current_timestamp() as dim_updated_at

from {{ ref("stg_stackoverflow__users") }}
