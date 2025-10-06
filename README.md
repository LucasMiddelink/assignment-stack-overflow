Dashboard: https://lookerstudio.google.com/reporting/5853456b-ffa8-4663-a534-bf4248b4b9f2
# Stack Overflow Analytics - Dimensional Data Model

## Project Overview

This dbt project analyzes Stack Overflow data to answer the business question: **"Which topics have the highest need for answers?"**

Built as a dimensional star schema model using Stack Overflow's public dataset from BigQuery.

## Architecture

### Data Sources
- **Stack Overflow Public Dataset** (`bigquery-public-data.stackoverflow`)
  - Questions, answers, users, tags, and votes data

### Dimensional Model
- **Fact Table:** `fact_questions` - One row per question with metrics
- **Dimensions:** `dim_tags`, `dim_users`, `dim_date`
- **Analysis View:** Pre-joined view optimized for dashboard analysis

### Key Metrics
- `unanswered_question_count` - Questions with zero answers
- `no_accepted_answer_count` - Questions without accepted solutions
- `answer_count` - Total answers per question
- `view_count` - Question popularity

## Project Structure

```
models/
├── staging/
│   ├── sources.yml                    # Source definitions
│   ├── stg_stackoverflow__questions.sql
│   ├── stg_stackoverflow__tags.sql
│   └── stg_stackoverflow__users.sql
├── marts/
│   ├── dim_tags.sql                   # Topic dimension
│   ├── dim_users.sql                  # User dimension  
│   ├── dim_date.sql                   # Time dimension
│   ├── fact_questions.sql             # Main fact table
│   └── analysis_view.sql              # Dashboard-ready view
└── schema.yml                         # Documentation & tests
```

## Quick Start

### Prerequisites
- dbt Cloud account
- BigQuery project with billing enabled
- Access to `bigquery-public-data.stackoverflow`

### Running the Project

```bash
# Install dependencies and run models
dbt run

# Run data quality tests
dbt test

# Generate documentation
dbt docs generate
```

### Key Findings

**Top 5 Topics Needing Answers:**
1. Python
2. JavaScript
3. ReactJS
4. Java
5. Android

**Top 5 Topics Needing Better Quality Answers:**
1. Python
2. Javascript
3. ReactJS
4. Java
5. C#

**Insights:**
- Most topics have 2x more "no accepted answer" than "completely unanswered"
- Indicates answer quality issues rather than lack of responses
- Popular languages dominate both question volume and unanswered rates

## Dashboard

Interactive Looker Studio dashboard available showing:
- Topics ranked by unanswered question counts
- Answer quality analysis (unanswered vs no accepted answer)
- User expertise distribution by topic
- Temporal trends in question patterns

## Data Model Design

### Star Schema Benefits
- **Simple joins** from fact to dimensions
- **Fast aggregations** for dashboard queries
- **Business-friendly** structure for analysts
- **Scalable** design for additional metrics

### Business Logic
- Questions filtered to 2022+ (manageable data size)
- Tags parsed from pipe-separated format
- User expertise classified by reputation thresholds
- Degenerate dimensions for commonly-used attributes
