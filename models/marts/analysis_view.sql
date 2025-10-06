{{ config(materialized='view') }}

with base_data as (
    select 
        -- Question details
        f.question_id,
        f.question_date,
        f.tags,
        
        -- Metrics
        f.unanswered_question_count,
        f.no_accepted_answer_count,
        f.long_unanswered_count,
        f.answer_count,
        f.view_count,
        f.question_score,
        f.days_since_asked,
        
        -- User context
        u.user_display_name,
        u.user_expertise_level,
        u.reputation,
        
        -- Date context
        d.calendar_date,
        d.year,
        d.month,
        d.month_name,
        d.quarter,
        d.day_name,
        d.is_weekend
        
    from {{ ref('fact_questions') }} f
    left join {{ ref('dim_users') }} u 
        on f.user_id = u.user_id
    left join {{ ref('dim_date') }} d 
        on f.date_id = d.date_id
),

tags_expanded as (
    select 
        *,
        trim(tag) as individual_tag
    from base_data,
    unnest(split(tags, '|')) as tag
    where trim(tag) != ''
)

select * from tags_expanded