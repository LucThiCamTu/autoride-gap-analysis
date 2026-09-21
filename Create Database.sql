-- Create Database
CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

-- 1. Bảng Cars (Danh sách xe)
CREATE TABLE IF NOT EXISTS Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

-- 2. Bảng Rentals (Quản lý hợp đồng thuê xe - Đã nâng cấp)
CREATE TABLE IF NOT EXISTS Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME,
    
    -- Sử dụng ENUM để khóa chặt các trạng thái vòng đời
    status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'BOOKED',
    
    -- Các cột tài chính chuẩn DECIMAL tránh sai số
    security_deposit DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    late_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    damage_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    
    FOREIGN KEY (car_id) REFERENCES Cars(car_id) ON DELETE RESTRICT
);

-- 3. Bảng Inspections (Biên bản kiểm tra xe)
CREATE TABLE IF NOT EXISTS Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT,
    inspector_name VARCHAR(100) NOT NULL,
    
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) ON DELETE RESTRICT
);

-- =========================================================
-- MÔ PHỎNG KỊCH BẢN THỰC TẾ (DML)
-- =========================================================

-- Bước 1: Thêm xe vào hệ thống
INSERT INTO Cars (model_name, license_plate) 
VALUES ('Toyota Camry', '30A-123.45');

-- Bước 2: Khách "Nguyen Van A" đặt và nhận xe, đóng cọc 10.000.000 VNĐ (Trạng thái ACTIVE)
INSERT INTO Rentals (car_id, customer_name, rent_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-09-20 08:00:00', 'ACTIVE', 10000000.00);

-- Bước 3: Khách trả xe. Nhân viên kiểm tra phát hiện vỡ đèn pha trái
INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
VALUES (1, '2026-09-21 16:00:00', 'Vỡ đèn pha trái', 'Nhan Vien B');

-- Bước 4: Cập nhật hợp đồng: Trạng thái COMPLETED, ghi nhận phí phạt hư hỏng 2.000.000 VNĐ
UPDATE Rentals 
SET status = 'COMPLETED',
    return_date = '2026-09-21 16:00:00',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = 1;

-- Bước 5: Truy vấn tính toán chính xác số tiền hoàn lại cho khách hàng
SELECT 
    r.rental_id,
    r.customer_name,
    c.model_name,
    c.license_plate,
    r.security_deposit AS tiền_cọc,
    r.late_fee AS phí_trễ_giờ,
    r.damage_fee AS phí_hư_hỏng,
    (r.security_deposit - r.late_fee - r.damage_fee) AS tiền_hoàn_trả_khách,
    r.status AS trạng_thái
FROM Rentals r
JOIN Cars c ON r.car_id = c.car_id
WHERE r.rental_id = 1;