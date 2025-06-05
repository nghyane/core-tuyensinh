-- =====================================================
-- DEPARTMENT VIEWS
-- Purpose: Views for department-related queries
-- =====================================================

-- Departments with program statistics
CREATE OR REPLACE VIEW v_departments_with_stats AS
SELECT
    d.id,
    d.code,
    d.name,
    d.name_en,
    d.is_active,
    d.created_at,
    d.updated_at,
    COUNT(p.id) as program_count,
    AVG(p.duration_years) as avg_program_duration,
    COUNT(p.id) FILTER (WHERE p.duration_years = 4) as four_year_programs,
    COUNT(p.id) FILTER (WHERE p.duration_years = 3) as three_year_programs
FROM departments d
LEFT JOIN programs p ON d.id = p.department_id AND p.is_active = true
WHERE d.is_active = true
GROUP BY d.id, d.code, d.name, d.name_en, d.is_active, d.created_at, d.updated_at
ORDER BY d.name;

-- Departments summary view
CREATE OR REPLACE VIEW v_departments_summary AS
SELECT
    COUNT(*) as total_departments,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as new_departments_month,
    (SELECT COUNT(*) FROM programs WHERE is_active = true) as total_programs,
    AVG((SELECT COUNT(*) FROM programs p WHERE p.department_id = d.id AND p.is_active = true)) as avg_programs_per_dept
FROM departments d
WHERE d.is_active = true;

-- Active departments with recent activity
CREATE OR REPLACE VIEW v_active_departments AS
SELECT
    d.id,
    d.code,
    d.name,
    d.name_en,
    d.created_at,
    COUNT(p.id) as program_count,
    MAX(p.created_at) as latest_program_created,
    MAX(p.updated_at) as latest_program_updated
FROM departments d
LEFT JOIN programs p ON d.id = p.department_id AND p.is_active = true
WHERE d.is_active = true
GROUP BY d.id, d.code, d.name, d.name_en, d.created_at
HAVING COUNT(p.id) > 0 OR d.created_at >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY COALESCE(MAX(p.updated_at), d.updated_at) DESC;

-- Department functions
CREATE OR REPLACE FUNCTION get_departments_with_stats(
    limit_results INTEGER DEFAULT 100,
    offset_results INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    code VARCHAR(10),
    name VARCHAR(100),
    name_en VARCHAR(100),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    program_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id, d.code, d.name, d.name_en, d.is_active, d.created_at, d.updated_at,
        COUNT(p.id) as program_count
    FROM departments d
    LEFT JOIN programs p ON d.id = p.department_id AND p.is_active = true
    WHERE d.is_active = true
    GROUP BY d.id, d.code, d.name, d.name_en, d.is_active, d.created_at, d.updated_at
    ORDER BY d.name
    LIMIT limit_results
    OFFSET offset_results;
END;
$$ LANGUAGE plpgsql;

-- Get departments with pagination (optimized for API)
CREATE OR REPLACE FUNCTION get_departments_with_pagination(
    limit_results INTEGER DEFAULT 100,
    offset_results INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    code VARCHAR(10),
    name VARCHAR(100),
    name_en VARCHAR(100),
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id, d.code, d.name, d.name_en, d.description
    FROM departments d
    WHERE d.is_active = true
    ORDER BY d.name
    LIMIT limit_results
    OFFSET offset_results;
END;
$$ LANGUAGE plpgsql;

-- Get total count of active departments
CREATE OR REPLACE FUNCTION get_departments_count()
RETURNS BIGINT AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM departments
        WHERE is_active = true
    );
END;
$$ LANGUAGE plpgsql;

-- Get department by ID
CREATE OR REPLACE FUNCTION get_department_by_id(department_id UUID)
RETURNS TABLE (
    id UUID,
    code VARCHAR(10),
    name VARCHAR(100),
    name_en VARCHAR(100),
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id, d.code, d.name, d.name_en, d.description
    FROM departments d
    WHERE d.id = department_id AND d.is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Create department with validation
CREATE OR REPLACE FUNCTION create_department_with_validation(
    d_code VARCHAR(10),
    d_name VARCHAR(100),
    d_name_en VARCHAR(100) DEFAULT NULL,
    d_description TEXT DEFAULT NULL
) RETURNS TABLE (
    id UUID,
    code VARCHAR(10),
    name VARCHAR(100),
    name_en VARCHAR(100),
    description TEXT
) AS $$
DECLARE
    new_department_id UUID;
BEGIN
    -- Check if department code already exists
    IF EXISTS (SELECT 1 FROM departments WHERE departments.code = d_code) THEN
        RAISE EXCEPTION 'Department with code % already exists', d_code USING ERRCODE = 'D0001';
    END IF;

    -- Insert new department
    INSERT INTO departments (code, name, name_en, description)
    VALUES (d_code, d_name, d_name_en, d_description)
    RETURNING departments.id INTO new_department_id;

    -- Return created department
    RETURN QUERY
    SELECT * FROM get_department_by_id(new_department_id);
END;
$$ LANGUAGE plpgsql;

-- Update department with validation
CREATE OR REPLACE FUNCTION update_department_with_validation(
    d_id UUID,
    d_code VARCHAR(10) DEFAULT NULL,
    d_name VARCHAR(100) DEFAULT NULL,
    d_name_en VARCHAR(100) DEFAULT NULL,
    d_description TEXT DEFAULT NULL,
    d_is_active BOOLEAN DEFAULT NULL
) RETURNS TABLE (
    id UUID,
    code VARCHAR(10),
    name VARCHAR(100),
    name_en VARCHAR(100),
    description TEXT
) AS $$
BEGIN
    -- Check if department exists
    IF NOT EXISTS (SELECT 1 FROM departments WHERE departments.id = d_id AND is_active = true) THEN
        RAISE EXCEPTION 'Department not found' USING ERRCODE = 'D0002';
    END IF;

    -- Check if code is unique (if provided and different)
    IF d_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM departments
        WHERE departments.code = d_code AND departments.id != d_id
    ) THEN
        RAISE EXCEPTION 'Department with code % already exists', d_code USING ERRCODE = 'D0001';
    END IF;

    -- Update department
    UPDATE departments
    SET
        code = COALESCE(d_code, code),
        name = COALESCE(d_name, name),
        name_en = COALESCE(d_name_en, name_en),
        description = COALESCE(d_description, description),
        is_active = COALESCE(d_is_active, is_active),
        updated_at = CURRENT_TIMESTAMP
    WHERE departments.id = d_id;

    -- Return updated department
    RETURN QUERY
    SELECT * FROM get_department_by_id(d_id);
END;
$$ LANGUAGE plpgsql;

-- Delete department with validation
CREATE OR REPLACE FUNCTION delete_department_with_validation(d_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if department exists
    IF NOT EXISTS (SELECT 1 FROM departments WHERE id = d_id AND is_active = true) THEN
        RAISE EXCEPTION 'Department not found' USING ERRCODE = 'D0002';
    END IF;

    -- Check if department has active programs
    IF EXISTS (SELECT 1 FROM programs WHERE department_id = d_id AND is_active = true) THEN
        RAISE EXCEPTION 'Cannot delete department with active programs' USING ERRCODE = 'D0003';
    END IF;

    -- Soft delete department
    UPDATE departments
    SET is_active = false, updated_at = CURRENT_TIMESTAMP
    WHERE id = d_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
