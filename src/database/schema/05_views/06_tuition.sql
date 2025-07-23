-- =====================================================
-- TUITION VIEWS
-- Purpose: Views for tuition fee queries and calculations
-- =====================================================

-- Comprehensive tuition view with program and campus details
CREATE OR REPLACE VIEW v_tuition_summary AS
SELECT 
    pt.id,
    pt.year,
    
    -- Program information
    p.id as program_id,
    p.code as program_code,
    p.name as program_name,
    p.name_en as program_name_en,
    
    -- Department information
    d.id as department_id,
    d.code as department_code,
    d.name as department_name,
    d.name_en as department_name_en,
    
    -- Campus information
    c.id as campus_id,
    c.code as campus_code,
    c.name as campus_name,
    c.city as campus_city,
    c.discount_percentage as campus_discount,
    
    -- Progressive tuition fees
    pt.semester_group_1_3_fee,
    pt.semester_group_4_6_fee,
    pt.semester_group_7_9_fee,
    
    -- Calculated totals
    (pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3) as total_program_fee,
    
    -- Fee ranges for quick reference
    pt.semester_group_1_3_fee as min_semester_fee,
    pt.semester_group_7_9_fee as max_semester_fee,
    
    -- Status and timestamps
    pt.is_active,
    pt.created_at,
    pt.updated_at
    
FROM progressive_tuition pt
INNER JOIN programs p ON pt.program_id = p.id
INNER JOIN departments d ON p.department_id = d.id
INNER JOIN campuses c ON pt.campus_id = c.id
WHERE pt.is_active = true
  AND p.is_active = true
  AND c.is_active = true
ORDER BY d.name, p.name, c.name;

-- Tuition comparison view for easy fee comparison across campuses
CREATE OR REPLACE VIEW v_tuition_comparison AS
SELECT 
    p.code as program_code,
    p.name as program_name,
    d.name as department_name,
    pt.year,
    
    -- Campus fees grouped
    json_agg(
        json_build_object(
            'campus_code', c.code,
            'campus_name', c.name,
            'city', c.city,
            'discount_percentage', c.discount_percentage,
            'semester_1_3_fee', pt.semester_group_1_3_fee,
            'semester_4_6_fee', pt.semester_group_4_6_fee,
            'semester_7_9_fee', pt.semester_group_7_9_fee,
            'total_program_fee', (pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3)
        ) ORDER BY c.name
    ) as campus_fees,
    
    -- Min/Max fees across all campuses for this program
    min(pt.semester_group_1_3_fee) as min_semester_fee,
    max(pt.semester_group_7_9_fee) as max_semester_fee,
    min(pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3) as min_total_fee,
    max(pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3) as max_total_fee
    
FROM progressive_tuition pt
JOIN programs p ON pt.program_id = p.id
JOIN departments d ON p.department_id = d.id
JOIN campuses c ON pt.campus_id = c.id
WHERE pt.is_active = true
  AND p.is_active = true
  AND c.is_active = true
GROUP BY p.id, p.code, p.name, d.name, pt.year
ORDER BY d.name, p.name;

-- Campus tuition summary for campus-specific queries
CREATE OR REPLACE VIEW v_campus_tuition_summary AS
SELECT 
    c.id as campus_id,
    c.code as campus_code,
    c.name as campus_name,
    c.city as campus_city,
    c.discount_percentage,
    pt.year,
    
    -- Program count and fee statistics
    count(pt.id) as total_programs,
    count(DISTINCT d.id) as total_departments,
    
    -- Fee statistics
    min(pt.semester_group_1_3_fee) as min_semester_fee,
    max(pt.semester_group_7_9_fee) as max_semester_fee,
    avg(pt.semester_group_1_3_fee) as avg_semester_1_3_fee,
    avg(pt.semester_group_4_6_fee) as avg_semester_4_6_fee,
    avg(pt.semester_group_7_9_fee) as avg_semester_7_9_fee,
    
    -- Available programs
    json_agg(
        json_build_object(
            'program_code', p.code,
            'program_name', p.name,
            'department_name', d.name,
            'semester_1_3_fee', pt.semester_group_1_3_fee,
            'semester_4_6_fee', pt.semester_group_4_6_fee,
            'semester_7_9_fee', pt.semester_group_7_9_fee
        ) ORDER BY d.name, p.name
    ) as programs
    
