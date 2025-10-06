/* 
NOTE: materialized is better to have 'incremental' but requires billing to be enabled.
-- For incremental config:
    unique_key='question_id',
    on_schema_change='fail'
*/
{{ config(
    materialized='view'
) }}

with questions_base as (
    select *
    from {{ ref('stg_stackoverflow__questions') }}
    -- Date is set to stay within free tier limit
    where question_date >= '2022-01-01'
    
    
    /*
    {% if is_incremental() %}
        -- Only process questions new data since last run
        and (
            question_created_at > (select max(fact_created_at) from {{ this }})
            or question_last_activity_at > (select max(fact_created_at) from {{ this }})
        )
    {% endif %}
    */
),

final as (
    select 
        -- Primary key
        question_id,
        
        -- Foreign keys to dimensions  
        question_owner_user_id as user_id,
        cast(format_date('%Y%m%d', question_date) as int64) as date_id,
        
        -- Degenerate dimensions
        question_date,
        tags, -- Tags stored as pipe separated string
        
        -- for analysis
        answer_count,
        view_count,
        score as question_score,
        days_since_asked,
        
        -- Renaming for clarity in dashboard
        is_unanswered as unanswered_question_count,
        is_no_accepted_answer as no_accepted_answer_count,
        
        -- Derived measures
        -- Unanswered longer then 90 days
        case 
            when days_since_asked > 90 and is_unanswered = 1 then 1 
            else 0 
        end as long_unanswered_count,
        
        -- Metadata
        current_timestamp() as fact_created_at
        
    from questions_base
    where tags is not null 
      and tags != ''
)

select * from final