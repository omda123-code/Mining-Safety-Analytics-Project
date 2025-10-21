use [Osha gov]
select * from mining_accidents

------------------  1. DESCRIPTIVE ANALYSIS -------------------

-- 1. What are the most common accident classifications?
-- Purpose: Identify the main types of incidents to focus safety measures.

SELECT ai_class_desc, COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY ai_class_desc
ORDER BY total_accidents DESC;

-- 2. Which mining subunits report the most accidents?
-- Purpose: Discover where most incidents occur (underground, open pit, etc.).

SELECT subunit_desc, COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY subunit_desc
ORDER BY total_accidents DESC;

-- 3. Which states have the highest number of accidents?
-- Purpose: Identify geographic hotspots of mining risk.

SELECT fips_state_cd, COUNT(*) AS accident_count
FROM mining_accidents
GROUP BY fips_state_cd
ORDER BY accident_count DESC;

-- 4. How many accidents occur by shift start time?
-- Purpose: Check whether night or early shifts are more accident-prone.

SELECT shift_begin_time, COUNT(*) AS accident_count
FROM mining_accidents
GROUP BY shift_begin_time
ORDER BY accident_count DESC;

-- 5. Which occupations are most frequently injured?
-- Purpose: Detect high-risk job roles in mining operations.

SELECT ai_occ_desc, COUNT(*) AS total_injuries
FROM mining_accidents
GROUP BY ai_occ_desc
ORDER BY total_injuries DESC;

-- 6. What is the distribution of accident types across mining methods?
-- Purpose: Compare safety between underground vs. surface methods.

SELECT ug_mining_method, accident_type, COUNT(*) AS total
FROM mining_accidents
GROUP BY ug_mining_method, accident_type
ORDER BY total DESC;

-- 7. Which contractors have the highest accident counts?
-- Purpose: Track contractor safety performance.

SELECT cntctr_id, COUNT(*) AS total_accidents
FROM mining_accidents
WHERE cntctr_id IS NOT NULL
GROUP BY cntctr_id
ORDER BY total_accidents DESC;


--------------------  2. SEVERITY & IMPACT ANALYSIS -----------------------
 
-- 1. What is the average number of days lost per accident type?
-- Purpose: Measure impact on productivity and recovery.

SELECT accident_type, AVG(cast(days_lost as int)) AS avg_days_lost
FROM mining_accidents
WHERE days_lost IS NOT NULL
GROUP BY accident_type
ORDER BY avg_days_lost DESC;

-- 2. Which types of injuries result in the longest absences?
-- Purpose: Identify the most severe injury types.

SELECT nature_injury, AVG(cast(days_lost as int)) AS avg_lost_days
FROM mining_accidents
WHERE days_lost IS NOT NULL
GROUP BY nature_injury
ORDER BY avg_lost_days DESC;

-- 3. What are the top body parts most frequently injured?
-- Purpose: Help define PPE (Personal Protective Equipment) priorities.

SELECT inj_body_part, COUNT(*) AS injuries
FROM mining_accidents
GROUP BY inj_body_part
ORDER BY injuries DESC;

-- 4. What percentage of accidents led to lost workdays vs restricted work?
-- Purpose: Compare temporary vs severe impacts.

