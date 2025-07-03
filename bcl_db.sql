CREATE DATABASE IF NOT EXISTS `fit_mate_db`
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `fit_mate_db`;

CREATE TABLE IF NOT EXISTS `roles` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_roles_name UNIQUE (name)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `users` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NOT NULL,
    username VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
	name VARCHAR(25) NOT NULL,
    birthdate DATE NOT NULL,
	gender VARCHAR(20) NOT NULL,
	phone VARCHAR(20) NOT NULL,
	email VARCHAR(100) NOT NULL,
    profile_image_id BIGINT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_phone UNIQUE (phone),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT fk_users_role_id FOREIGN KEY (role_id) REFERENCES roles(id),
	CONSTRAINT ck_users_gender CHECK (gender IN ('MALE', 'FEMALE'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `one_day_tickets` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    issued_at DATE NOT NULL,
    used_at DATE,
    canceled_at DATE,
    cancel_reason VARCHAR(255),
    status VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_one_day_tickets_member_id FOREIGN KEY (member_id) REFERENCES users(id),
    CONSTRAINT fk_one_day_tickets_trainer_id FOREIGN KEY (trainer_id) REFERENCES users(id),
    CONSTRAINT ck_one_day_tickets_status CHECK (status IN ('ISSUED', 'USED', 'CANCELLED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `upload_files` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    original_name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    target_type VARCHAR(30) NOT NULL,
    license_id BIGINT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT ck_upload_files_target_type CHECK (target_type IN ('PROFILE', 'ATTACHMENT', 'INFO', 'LICENSE', 'BOARD')),
    -- PROFILE: 사용자 프로필 이미지
    -- ATTACHMENT: 트레이너 첨부파일 (계약서 등), INFO: 트레이너 긴 소개 파일, LICENCE: 트레이너 자격증
    -- BOARD: 커뮤니티 첨부파일
    
    INDEX idx_target (target_id, target_type)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `users`
ADD CONSTRAINT fk_users_profile_image_id
FOREIGN KEY (profile_image_id) REFERENCES upload_files(id);

CREATE TABLE IF NOT EXISTS `trainer_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    username VARCHAR(20) NOT NULL,
    prev_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    changed_by BIGINT NOT NULL,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trainer_status_logs_trainer_id FOREIGN KEY (trainer_id) REFERENCES trainers(id),
    CONSTRAINT fk_trainer_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id),
    CONSTRAINT ck_trainer_status_logs_prev_status CHECK (prev_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT ck_trainer_status_logs_new_status CHECK (new_status IN ('PENDING', 'APPROVED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE OR REPLACE VIEW `trainer_list_view` AS
SELECT
	t.id AS trainer_id,
    u.username,
    u.name,
    u.birthdate,
    t.job_address,
    u.created_at,
    t.status
FROM
	trainers t
JOIN
	users u ON t.user_id = u.id
JOIN
	roles r ON u.role_id = r.id
WHERE
	r.name = 'TRAINER';