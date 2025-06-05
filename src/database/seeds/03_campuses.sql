-- =====================================================
-- CAMPUSES AND FOUNDATION FEES SEED DATA
-- Purpose: FPT University campuses and fee structure
-- =====================================================

-- Campuses data (Real FPT campuses with correct discount policies)
INSERT INTO campuses (code, name, city, address, phone, email, discount_percentage) VALUES
('HN', 'FPT University Hà Nội', 'Hà Nội', 'Khu Giáo dục và Đào tạo - Khu Công nghệ cao Hòa Lạc - Km29 Đại lộ Thăng Long, H. Thạch Thất, TP. Hà Nội', '024 7300 5588', 'tuyensinhhanoi@fpt.edu.vn', 0),
('HCM', 'FPT University TP.HCM', 'TP. Hồ Chí Minh', 'Lô E2a-7, Đường D1 Khu Công nghệ cao, P. Long Thạnh Mỹ, TP. Thủ Đức, TP. Hồ Chí Minh', '028 7300 5588', 'tuyensinhhcm@fpt.edu.vn', 0),
('DN', 'FPT University Đà Nẵng', 'Đà Nẵng', 'Khu đô thị công nghệ FPT Đà Nẵng, P. Hoà Hải, Q. Ngũ Hành Sơn, TP. Đà Nẵng', '0236 730 0999', 'tuyensinhdanang@fpt.edu.vn', 30),
('CT', 'FPT University Cần Thơ', 'Cần Thơ', 'Số 600 Đường Nguyễn Văn Cừ (nối dài), P. An Bình, Q. Ninh Kiều, TP. Cần Thơ', '0292 730 3636', 'tuyensinhcantho@fpt.edu.vn', 30),
('QN', 'FPT University Quy Nhơn', 'Quy Nhơn', 'Khu đô thị mới An Phú Thịnh, Phường Nhơn Bình & Phường Đống Đa, TP. Quy Nhơn, Bình Định', '0256 7300 999', 'tuyensinhquynhon@fpt.edu.vn', 50);

-- Foundation fees data (Real 2025 foundation fees by campus)
INSERT INTO foundation_fees (campus_id, year, standard_fee, discounted_fee) VALUES
-- Hà Nội & HCM: No discount
((SELECT id FROM campuses WHERE code = 'HN'), 2025, 13100000, 13100000),
((SELECT id FROM campuses WHERE code = 'HCM'), 2025, 13100000, 13100000),
-- Đà Nẵng & Cần Thơ: 30% discount
((SELECT id FROM campuses WHERE code = 'DN'), 2025, 13100000, 9170000),
((SELECT id FROM campuses WHERE code = 'CT'), 2025, 13100000, 9170000),
-- Quy Nhơn: 50% discount
((SELECT id FROM campuses WHERE code = 'QN'), 2025, 13100000, 6550000);

-- Scholarships data (Real FPT 2025 scholarships)
INSERT INTO scholarships (code, name, type, recipients, percentage, requirements, year) VALUES
('EXPERT_GLOBAL', 'Học bổng Chuyên gia Toàn cầu', 'Toàn phần + Sinh hoạt phí', 100, 100, 'Giải Nhất/Nhì/Ba HSG cấp quốc gia ngành CNTT + Phỏng vấn', 2025),
('SCHOOL_PATH', 'Học bổng Học đường', 'Toàn phần', 900, 100, 'Top 10 SchoolRank tại trường THPT Khu vực 1', 2025),
('FULL_SCHOLARSHIP', 'Học bổng Toàn phần', 'Toàn phần', 300, 100, 'Olympic quốc tế hoặc HSG Nhất quốc gia hoặc ĐGNL >= 90%', 2025),
('TWO_YEAR', 'Học bổng 2 năm', 'Miễn 2 năm đầu', 500, 100, 'HSG Nhì quốc gia hoặc ĐGNL >= 85%', 2025),
('ONE_YEAR', 'Học bổng 1 năm', 'Miễn năm đầu', 1000, 100, 'HSG Ba quốc gia hoặc ĐGNL >= 80%', 2025);

-- Admission methods data (Real FPT 2025 methods)
INSERT INTO admission_methods (method_code, name, requirements, year) VALUES
('HB', 'Xét học bạ THPT', 'Top 50 SchoolRank + Điểm kỳ 2 lớp 12 >= 21', 2025),
('DGNL_HN', 'Đánh giá năng lực ĐHQG Hà Nội', 'Điểm >= 80 (đợt 1) hoặc Top 50', 2025),
('DGNL_HCM', 'Đánh giá năng lực ĐHQG TP.HCM', 'Điểm >= 609 (đợt 1) hoặc Top 50', 2025),
('THPT', 'Thi tốt nghiệp THPT', 'Top 50 với tổ hợp Toán + 2 môn bất kỳ', 2025),
('OTHER', 'Phương thức khác', 'BTEC HND, Melbourne Polytechnic, FUNiX, v.v.', 2025);

-- Program campus availability (sample data)
INSERT INTO program_campus_availability (program_id, campus_id, year, is_available) VALUES
-- All programs available at Hà Nội and HCM
((SELECT id FROM programs WHERE code = 'SE'), (SELECT id FROM campuses WHERE code = 'HN'), 2025, true),
((SELECT id FROM programs WHERE code = 'AI'), (SELECT id FROM campuses WHERE code = 'HN'), 2025, true),
((SELECT id FROM programs WHERE code = 'MKT'), (SELECT id FROM campuses WHERE code = 'HN'), 2025, true),
((SELECT id FROM programs WHERE code = 'IB'), (SELECT id FROM campuses WHERE code = 'HN'), 2025, true),
((SELECT id FROM programs WHERE code = 'SE'), (SELECT id FROM campuses WHERE code = 'HCM'), 2025, true),
((SELECT id FROM programs WHERE code = 'AI'), (SELECT id FROM campuses WHERE code = 'HCM'), 2025, true),
((SELECT id FROM programs WHERE code = 'MKT'), (SELECT id FROM campuses WHERE code = 'HCM'), 2025, true),
((SELECT id FROM programs WHERE code = 'IB'), (SELECT id FROM campuses WHERE code = 'HCM'), 2025, true),
-- Limited programs at regional campuses
((SELECT id FROM programs WHERE code = 'SE'), (SELECT id FROM campuses WHERE code = 'DN'), 2025, true),
((SELECT id FROM programs WHERE code = 'MKT'), (SELECT id FROM campuses WHERE code = 'DN'), 2025, true),
((SELECT id FROM programs WHERE code = 'SE'), (SELECT id FROM campuses WHERE code = 'CT'), 2025, true),
((SELECT id FROM programs WHERE code = 'MKT'), (SELECT id FROM campuses WHERE code = 'CT'), 2025, true),
((SELECT id FROM programs WHERE code = 'SE'), (SELECT id FROM campuses WHERE code = 'QN'), 2025, true);
