-- =====================================================
-- VIEWS AND STORED PROCEDURES
-- Version: 1.0.0
-- Date: 2025-01-27
-- Purpose: Database views and stored procedures for business logic
-- =====================================================

-- ✅ CORE BUSINESS VIEWS

-- Progressive tuition view with related data
CREATE OR REPLACE VIEW v_progressive_tuition AS
SELECT
    pt.id,
    pt.program_id,
    p.code AS program_code,
    p.name AS program_name,
    pt.year,
    pt.semester_group_1_3_fee,
    pt.semester_group_4_6_fee,
    pt.semester_group_7_9_fee,
    c.id AS campus_id,
    c.code AS campus_code,
    c.name AS campus_name,
    c.discount_percentage,
    ff.standard_fee AS foundation_standard_fee,
    ff.discounted_fee AS foundation_discounted_fee,
    pt.is_active,
    pt.created_at
FROM progressive_tuition pt
JOIN campuses c ON pt.campus_id = c.id
JOIN programs p ON pt.program_id = p.id
LEFT JOIN foundation_fees ff ON ff.campus_id = c.id AND ff.year = pt.year AND ff.is_active = true
WHERE pt.is_active = true AND c.is_active = true AND p.is_active = true;

-- Materialized view for program search optimization
CREATE MATERIALIZED VIEW mv_program_search AS
SELECT
    p.id,
    p.code,
    p.name,
    p.name_en,
    d.name as department,
    d.code as department_code,
    p.duration_years,
    string_agg(DISTINCT c.code || ':' || c.name, '; ') as campus_info,
    string_agg(DISTINCT c.code, ', ') as campus_codes,
    COUNT(DISTINCT c.id) as campus_count,
    MIN(pt.semester_group_1_3_fee) as min_tuition,
    MAX(pt.semester_group_7_9_fee) as max_tuition,
    AVG((pt.semester_group_1_3_fee + pt.semester_group_4_6_fee + pt.semester_group_7_9_fee) / 3)::DECIMAL(15,2) as avg_tuition,
    p.code || ' ' || p.name || ' ' || COALESCE(p.name_en, '') || ' ' || d.name as search_text
FROM programs p
JOIN departments d ON d.id = p.department_id
LEFT JOIN program_campus_availability pca ON pca.program_id = p.id AND pca.is_available = true
LEFT JOIN campuses c ON c.id = pca.campus_id AND c.is_active = true
LEFT JOIN progressive_tuition pt ON pt.program_id = p.id AND pt.is_active = true
WHERE p.is_active = true AND d.is_active = true
GROUP BY p.id, p.code, p.name, p.name_en, d.name, d.code, p.duration_years;

-- Index for materialized view
CREATE INDEX idx_mv_program_search_code ON mv_program_search(code);
CREATE INDEX idx_mv_program_search_text ON mv_program_search USING gin(search_text gin_trgm_ops);

-- ✅ APPLICATION MANAGEMENT VIEWS

-- Complete application information view
CREATE OR REPLACE VIEW v_applications_complete AS
SELECT
    a.id,
    a.application_code,
    a.student_name,
    a.email,
    a.phone,
    a.date_of_birth,
    a.gender,
    a.address,
    a.high_school_name,
    a.graduation_year,
    a.status,
    a.source,
    a.chatbot_session_id,
    a.submitted_at,
    a.processed_at,
    a.notes,
    a.admin_notes,
    p.code AS program_code,
    p.name AS program_name,
    d.name AS department_name,
    c.code AS campus_code,
    c.name AS campus_name,
    c.city AS campus_city,
    am.name AS admission_method,
    s.name AS scholarship_name,
    s.percentage AS scholarship_percentage,
    u.username AS processed_by_user,
    COUNT(ad.id) AS document_count
FROM applications a
JOIN programs p ON a.program_id = p.id
JOIN departments d ON p.department_id = d.id
JOIN campuses c ON a.campus_id = c.id
LEFT JOIN admission_methods am ON a.admission_method_id = am.id
LEFT JOIN scholarships s ON a.scholarship_id = s.id
LEFT JOIN users u ON a.processed_by = u.id
LEFT JOIN application_documents ad ON a.id = ad.application_id
GROUP BY a.id, a.application_code, a.student_name, a.email, a.phone, a.date_of_birth,
         a.gender, a.address, a.high_school_name, a.graduation_year, a.status, a.source,
         a.chatbot_session_id, a.submitted_at, a.processed_at, a.notes, a.admin_notes,
         p.code, p.name, d.name, c.code, c.name, c.city, am.name, s.name, s.percentage, u.username;

