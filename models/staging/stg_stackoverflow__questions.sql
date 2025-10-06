{{ config(materialized="view") }}

with
    source_data as (
        select
            -- Primary key and identifiers
            id as question_id,

            -- Answer status
            accepted_answer_id,
            safe_cast(answer_count as int64) as answer_count,

            -- Quality and engagement metrics  
            score,
            safe_cast(view_count as int64) as view_count,

            -- Timing information
            creation_date as question_created_at,
            last_activity_date as question_last_activity_at,

            -- Topic information
            tags,

            -- Question owner
            owner_user_id as question_owner_user_id

        from {{ source("stackoverflow", "posts_questions") }}

        -- Filter for data quality (remove test/invalid records)
        where id is not null and creation_date is not null
    ),

    final as (
        select
            *,

            -- Is this question completely unanswered?
            case when answer_count = 0 then 1 else 0 end as is_unanswered,

            -- Is this question under-served? (no accepted answer)
            case
                when accepted_answer_id is null then 1 else 0
            end as is_no_accepted_answer,

            -- How many days since question was asked?
            date_diff(
                current_date(), date(question_created_at), day
            ) as days_since_asked,

            -- Extract date for joining to date dimension later
            date(question_created_at) as question_date

        from source_data
    )

select *
from final