SELECT
  SUM(CASE WHEN days_lost > 0 THEN 1 ELSE 0 END) AS lost_work_cases,
  SUM(CASE WHEN days_restrict > 0 THEN 1 ELSE 0 END) AS restricted_work_cases,
  COUNT(*) AS total_cases,
  ROUND(SUM(CASE WHEN days_lost > 0 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS pct_lost_work
FROM mining_accidents;

-- 5. How many fatal or permanent disability accidents occurred per year?
-- Purpose: Monitor fatality trends.

SELECT ai_year, COUNT(*) AS fatal_cases
FROM mining_accidents
WHERE inj_degr_desc IN ('FATAL', 'PERMANENT DISABILITY')
GROUP BY ai_year
ORDER BY ai_year;


------------------- 3. ROOT CAUSE ANALYSIS ------------------

-- 1. Which activities are linked to the most accidents?
-- Purpose: Determine unsafe job activities (e.g., maintenance, loading).

SELECT ai_acty_desc, COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY ai_acty_desc
ORDER BY total_accidents DESC;

-- 2. Which equipment types are involved in most accidents?
-- Purpose: Identify high-risk machinery.

SELECT mining_equip, COUNT(*) AS accident_count
FROM mining_accidents
GROUP BY mining_equip
ORDER BY accident_count DESC;

-- 3. Which manufacturers’ equipment is most often in accidents?
-- Purpose: Evaluate supplier-related safety issues.

SELECT equip_mfr_name, COUNT(*) AS accidents
FROM mining_accidents
WHERE equip_mfr_name IS NOT NULL
GROUP BY equip_mfr_name
ORDER BY accidents DESC;

-- 4. Which experience level group has the highest injury rate?
-- Purpose: Test if new workers are at higher risk.

SELECT
  CASE
    WHEN exper_tot_calc < 1 THEN 'Less than 1 year'
    WHEN exper_tot_calc BETWEEN 1 AND 5 THEN '1-5 years'
    WHEN exper_tot_calc BETWEEN 6 AND 10 THEN '6-10 years'
    ELSE 'More than 10 years'
  END AS experience_group,
  COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY 
  CASE
    WHEN exper_tot_calc < 1 THEN 'Less than 1 year'
    WHEN exper_tot_calc BETWEEN 1 AND 5 THEN '1-5 years'
    WHEN exper_tot_calc BETWEEN 6 AND 10 THEN '6-10 years'
    ELSE 'More than 10 years'
  END
ORDER BY total_accidents DESC;


-- 5. Does experience level affect severity (days lost)?
-- Purpose: Correlate experience with injury impact.

SELECT
  CASE
    WHEN exper_tot_calc < 1 THEN 'Less than 1 year'
    WHEN exper_tot_calc BETWEEN 1 AND 5 THEN '1-5 years'
    WHEN exper_tot_calc BETWEEN 6 AND 10 THEN '6-10 years'
    ELSE 'More than 10 years'
  END AS experience_group,
  AVG(cast(days_lost as int)) AS avg_days_lost
FROM mining_accidents
WHERE days_lost IS NOT NULL
GROUP BY 
  CASE
    WHEN exper_tot_calc < 1 THEN 'Less than 1 year'
    WHEN exper_tot_calc BETWEEN 1 AND 5 THEN '1-5 years'
    WHEN exper_tot_calc BETWEEN 6 AND 10 THEN '6-10 years'
    ELSE 'More than 10 years'
  END
ORDER BY avg_days_lost DESC;


-- 6. What are the main injury sources?
-- Purpose: Detect primary sources like “Roof Fall”, “Machinery”, etc.

SELECT injury_source, COUNT(*) AS total_cases
FROM mining_accidents
GROUP BY injury_source
ORDER BY total_cases DESC;

-- 7. What accident types are linked to specific injury sources?
-- Purpose: Understand the relationship between cause and effect.

SELECT accident_type, injury_source, COUNT(*) AS total
FROM mining_accidents
GROUP BY accident_type, injury_source
ORDER BY total DESC;


------------------ 4. TREND & PREDICTIVE INSIGHTS -------------------

-- 1. What is the overall yearly trend of accidents?
-- Purpose: Track improvement or deterioration in safety.

SELECT ai_year, COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY ai_year
ORDER BY ai_year;

-- 2. How have “days lost” averages changed yearly?
-- Purpose: Measure how injury severity changes over time.

SELECT ai_year, AVG(cast(days_lost as int)) AS avg_days_lost
FROM mining_accidents
WHERE days_lost IS NOT NULL
GROUP BY ai_year
ORDER BY ai_year;

-- 3. What is the average delay between accident and investigation start?
-- Purpose: Evaluate responsiveness of safety teams.

SELECT AVG(DATEDIFF(day, ai_dt, invest_begin_dt)) AS avg_days_to_investigate
FROM mining_accidents
WHERE invest_begin_dt IS NOT NULL;

-- 4. What is the average delay between accident and return to work?
-- Purpose: Understand rehabilitation duration trends.

SELECT AVG(DATEDIFF(day, ai_dt, return_to_work_dt)) AS avg_recovery_days
FROM mining_accidents
WHERE return_to_work_dt IS NOT NULL;

-- 5. Compare accident counts between quarters in each year.
-- Purpose: Detect seasonal or operational cycles.

SELECT cal_yr, cal_qtr, COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY cal_yr, cal_qtr
ORDER BY cal_yr, cal_qtr;

-- 6. Which accident types are increasing or decreasing over time?
-- Purpose: Identify emerging safety threats.

SELECT ai_year, accident_type, COUNT(*) AS total
FROM mining_accidents
GROUP BY ai_year, accident_type
ORDER BY ai_year, total DESC;


---------------------- 5. PERFORMANCE & COMPLIANCE METRICS --------------------

-- 1. What percentage of accidents were reported immediately?
-- Purpose: Check compliance with incident reporting regulations.

SELECT immed_notify, COUNT(*) AS total,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM mining_accidents), 2) AS percentage
FROM mining_accidents
GROUP BY immed_notify;

