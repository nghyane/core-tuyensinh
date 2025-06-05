-- =====================================================
-- CAMPUS VIEWS
-- Purpose: Views for campus-related queries
-- =====================================================

-- Campus with program availability
CREATE OR REPLACE VIEW v_campuses_with_programs AS
SELECT
    c.id,
    c.code,
    c.name,
    c.city,
    c.discount_percentage,
    c.is_active,
    COUNT(pca.program_id) as available_programs_count,
    array_agg(DISTINCT p.code ORDER BY p.code) FILTER (WHERE pca.is_available = true) as available_program_codes
FROM campuses c
LEFT JOIN program_campus_availability pca ON c.id = pca.campus_id AND pca.is_available = true
LEFT JOIN programs p ON pca.program_id = p.id AND p.is_active = true
WHERE c.is_active = true
GROUP BY c.id, c.code, c.name, c.city, c.discount_percentage, c.is_active
ORDER BY c.name;

-- Campus summary view
CREATE OR REPLACE VIEW v_campuses_summary AS
SELECT
    COUNT(*) as total_campuses,
    AVG(discount_percentage) as avg_discount,
    COUNT(*) FILTER (WHERE discount_percentage > 0) as campuses_with_discount,
    (SELECT COUNT(DISTINCT program_id) FROM program_campus_availability WHERE is_available = true) as total_available_programs
FROM campuses
WHERE is_active = true;

-- TODO: Add more campus views as needed
-- - Campus with tuition fees
-- - Campus with foundation fees
-- - Campus application statistics
