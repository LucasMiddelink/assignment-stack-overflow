{{ config(materialized="table") }}

with
    date_spine as (
        -- Generate dates from 2008 (Stack Overflow launch) to current date + 1 year
        select
            date_add(
                '2008-01-01', interval row_number() over (order by 1) - 1 day
            ) as calendar_date
        from
            unnest(
                generate_array(
                    1,
                    date_diff(
                        date_add(current_date(), interval 365 day), '2008-01-01', day
                    )
                )
            ) as t
    ),

    date_attributes as (
        select
            -- Primary key (YYYYMMDD format)
            cast(format_date('%Y%m%d', calendar_date) as int64) as date_id,

            -- Date attributes
            calendar_date,
            extract(year from calendar_date) as year,
            extract(month from calendar_date) as month,
            extract(day from calendar_date) as day,
            extract(quarter from calendar_date) as quarter,
            extract(dayofweek from calendar_date) as day_of_week,
            extract(dayofyear from calendar_date) as day_of_year,
            extract(week from calendar_date) as week_of_year,

            -- Business-friendly attributes
            format_date('%B', calendar_date) as month_name,
            format_date('%A', calendar_date) as day_name,
            format_date('%Y-Q%q', calendar_date) as year_quarter,
            format_date('%Y-%m', calendar_date) as year_month,

            -- Flags
            case
                when extract(dayofweek from calendar_date) in (1, 7)
                then true
                else false
            end as is_weekend,

            -- Metadata
            current_timestamp() as dim_created_at,
            current_timestamp() as dim_updated_at

        from date_spine
    )

select *
from date_attributes