-- 2. What is the distribution of accident closure times?
-- Purpose: Evaluate how quickly cases are closed.

SELECT
  CASE
    WHEN DATEDIFF(day, TRY_CONVERT(DATE, ai_dt, 103), TRY_CONVERT(DATE, invest_begin_dt, 103)) <= 30 THEN '≤30 days'
    WHEN DATEDIFF(day, TRY_CONVERT(DATE, ai_dt, 103), TRY_CONVERT(DATE, invest_begin_dt, 103)) BETWEEN 31 AND 90 THEN '31–90 days'
    ELSE '>90 days'
  END AS closure_range,
  COUNT(*) AS total_cases
FROM mining_accidents
WHERE TRY_CONVERT(DATE, ai_dt, 103) IS NOT NULL
  AND TRY_CONVERT(DATE, invest_begin_dt, 103) IS NOT NULL
GROUP BY 
  CASE
    WHEN DATEDIFF(day, TRY_CONVERT(DATE, ai_dt, 103), TRY_CONVERT(DATE, invest_begin_dt, 103)) <= 30 THEN '≤30 days'
    WHEN DATEDIFF(day, TRY_CONVERT(DATE, ai_dt, 103), TRY_CONVERT(DATE, invest_begin_dt, 103)) BETWEEN 31 AND 90 THEN '31–90 days'
    ELSE '>90 days'
  END
ORDER BY total_cases DESC;



-- 3. Which mines have the highest injury frequency?
-- Purpose: Identify poor safety performance at site level.

SELECT mine_id, COUNT(*) AS total_accidents
FROM mining_accidents
GROUP BY mine_id
ORDER BY total_accidents DESC;

-- 4. Compare coal vs metal industries in terms of accident frequency and severity.
-- Purpose: Benchmark performance between industries.

SELECT coal_metal_ind,
       COUNT(*) AS total_accidents,
       AVG(cast(days_lost as int)) AS avg_days_lost
FROM mining_accidents
GROUP BY coal_metal_ind;

-- 5. What are the most common accident types per mining equipment?
-- Purpose: Connect incident types with specific machinery.

SELECT mining_equip, accident_type, COUNT(*) AS total
FROM mining_accidents
GROUP BY mining_equip, accident_type
ORDER BY total DESC;

-- 6. Which activities are causing severe (long-term) injuries most often?
-- Purpose: Target operational hazards leading to major losses.

SELECT ai_acty_desc, AVG(cast(days_lost as int)) AS avg_days_lost, COUNT(*) AS cases
FROM mining_accidents
WHERE days_lost IS NOT NULL
GROUP BY ai_acty_desc
ORDER BY avg_days_lost DESC;

-- 7. Correlate injury source with body part affected.
-- Purpose: Reveal cause-effect patterns for preventive design.

SELECT injury_source, inj_body_part, COUNT(*) AS total
FROM mining_accidents
GROUP BY injury_source, inj_body_part
ORDER BY total DESC;

-- 8. Rank mines by total lost days.
-- Purpose: Identify sites with the greatest operational downtime.

SELECT mine_id, SUM(cast(days_lost as int)) AS total_lost_days
FROM mining_accidents
GROUP BY mine_id
ORDER BY total_lost_days DESC;

-- 9. Average investigation delay per mine.
-- Purpose: Find mines with weak safety management responsiveness.

SELECT mine_id, AVG(DATEDIFF(day, ai_dt, invest_begin_dt)) AS avg_invest_delay
FROM mining_accidents
WHERE invest_begin_dt IS NOT NULL
GROUP BY mine_id
ORDER BY avg_invest_delay DESC;

-- 10. Identify mines with repeated similar accident types.
-- Purpose: Detect systemic, recurring safety issues.

SELECT mine_id, accident_type, COUNT(*) AS repeated_cases
FROM mining_accidents
GROUP BY mine_id, accident_type
HAVING COUNT(*) > 5
ORDER BY repeated_cases DESC;