-- Application statistics view
CREATE OR REPLACE VIEW v_application_stats AS
SELECT
    COUNT(*) as total_applications,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_count,
    COUNT(*) FILTER (WHERE status = 'reviewing') as reviewing_count,
    COUNT(*) FILTER (WHERE status = 'approved') as approved_count,
    COUNT(*) FILTER (WHERE status = 'rejected') as rejected_count,
    COUNT(*) FILTER (WHERE source = 'chatbot') as chatbot_applications,
    COUNT(*) FILTER (WHERE submitted_at >= CURRENT_DATE) as today_applications,
    COUNT(*) FILTER (WHERE submitted_at >= CURRENT_DATE - INTERVAL '7 days') as week_applications,
    AVG(EXTRACT(EPOCH FROM (processed_at - submitted_at))/3600) FILTER (WHERE processed_at IS NOT NULL) as avg_processing_hours
FROM applications;

-- ✅ MONITORING VIEWS

-- Table sizes monitoring
CREATE VIEW v_table_sizes AS
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Data summary view
CREATE VIEW v_data_summary AS
SELECT
    'departments' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE is_active = true) as active_records,
    MAX(created_at) as latest_created
FROM departments
UNION ALL
SELECT 'programs', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM programs
UNION ALL
SELECT 'campuses', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM campuses
UNION ALL
SELECT 'scholarships', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM scholarships
UNION ALL
SELECT 'progressive_tuition', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM progressive_tuition
UNION ALL
SELECT 'foundation_fees', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM foundation_fees
UNION ALL
SELECT 'admission_methods', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM admission_methods
UNION ALL
SELECT 'users', COUNT(*), COUNT(*) FILTER (WHERE is_active = true), MAX(created_at) FROM users
UNION ALL
SELECT 'applications', COUNT(*), COUNT(*) FILTER (WHERE status != 'cancelled'), MAX(created_at) FROM applications
UNION ALL
SELECT 'application_documents', COUNT(*), COUNT(*), MAX(created_at) FROM application_documents
UNION ALL
SELECT 'chatbot_conversations', COUNT(*), COUNT(*) FILTER (WHERE ended_at IS NOT NULL), MAX(created_at) FROM chatbot_conversations
UNION ALL
SELECT 'chat_messages', COUNT(*), COUNT(*), MAX(timestamp) FROM chat_messages
UNION ALL
SELECT 'user_intents', COUNT(*), COUNT(*) FILTER (WHERE resolved = true), MAX(created_at) FROM user_intents
UNION ALL
SELECT 'chatbot_analytics', COUNT(*), COUNT(*), MAX(created_at) FROM chatbot_analytics;

-- ✅ STORED PROCEDURES