FROM campuses c
JOIN progressive_tuition pt ON c.id = pt.campus_id
JOIN programs p ON pt.program_id = p.id
JOIN departments d ON p.department_id = d.id
WHERE pt.is_active = true
  AND p.is_active = true
  AND c.is_active = true
GROUP BY c.id, c.code, c.name, c.city, c.discount_percentage, pt.year
ORDER BY c.name;

-- =====================================================
-- TUITION FUNCTIONS (for complex queries only)
-- =====================================================

-- Function to get tuition with custom filters and calculations
CREATE OR REPLACE FUNCTION get_tuition_with_filters(
    p_program_codes text[] DEFAULT NULL,
    p_campus_codes text[] DEFAULT NULL,
    p_year integer DEFAULT 2025,
    p_include_inactive boolean DEFAULT false
)
RETURNS TABLE (
    program_code text,
    program_name text,
    campus_code text,
    campus_name text,
    semester_1_3_fee numeric,
    semester_4_6_fee numeric,
    semester_7_9_fee numeric,
    total_program_fee numeric,
    effective_discount numeric
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.code::text,
        p.name::text,
        c.code::text,
        c.name::text,
        pt.semester_group_1_3_fee,
        pt.semester_group_4_6_fee,
        pt.semester_group_7_9_fee,
        (pt.semester_group_1_3_fee * 3 + pt.semester_group_4_6_fee * 3 + pt.semester_group_7_9_fee * 3),
        c.discount_percentage
    FROM progressive_tuition pt
    JOIN programs p ON pt.program_id = p.id
    JOIN campuses c ON pt.campus_id = c.id
    WHERE pt.year = p_year
      AND (p_include_inactive OR (pt.is_active AND p.is_active AND c.is_active))
      AND (p_program_codes IS NULL OR p.code = ANY(p_program_codes))
      AND (p_campus_codes IS NULL OR c.code = ANY(p_campus_codes))
    ORDER BY p.name, c.name;
END;
$$;

-- Function to calculate total cost including preparation fees
CREATE OR REPLACE FUNCTION calculate_total_program_cost(
    p_program_code text,
    p_campus_code text,
    p_year integer DEFAULT 2025,
    p_has_ielts boolean DEFAULT false
)
RETURNS TABLE (
    program_fee numeric,
    preparation_fees numeric,
    total_cost numeric,
    cost_breakdown jsonb
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_program_id uuid;
    v_campus_id uuid;
    v_tuition_total numeric;
    v_orientation_fee numeric := 0;
    v_english_prep_fee numeric := 0;
    v_english_periods integer := 0;
BEGIN
    -- Get IDs
    SELECT p.id INTO v_program_id FROM programs p WHERE p.code = p_program_code;
    SELECT c.id INTO v_campus_id FROM campuses c WHERE c.code = p_campus_code;

    IF v_program_id IS NULL OR v_campus_id IS NULL THEN
        RAISE EXCEPTION 'Program or campus not found';
    END IF;

    -- Get tuition total
    SELECT (semester_group_1_3_fee * 3 + semester_group_4_6_fee * 3 + semester_group_7_9_fee * 3)
    INTO v_tuition_total
    FROM progressive_tuition
    WHERE program_id = v_program_id AND campus_id = v_campus_id AND year = p_year;

    -- Get preparation fees
    SELECT fee INTO v_orientation_fee
    FROM preparation_fees
    WHERE campus_id = v_campus_id AND year = p_year AND fee_type = 'orientation';

    -- English prep fee (if no IELTS 6.0+)
    IF NOT p_has_ielts THEN
        SELECT fee INTO v_english_prep_fee
        FROM preparation_fees
        WHERE campus_id = v_campus_id AND year = p_year AND fee_type = 'english_prep';

        v_english_periods := 6; -- Maximum periods
        v_english_prep_fee := COALESCE(v_english_prep_fee, 0) * v_english_periods;
    END IF;

    RETURN QUERY
    SELECT
        COALESCE(v_tuition_total, 0),
        COALESCE(v_orientation_fee, 0) + COALESCE(v_english_prep_fee, 0),
        COALESCE(v_tuition_total, 0) + COALESCE(v_orientation_fee, 0) + COALESCE(v_english_prep_fee, 0),
        jsonb_build_object(
            'tuition_total', COALESCE(v_tuition_total, 0),
            'orientation_fee', COALESCE(v_orientation_fee, 0),
            'english_prep_fee', COALESCE(v_english_prep_fee, 0),
            'english_periods', v_english_periods,
            'has_ielts_exemption', p_has_ielts
        );
END;
$$;

-- =====================================================
-- TUITION VALIDATION FUNCTIONS (for CRUD operations)
-- =====================================================

-- Get tuition by ID with full details
CREATE OR REPLACE FUNCTION get_tuition_by_id_with_details(tuition_id UUID)
RETURNS TABLE (
    id UUID,
    year INTEGER,
    program_id UUID,
    program_code TEXT,
    program_name TEXT,
    program_name_en TEXT,
    department_id UUID,
    department_code TEXT,
    department_name TEXT,
    department_name_en TEXT,
    campus_id UUID,
    campus_code TEXT,
    campus_name TEXT,
    campus_city TEXT,
    campus_discount NUMERIC,
    semester_group_1_3_fee NUMERIC,
    semester_group_4_6_fee NUMERIC,
    semester_group_7_9_fee NUMERIC,
    total_program_fee NUMERIC,
    min_semester_fee NUMERIC,
    max_semester_fee NUMERIC,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vs.id,
        vs.year,
        vs.program_id,
        vs.program_code::TEXT,
        vs.program_name::TEXT,
        vs.program_name_en::TEXT,
        vs.department_id,
        vs.department_code::TEXT,
        vs.department_name::TEXT,
        vs.department_name_en::TEXT,
        vs.campus_id,
        vs.campus_code::TEXT,
        vs.campus_name::TEXT,
        vs.campus_city::TEXT,
        vs.campus_discount,
        vs.semester_group_1_3_fee,
        vs.semester_group_4_6_fee,
        vs.semester_group_7_9_fee,
        vs.total_program_fee,
        vs.min_semester_fee,
        vs.max_semester_fee,
        vs.is_active,
        vs.created_at,
        vs.updated_at
    FROM v_tuition_summary vs
    WHERE vs.id = tuition_id;
END;
$$;

-- Create tuition with validation
CREATE OR REPLACE FUNCTION create_tuition_with_validation(
    program_id_param UUID,
    campus_id_param UUID,
    year_param INTEGER,
    semester_group_1_3_fee_param NUMERIC,
    semester_group_4_6_fee_param NUMERIC,
    semester_group_7_9_fee_param NUMERIC
)
RETURNS TABLE (
    id UUID,
    year INTEGER,
    program_id UUID,
    program_code TEXT,
    program_name TEXT,
    program_name_en TEXT,
    department_id UUID,
    department_code TEXT,
    department_name TEXT,
    department_name_en TEXT,
    campus_id UUID,
    campus_code TEXT,
    campus_name TEXT,
    campus_city TEXT,
    campus_discount NUMERIC,
    semester_group_1_3_fee NUMERIC,
    semester_group_4_6_fee NUMERIC,
    semester_group_7_9_fee NUMERIC,
    total_program_fee NUMERIC,
    min_semester_fee NUMERIC,
    max_semester_fee NUMERIC,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_tuition_id UUID;
BEGIN
    -- Validate program exists and is active
    IF NOT EXISTS (SELECT 1 FROM programs WHERE programs.id = program_id_param AND programs.is_active = true) THEN
        RAISE EXCEPTION 'Program not found or inactive' USING ERRCODE = 'P0003';
    END IF;

    -- Validate campus exists and is active
    IF NOT EXISTS (SELECT 1 FROM campuses WHERE campuses.id = campus_id_param AND campuses.is_active = true) THEN
        RAISE EXCEPTION 'Campus not found or inactive' USING ERRCODE = 'P0003';
    END IF;

    -- Check if tuition already exists for this program, campus, and year
    IF EXISTS (
        SELECT 1 FROM progressive_tuition pt
        WHERE pt.program_id = program_id_param
          AND pt.campus_id = campus_id_param
          AND pt.year = year_param
          AND pt.is_active = true
    ) THEN
        RAISE EXCEPTION 'Tuition already exists for this program and campus in year %', year_param USING ERRCODE = 'P0004';
    END IF;

    -- Validate fee amounts are positive
    IF semester_group_1_3_fee_param <= 0 OR semester_group_4_6_fee_param <= 0 OR semester_group_7_9_fee_param <= 0 THEN
        RAISE EXCEPTION 'All semester fees must be positive' USING ERRCODE = 'P0005';
    END IF;

    -- Validate year range
    IF year_param < 2020 OR year_param > 2030 THEN
        RAISE EXCEPTION 'Year must be between 2020 and 2030' USING ERRCODE = 'P0005';
    END IF;

    -- Insert new tuition record
    INSERT INTO progressive_tuition (
        program_id,
        campus_id,
        year,
        semester_group_1_3_fee,
        semester_group_4_6_fee,
        semester_group_7_9_fee
    ) VALUES (
        program_id_param,
        campus_id_param,
        year_param,
        semester_group_1_3_fee_param,
        semester_group_4_6_fee_param,
        semester_group_7_9_fee_param
    ) RETURNING progressive_tuition.id INTO new_tuition_id;

    -- Return the created tuition with full details
    RETURN QUERY
    SELECT * FROM get_tuition_by_id_with_details(new_tuition_id);
END;
$$;

-- Update tuition with validation
CREATE OR REPLACE FUNCTION update_tuition_with_validation(
    p_id UUID,
    p_program_id UUID DEFAULT NULL,
    p_campus_id UUID DEFAULT NULL,
    p_year INTEGER DEFAULT NULL,
    p_semester_group_1_3_fee NUMERIC DEFAULT NULL,
    p_semester_group_4_6_fee NUMERIC DEFAULT NULL,
    p_semester_group_7_9_fee NUMERIC DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    year INTEGER,
    program_id UUID,
    program_code TEXT,
    program_name TEXT,
    program_name_en TEXT,
    department_id UUID,
    department_code TEXT,
    department_name TEXT,
    department_name_en TEXT,
    campus_id UUID,
    campus_code TEXT,
    campus_name TEXT,
    campus_city TEXT,
    campus_discount NUMERIC,
    semester_group_1_3_fee NUMERIC,
    semester_group_4_6_fee NUMERIC,
    semester_group_7_9_fee NUMERIC,
    total_program_fee NUMERIC,
    min_semester_fee NUMERIC,
    max_semester_fee NUMERIC,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if tuition exists
    IF NOT EXISTS (SELECT 1 FROM progressive_tuition WHERE progressive_tuition.id = p_id) THEN
        RAISE EXCEPTION 'Tuition record not found' USING ERRCODE = 'P0003';
    END IF;

    -- Validate program if provided
    IF p_program_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM programs WHERE programs.id = p_program_id AND programs.is_active = true) THEN
        RAISE EXCEPTION 'Program not found or inactive' USING ERRCODE = 'P0003';
    END IF;

    -- Validate campus if provided
    IF p_campus_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM campuses WHERE campuses.id = p_campus_id AND campuses.is_active = true) THEN
        RAISE EXCEPTION 'Campus not found or inactive' USING ERRCODE = 'P0003';
    END IF;

    -- Validate fee amounts if provided
    IF (p_semester_group_1_3_fee IS NOT NULL AND p_semester_group_1_3_fee <= 0) OR
       (p_semester_group_4_6_fee IS NOT NULL AND p_semester_group_4_6_fee <= 0) OR
       (p_semester_group_7_9_fee IS NOT NULL AND p_semester_group_7_9_fee <= 0) THEN
        RAISE EXCEPTION 'All semester fees must be positive' USING ERRCODE = 'P0005';
    END IF;

    -- Validate year if provided
    IF p_year IS NOT NULL AND (p_year < 2020 OR p_year > 2030) THEN
        RAISE EXCEPTION 'Year must be between 2020 and 2030' USING ERRCODE = 'P0005';
    END IF;

    -- Check for duplicate if program, campus, or year is being changed
    IF (p_program_id IS NOT NULL OR p_campus_id IS NOT NULL OR p_year IS NOT NULL) THEN
        IF EXISTS (
            SELECT 1 FROM progressive_tuition pt
            WHERE pt.id != p_id
              AND pt.program_id = COALESCE(p_program_id, (SELECT program_id FROM progressive_tuition WHERE progressive_tuition.id = p_id))
              AND pt.campus_id = COALESCE(p_campus_id, (SELECT campus_id FROM progressive_tuition WHERE progressive_tuition.id = p_id))
              AND pt.year = COALESCE(p_year, (SELECT progressive_tuition.year FROM progressive_tuition WHERE progressive_tuition.id = p_id))
              AND pt.is_active = true
        ) THEN
            RAISE EXCEPTION 'Tuition already exists for this program and campus in the specified year' USING ERRCODE = 'P0004';
        END IF;
    END IF;

    -- Update the tuition record
    UPDATE progressive_tuition SET
        program_id = COALESCE(p_program_id, program_id),
        campus_id = COALESCE(p_campus_id, campus_id),
        year = COALESCE(p_year, year),
        semester_group_1_3_fee = COALESCE(p_semester_group_1_3_fee, semester_group_1_3_fee),
        semester_group_4_6_fee = COALESCE(p_semester_group_4_6_fee, semester_group_4_6_fee),
        semester_group_7_9_fee = COALESCE(p_semester_group_7_9_fee, semester_group_7_9_fee),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = CURRENT_TIMESTAMP
    WHERE progressive_tuition.id = p_id;

    -- Return the updated tuition with full details
    RETURN QUERY
    SELECT * FROM get_tuition_by_id_with_details(p_id);
END;
$$;

-- Delete tuition with validation
CREATE OR REPLACE FUNCTION delete_tuition_with_validation(p_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if tuition exists
    IF NOT EXISTS (SELECT 1 FROM progressive_tuition WHERE id = p_id AND progressive_tuition.is_active = true) THEN
        RAISE EXCEPTION 'Tuition record not found' USING ERRCODE = 'P0003';
    END IF;

    -- Check if tuition is referenced by any applications (if applications table exists)
    -- This is a soft constraint - we'll just warn but allow deletion
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'applications') THEN
        IF EXISTS (
            SELECT 1 FROM applications a
            JOIN programs p ON a.program_id = p.id
            JOIN progressive_tuition pt ON pt.program_id = p.id AND pt.campus_id = a.campus_id
            WHERE pt.id = p_id AND a.status != 'cancelled'
        ) THEN
            RAISE WARNING 'Tuition record is referenced by active applications';
        END IF;
    END IF;

    -- Soft delete the tuition record
    UPDATE progressive_tuition
    SET is_active = false, updated_at = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql;