-- Search programs with ranking
CREATE OR REPLACE FUNCTION search_programs_ranked(
    search_query VARCHAR,
    limit_results INTEGER DEFAULT 20
) RETURNS TABLE (
    code VARCHAR,
    name VARCHAR,
    name_en VARCHAR,
    department VARCHAR,
    campuses TEXT,
    min_tuition DECIMAL,
    max_tuition DECIMAL,
    relevance_score REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        mv.code,
        mv.name,
        mv.name_en,
        mv.department,
        mv.campus_codes,
        mv.min_tuition,
        mv.max_tuition,
        CASE
            WHEN LOWER(mv.code) = LOWER(search_query) THEN 1.0
            WHEN LOWER(mv.name) = LOWER(search_query) THEN 0.9
            WHEN LOWER(mv.name_en) = LOWER(search_query) THEN 0.9
            ELSE similarity(mv.search_text, search_query)
        END as relevance_score
    FROM mv_program_search mv
    WHERE
        similarity(mv.search_text, search_query) > 0.1
        OR LOWER(mv.code) = LOWER(search_query)
        OR LOWER(mv.search_text) LIKE LOWER('%' || search_query || '%')
    ORDER BY
        relevance_score DESC,
        mv.name
    LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- ✅ REAL-TIME DASHBOARD VIEWS

-- Live application dashboard (real-time, no materialization needed)
CREATE OR REPLACE VIEW v_live_dashboard AS
SELECT
    'applications_today' as metric,
    COUNT(*)::text as value,
    'Total applications submitted today' as description
FROM applications
WHERE submitted_at >= CURRENT_DATE
UNION ALL
SELECT
    'pending_applications',
    COUNT(*)::text,
    'Applications awaiting review'
FROM applications
WHERE status = 'pending'
UNION ALL
SELECT
    'active_conversations',
    COUNT(*)::text,
    'Ongoing chatbot conversations'
FROM chatbot_conversations
WHERE ended_at IS NULL AND started_at >= CURRENT_DATE - INTERVAL '1 hour'
UNION ALL
SELECT
    'top_program_today',
    COALESCE(p.code, 'N/A'),
    'Most applied program today'
FROM applications a
JOIN programs p ON a.program_id = p.id
WHERE a.submitted_at >= CURRENT_DATE
GROUP BY p.code, p.name
ORDER BY COUNT(*) DESC
LIMIT 1
UNION ALL
SELECT
    'conversion_rate_today',
    COALESCE(ROUND(COUNT(*) FILTER (WHERE status = 'approved') * 100.0 / NULLIF(COUNT(*), 0), 1)::text || '%', '0%'),
    'Today approval rate'
FROM applications
WHERE submitted_at >= CURRENT_DATE;

-- Fee calculator view (optimized for API responses)
CREATE OR REPLACE VIEW v_fee_calculator AS
SELECT
    p.code as program_code,
    p.name as program_name,
    c.code as campus_code,
    c.name as campus_name,
    c.discount_percentage,
    pt.semester_group_1_3_fee,
    pt.semester_group_4_6_fee,
    pt.semester_group_7_9_fee,
    ff.standard_fee as foundation_standard,
    ff.discounted_fee as foundation_discounted,
    -- Calculate total program cost
    (pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3) as total_tuition,
    -- Calculate with foundation fee
    (pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3 + ff.discounted_fee) as total_cost,
    -- Savings calculation
    CASE
        WHEN c.discount_percentage > 0 THEN
            ((pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3) * c.discount_percentage / 100)
        ELSE 0
    END as total_savings
FROM progressive_tuition pt
JOIN programs p ON pt.program_id = p.id
JOIN campuses c ON pt.campus_id = c.id
JOIN foundation_fees ff ON ff.campus_id = c.id AND ff.year = pt.year
WHERE pt.is_active = true AND p.is_active = true AND c.is_active = true AND ff.is_active = true
ORDER BY p.code, c.code;

-- Refresh materialized views
CREATE OR REPLACE FUNCTION refresh_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_program_search;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_admission_funnel;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_program_popularity;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_campus_performance;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_scholarship_analytics;

    -- Log refresh activity
    INSERT INTO chatbot_analytics (metric_date, metric_type, metric_value, metadata)
    VALUES (CURRENT_DATE, 'materialized_view_refresh', 1,
            jsonb_build_object('refreshed_at', CURRENT_TIMESTAMP, 'views_count', 5));
END;
$$ LANGUAGE plpgsql;

-- Generate unique application code
CREATE OR REPLACE FUNCTION generate_application_code()
RETURNS VARCHAR(20) AS $$
DECLARE
    new_code VARCHAR(20);
    year_suffix VARCHAR(4);
    counter INTEGER;
BEGIN
    year_suffix := EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR;

    -- Get next sequence number for this year
    SELECT COALESCE(MAX(CAST(SUBSTRING(application_code FROM 4 FOR 6) AS INTEGER)), 0) + 1
    INTO counter
    FROM applications
    WHERE application_code LIKE 'APP' || year_suffix || '%';

    new_code := 'APP' || year_suffix || LPAD(counter::VARCHAR, 6, '0');

    RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- Update application status with processing info
CREATE OR REPLACE FUNCTION update_application_status(
    app_id UUID,
    new_status VARCHAR(20),
    processor_id UUID DEFAULT NULL,
    admin_note TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE applications
    SET
        status = new_status,
        processed_at = CASE WHEN new_status != 'pending' THEN CURRENT_TIMESTAMP ELSE processed_at END,
        processed_by = CASE WHEN processor_id IS NOT NULL THEN processor_id ELSE processed_by END,
        admin_notes = CASE WHEN admin_note IS NOT NULL THEN admin_note ELSE admin_notes END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = app_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Get application statistics by period
CREATE OR REPLACE FUNCTION get_application_stats_by_period(days_back INTEGER DEFAULT 30)
RETURNS TABLE (
    period_date DATE,
    total_count INTEGER,
    pending_count INTEGER,
    approved_count INTEGER,
    rejected_count INTEGER,
    chatbot_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        DATE(a.submitted_at) as period_date,
        COUNT(*)::INTEGER as total_count,
        COUNT(*) FILTER (WHERE a.status = 'pending')::INTEGER as pending_count,
        COUNT(*) FILTER (WHERE a.status = 'approved')::INTEGER as approved_count,
        COUNT(*) FILTER (WHERE a.status = 'rejected')::INTEGER as rejected_count,
        COUNT(*) FILTER (WHERE a.source = 'chatbot')::INTEGER as chatbot_count
    FROM applications a
    WHERE a.submitted_at >= CURRENT_DATE - INTERVAL '1 day' * days_back
    GROUP BY DATE(a.submitted_at)
    ORDER BY period_date DESC;
END;
$$ LANGUAGE plpgsql;

-- ✅ ANALYTICS MATERIALIZED VIEWS (Performance Critical)

-- Admission funnel analytics (materialized for dashboard performance)
CREATE MATERIALIZED VIEW mv_admission_funnel AS
SELECT
    DATE_TRUNC('month', submitted_at) as month,
    COUNT(*) as total_applications,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_applications,
    COUNT(*) FILTER (WHERE status = 'reviewing') as reviewing_applications,
    COUNT(*) FILTER (WHERE status = 'approved') as approved_applications,
    COUNT(*) FILTER (WHERE status = 'rejected') as rejected_applications,
    ROUND(COUNT(*) FILTER (WHERE status = 'approved') * 100.0 / COUNT(*), 2) as approval_rate,
    COUNT(*) FILTER (WHERE source = 'chatbot') as chatbot_sourced,
    ROUND(COUNT(*) FILTER (WHERE source = 'chatbot') * 100.0 / COUNT(*), 2) as chatbot_conversion_rate,
    AVG(EXTRACT(EPOCH FROM (processed_at - submitted_at))/3600) FILTER (WHERE processed_at IS NOT NULL) as avg_processing_hours
FROM applications
WHERE submitted_at >= CURRENT_DATE - INTERVAL '24 months'
GROUP BY DATE_TRUNC('month', submitted_at)
ORDER BY month DESC;

-- Program popularity analytics (materialized for fast reporting)
CREATE MATERIALIZED VIEW mv_program_popularity AS
SELECT
    p.code,
    p.name,
    d.name as department,
    COUNT(a.id) as total_applications,
    COUNT(a.id) FILTER (WHERE a.status = 'approved') as approved_applications,
    ROUND(COUNT(a.id) FILTER (WHERE a.status = 'approved') * 100.0 / NULLIF(COUNT(a.id), 0), 2) as approval_rate,
    COUNT(DISTINCT a.campus_id) as campus_diversity,
    AVG(pt.semester_group_1_3_fee) as avg_starting_fee,
    COUNT(a.id) FILTER (WHERE a.submitted_at >= CURRENT_DATE - INTERVAL '30 days') as recent_applications,
    RANK() OVER (ORDER BY COUNT(a.id) DESC) as popularity_rank
FROM programs p
JOIN departments d ON p.department_id = d.id
LEFT JOIN applications a ON a.program_id = p.id
LEFT JOIN progressive_tuition pt ON pt.program_id = p.id AND pt.is_active = true
WHERE p.is_active = true
GROUP BY p.id, p.code, p.name, d.name
ORDER BY total_applications DESC;

-- Campus performance analytics (materialized for executive dashboards)
CREATE MATERIALIZED VIEW mv_campus_performance AS
SELECT
    c.code,
    c.name,
    c.city,
    c.discount_percentage,
    COUNT(a.id) as total_applications,
    COUNT(a.id) FILTER (WHERE a.status = 'approved') as approved_applications,
    COUNT(DISTINCT a.program_id) as program_diversity,
    COUNT(DISTINCT DATE_TRUNC('month', a.submitted_at)) as active_months,
    AVG(ff.discounted_fee) as avg_foundation_fee,
    COUNT(a.id) FILTER (WHERE a.source = 'chatbot') as chatbot_applications,
    ROUND(COUNT(a.id) FILTER (WHERE a.source = 'chatbot') * 100.0 / NULLIF(COUNT(a.id), 0), 2) as chatbot_rate,
    RANK() OVER (ORDER BY COUNT(a.id) DESC) as application_rank
FROM campuses c
LEFT JOIN applications a ON a.campus_id = c.id
LEFT JOIN foundation_fees ff ON ff.campus_id = c.id AND ff.is_active = true
WHERE c.is_active = true
GROUP BY c.id, c.code, c.name, c.city, c.discount_percentage
ORDER BY total_applications DESC;

-- Scholarship effectiveness analytics
CREATE MATERIALIZED VIEW mv_scholarship_analytics AS
SELECT
    s.code,
    s.name,
    s.type,
    s.percentage,
    s.recipients as target_recipients,
    COUNT(a.id) as applications_with_scholarship,
    COUNT(a.id) FILTER (WHERE a.status = 'approved') as approved_with_scholarship,
    ROUND(COUNT(a.id) FILTER (WHERE a.status = 'approved') * 100.0 / NULLIF(COUNT(a.id), 0), 2) as scholarship_approval_rate,
    AVG(EXTRACT(EPOCH FROM (a.processed_at - a.submitted_at))/24) FILTER (WHERE a.processed_at IS NOT NULL) as avg_processing_days,
    COUNT(DISTINCT a.program_id) as program_diversity
FROM scholarships s
LEFT JOIN applications a ON a.scholarship_id = s.id
WHERE s.is_active = true
GROUP BY s.id, s.code, s.name, s.type, s.percentage, s.recipients
ORDER BY applications_with_scholarship DESC;

-- Create indexes for materialized views
CREATE INDEX idx_mv_admission_funnel_month ON mv_admission_funnel(month);
CREATE INDEX idx_mv_program_popularity_rank ON mv_program_popularity(popularity_rank);
CREATE INDEX idx_mv_campus_performance_rank ON mv_campus_performance(application_rank);
CREATE INDEX idx_mv_scholarship_analytics_code ON mv_scholarship_analytics(code);

-- ✅ CHATBOT SYSTEM VIEWS AND PROCEDURES

-- Chatbot conversation statistics view
CREATE OR REPLACE VIEW v_chatbot_stats AS
SELECT
    COUNT(*) as total_conversations,
    COUNT(*) FILTER (WHERE ended_at IS NOT NULL) as completed_conversations,
    COUNT(*) FILTER (WHERE created_application_id IS NOT NULL) as conversations_with_applications,
    AVG(total_messages) FILTER (WHERE total_messages > 0) as avg_messages_per_conversation,
    AVG(EXTRACT(EPOCH FROM (ended_at - started_at))/60) FILTER (WHERE ended_at IS NOT NULL) as avg_duration_minutes,
    AVG(satisfaction_rating) FILTER (WHERE satisfaction_rating IS NOT NULL) as avg_satisfaction_rating,
    COUNT(*) FILTER (WHERE started_at >= CURRENT_DATE) as today_conversations,
    COUNT(*) FILTER (WHERE started_at >= CURRENT_DATE - INTERVAL '7 days') as week_conversations
FROM chatbot_conversations;

-- Popular intents view (enhanced with time-based analysis)
CREATE OR REPLACE VIEW v_popular_intents AS
SELECT
    intent_name,
    COUNT(*) as intent_count,
    AVG(confidence_score) as avg_confidence,
    COUNT(*) FILTER (WHERE resolved = true) as resolved_count,
    ROUND(COUNT(*) FILTER (WHERE resolved = true) * 100.0 / COUNT(*), 2) as resolution_rate,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as week_count,
    -- Extract common entities for intelligence
    jsonb_agg(DISTINCT entities->'program') FILTER (WHERE entities ? 'program') as common_programs,
    jsonb_agg(DISTINCT entities->'campus') FILTER (WHERE entities ? 'campus') as common_campuses
FROM user_intents
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY intent_name
ORDER BY intent_count DESC;

-- Chatbot conversation flow analysis
CREATE OR REPLACE VIEW v_conversation_flow AS
SELECT
    cc.id,
    cc.session_id,
    cc.total_messages,
    cc.satisfaction_rating,
    CASE
        WHEN cc.created_application_id IS NOT NULL THEN 'converted'
        WHEN cc.ended_at IS NOT NULL THEN 'completed'
        ELSE 'ongoing'
    END as conversation_outcome,
    -- Message flow analysis
    COUNT(cm.id) as actual_message_count,
    COUNT(cm.id) FILTER (WHERE cm.message_type = 'user') as user_messages,
    COUNT(cm.id) FILTER (WHERE cm.message_type = 'assistant') as bot_messages,
    -- Intent analysis
    COUNT(DISTINCT ui.intent_name) as unique_intents,
    string_agg(DISTINCT ui.intent_name, ', ' ORDER BY ui.intent_name) as intent_sequence,
    AVG(ui.confidence_score) as avg_intent_confidence,
    -- Timing analysis
    EXTRACT(EPOCH FROM (cc.ended_at - cc.started_at))/60 as duration_minutes,
    cc.started_at,
    cc.ended_at
FROM chatbot_conversations cc
LEFT JOIN chat_messages cm ON cc.id = cm.conversation_id
LEFT JOIN user_intents ui ON cc.id = ui.conversation_id
GROUP BY cc.id, cc.session_id, cc.total_messages, cc.satisfaction_rating,
         cc.created_application_id, cc.ended_at, cc.started_at
ORDER BY cc.started_at DESC;

-- Conversation details view with application info
CREATE OR REPLACE VIEW v_conversation_details AS
SELECT
    cc.id,
    cc.session_id,
    cc.started_at,
    cc.ended_at,
    cc.total_messages,
    cc.satisfaction_rating,
    cc.conversation_summary,
    a.application_code,
    a.student_name,
    a.email,
    p.code as program_code,
    p.name as program_name,
    c.code as campus_code,
    c.name as campus_name
FROM chatbot_conversations cc
LEFT JOIN applications a ON cc.created_application_id = a.id
LEFT JOIN programs p ON a.program_id = p.id
LEFT JOIN campuses c ON a.campus_id = c.id;

-- Generate unique session ID for chatbot
CREATE OR REPLACE FUNCTION generate_session_id()
RETURNS VARCHAR(100) AS $$
DECLARE
    new_session_id VARCHAR(100);
    timestamp_part VARCHAR(20);
    random_part VARCHAR(10);
BEGIN
    -- Generate timestamp part (YYYYMMDDHHMMSS)
    timestamp_part := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS');

    -- Generate random part (10 characters)
    random_part := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 10));

    -- Combine with prefix
    new_session_id := 'CHAT_' || timestamp_part || '_' || random_part;

    RETURN new_session_id;
END;
$$ LANGUAGE plpgsql;

-- Start new chatbot conversation
CREATE OR REPLACE FUNCTION start_conversation(
    p_user_ip VARCHAR(45) DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    conversation_id UUID;
    session_id VARCHAR(100);
BEGIN
    -- Generate unique session ID
    session_id := generate_session_id();

    -- Insert new conversation
    INSERT INTO chatbot_conversations (session_id, user_ip, user_agent)
    VALUES (session_id, p_user_ip, p_user_agent)
    RETURNING id INTO conversation_id;

    RETURN conversation_id;
END;
$$ LANGUAGE plpgsql;

-- End chatbot conversation with summary
CREATE OR REPLACE FUNCTION end_conversation(
    p_conversation_id UUID,
    p_satisfaction_rating INTEGER DEFAULT NULL,
    p_summary TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE chatbot_conversations
    SET
        ended_at = CURRENT_TIMESTAMP,
        satisfaction_rating = p_satisfaction_rating,
        conversation_summary = p_summary,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_conversation_id AND ended_at IS NULL;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Add message to conversation
CREATE OR REPLACE FUNCTION add_chat_message(
    p_conversation_id UUID,
    p_message_type VARCHAR(20),
    p_content TEXT,
    p_metadata JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    message_id UUID;
BEGIN
    -- Insert message
    INSERT INTO chat_messages (conversation_id, message_type, content, metadata)
    VALUES (p_conversation_id, p_message_type, p_content, p_metadata)
    RETURNING id INTO message_id;

    -- Update conversation message count
    UPDATE chatbot_conversations
    SET
        total_messages = total_messages + 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_conversation_id;

    RETURN message_id;
END;
$$ LANGUAGE plpgsql;

-- Record user intent
CREATE OR REPLACE FUNCTION record_user_intent(
    p_conversation_id UUID,
    p_message_id UUID,
    p_intent_name VARCHAR(100),
    p_confidence_score DECIMAL(3,2) DEFAULT NULL,
    p_entities JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    intent_id UUID;
BEGIN
    INSERT INTO user_intents (conversation_id, message_id, intent_name, confidence_score, entities)
    VALUES (p_conversation_id, p_message_id, p_intent_name, p_confidence_score, p_entities)
    RETURNING id INTO intent_id;

    RETURN intent_id;
END;
$$ LANGUAGE plpgsql;

-- Get conversation history
CREATE OR REPLACE FUNCTION get_conversation_history(
    p_conversation_id UUID,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    message_id UUID,
    message_type VARCHAR(20),
    content TEXT,
    metadata JSONB,
    timestamp TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cm.id,
        cm.message_type,
        cm.content,
        cm.metadata,
        cm.timestamp
    FROM chat_messages cm
    WHERE cm.conversation_id = p_conversation_id
    ORDER BY cm.timestamp ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ✅ MATERIALIZED VIEW MAINTENANCE SYSTEM

-- Smart refresh strategy based on data changes
CREATE OR REPLACE FUNCTION smart_refresh_materialized_views()
RETURNS void AS $$
DECLARE
    last_refresh TIMESTAMP;
    applications_changed BOOLEAN := false;
    programs_changed BOOLEAN := false;
BEGIN
    -- Check when views were last refreshed
    SELECT metric_value::timestamp INTO last_refresh
    FROM chatbot_analytics
    WHERE metric_type = 'last_mv_refresh'
    ORDER BY metric_date DESC
    LIMIT 1;

    -- Default to 1 hour ago if no record
    last_refresh := COALESCE(last_refresh, CURRENT_TIMESTAMP - INTERVAL '1 hour');

    -- Check if applications table has changes
    SELECT EXISTS(
        SELECT 1 FROM applications
        WHERE updated_at > last_refresh OR created_at > last_refresh
    ) INTO applications_changed;

    -- Check if programs/campuses have changes
    SELECT EXISTS(
        SELECT 1 FROM programs WHERE updated_at > last_refresh
        UNION ALL
        SELECT 1 FROM campuses WHERE updated_at > last_refresh
        UNION ALL
        SELECT 1 FROM progressive_tuition WHERE updated_at > last_refresh
    ) INTO programs_changed;

    -- Refresh only if needed
    IF applications_changed THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_admission_funnel;
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_program_popularity;
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_campus_performance;
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_scholarship_analytics;
    END IF;

    IF programs_changed THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY mv_program_search;
    END IF;

    -- Log refresh activity
    INSERT INTO chatbot_analytics (metric_date, metric_type, metric_value, metadata)
    VALUES (CURRENT_DATE, 'last_mv_refresh', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP),
            jsonb_build_object(
                'applications_changed', applications_changed,
                'programs_changed', programs_changed,
                'refreshed_at', CURRENT_TIMESTAMP
            ));
END;
$$ LANGUAGE plpgsql;

-- Scheduled refresh function (call this from cron or app scheduler)
CREATE OR REPLACE FUNCTION scheduled_refresh_materialized_views()
RETURNS void AS $$
BEGIN
    -- Always refresh analytics views daily at minimum
    IF EXTRACT(HOUR FROM CURRENT_TIME) = 6 THEN -- 6 AM refresh
        PERFORM refresh_materialized_views();
    ELSE
        PERFORM smart_refresh_materialized_views();
    END IF;
END;
$$ LANGUAGE plpgsql;
