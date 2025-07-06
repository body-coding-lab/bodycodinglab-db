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

CREATE TABLE IF NOT EXISTS `members`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    member_address VARCHAR(255) NOT NULL,
    one_day_ticket_count TINYINT DEFAULT 3,
    member_status VARCHAR(30) NOT NULL,
    
    CONSTRAINT fk_members_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_members_member_status CHECK (member_status IN ('NOT_SUBSCRIPTION', 'SUBSCRIPTION'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `subscriptions`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    price INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    CONSTRAINT fk_subscriptions_member_id FOREIGN KEY (member_id) REFERENCES members(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    job_address VARCHAR(255) NOT NULL,
    attachment_file_id BIGINT,
    short_introduce VARCHAR(150),
    long_introduce TEXT,
    status VARCHAR(20) NOT NULL,
    education_name VARCHAR(100),
    education_entrance VARCHAR(10),
    education_graduate VARCHAR(10),
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	CONSTRAINT fk_trainers_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_trainers_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_careers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    company_join DATE NOT NULL,
    company_quit DATE NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trainer_careers_trainer_id FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_licenses` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trainer_id BIGINT NOT NULL,
    license_type VARCHAR(50) NOT NULL,
    license_name DATE NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trainer_licenses_trainer_id FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE CASCADE,
	CONSTRAINT ck_trainer_license_type CHECK (license_type IN ('LICENSE', 'CERTIFICATE', 'AWARD_DETAIL'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payments`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    payment_key VARCHAR(255), 
    order_id VARCHAR(255) NOT NULL,
    amount INT NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    member_id BIGINT NOT NULL,
    subscription_id BIGINT,
	
    CONSTRAINT uq_payments_payment_key UNIQUE (payment_key),
    CONSTRAINT uq_payments_order_id UNIQUE (order_id),
    CONSTRAINT uq_payments_subscription_id UNIQUE (subscription_id),
    CONSTRAINT fk_payments_member_id FOREIGN KEY (member_id) REFERENCES members(id),
    CONSTRAINT fk_payments_subscription_id FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
    CONSTRAINT ck_payments_payment_status CHECK (payment_status IN ('READY', 'SUCCESS', 'FAIL')),
    CONSTRAINT ck_payments_payment_method CHECK(payment_method IN ('KAKAO_PAY'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `match_waiting_list`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_status VARCHAR(50) NOT NULL,
    reject_response TEXT,
    
    CONSTRAINT uq_match_waiting_list_member_id UNIQUE (member_id),
    CONSTRAINT fk_match_waiting_list_member_id FOREIGN KEY (member_id) REFERENCES user(id) ON DELETE CASCADE,
    CONSTRAINT fk_match_waiting_list_trainer_id FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_match_waiting_list_approved_status CHECK (approved_status IN ('NOT_APPROVED', 'APPROVED', 'REJECT'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `matches`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
    match_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_maintained BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT uq_matches_member_id UNIQUE (member_id),
    CONSTRAINT uq_matches_member_id_trainer_id UNIQUE (member_id, trainer_id),
    CONSTRAINT fk_matches_member_id FOREIGN KEY (member_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_matches_trainer_id FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `boards` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,
    category VARCHAR(20) NOT NULL,
    post_title VARCHAR(100) NOT NULL,
    post_content TEXT NOT NULL,
    writer_id BIGINT NOT NULL,
    view_count BIGINT NOT NULL DEFAULT 0,
	post_like BIGINT NOT NULL DEFAULT 0,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	CONSTRAINT fk_boards_match_id FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
	CONSTRAINT fk_boards_writer_id FOREIGN KEY (writer_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_boards_category CHECK (status IN ('MEAL', 'ROUTINE', 'COMMUNITY'))
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
    CONSTRAINT ck_one_day_tickets_status CHECK (status IN ('ISSUED', 'USED', 'CANCELED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `coupons`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    trainer_id BIGINT NOT NULL,
	expiration_period DATE NOT NULL,
    used_date TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    coupon_status VARCHAR(50) NOT NULL,
    
    CONSTRAINT fk_coupons_member_id FOREIGN KEY (member_id) REFERENCES users(id),
    CONSTRAINT fk_coupons_trainer_id FOREIGN KEY (trainer_id) REFERENCES users(id),
    CONSTRAINT ck_coupons_coupon_status CHECK (coupon_status IN ('NOT_USED', 'APPLICATION', 'COMPLETE', 'EXPIRED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; 

CREATE TABLE IF NOT EXISTS `member_forms`(
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    is_submit BOOLEAN DEFAULT FALSE,
    bodyform VARCHAR(30) NOT NULL,
    goal VARCHAR(30) NOT NULL,
    bmi VARCHAR(30) NOT NULL,
    improved_part VARCHAR(30) NOT NULL,
    preferred_diet VARCHAR(30) NOT NULL,
    sugar_intake VARCHAR(30) NOT NULL,
    water_intake VARCHAR(30) NOT NULL,
    height TINYINT UNSIGNED NOT NULL,
	weight TINYINT UNSIGNED NOT NULL,
    weight_goal TINYINT UNSIGNED NOT NULL,
    physical_level TINYINT UNSIGNED NOT NULL,
    exercising_problem VARCHAR(30) NOT NULL,
    pushup_level VARCHAR(30) NOT NULL,
    pullup_level VARCHAR(30) NOT NULL,
    exercise_frequency VARCHAR(30) NOT NULL,
    investable_time VARCHAR(30) NOT NULL,
    
    CONSTRAINT fk_member_forms_member_id FOREIGN KEY (member_id) REFERENCES members (id),
    CONSTRAINT ck_member_forms_bodyform CHECK (bodyform IN ('SLIM', 'NORMAL', 'FAT')),
    CONSTRAINT ck_member_forms_goal CHECK (goal IN ('DIET', 'IMPROVEMENT_OF_MUSCLE', 'PERFORMANCE')),
    CONSTRAINT ck_member_forms_bmi CHECK (bmi IN ('LESS_18', 'BETWEEN_18TO23', 'BETWEEN_23TO25', 'MORE_25')),
    CONSTRAINT ck_member_forms_improved_part CHECK (improved_part IN ('CHEST', 'ARM', 'STOMACH', 'LEG', 'NOT_APPLICABLE')),
    CONSTRAINT ck_member_forms_preferred_diet CHECK (preferred_diet IN ('VEGETARIAN', 'VEGAN', 'KITO', 'MEDITERRANEAN', 'CARNIVORE', 'NOT_APPLICABLE')),
    CONSTRAINT ck_member_forms_sugar_intake CHECK (sugar_intake IN ('DONT_OFTEN', 'WEEK_3TO5', 'EVERYDAY')),
    CONSTRAINT ck_member_forms_water_intake CHECK (water_intake IN ('COFFEE_TEA', 'LESS_2', 'BETWEEN_2TO6', 'BETWEEN_7TO10', 'MORE_10')),
    CONSTRAINT ck_member_forms_exercising_problem CHECK (exercising_problem IN ('MOTIVATION', 'EFFECT', 'HARD', 'PLAN', 'COACHING', 'NOT_APPLICABLE')),
	CONSTRAINT ck_member_forms_pushup_level CHECK (pushup_level IN ('LESS_5', 'BETWEEN_5TO10', 'MORE_10')),
    CONSTRAINT ck_member_forms_pullup_level CHECK (pullup_level IN ('LESS_5', 'BEWEENT_5TO10', 'MORE_10')),
    CONSTRAINT ck_member_forms_exercise_frequency CHECK (exercise_frequency IN ('NEVER', 'WEEK_1TO2', 'WEEK_3', 'MORE_WEEK_3')),
    CONSTRAINT ck_member_forms_investable_time CHECK (investable_time IN ('MIN30', 'MIN40', 'HOUR1', 'FREEDOM'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `upload_files` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    original_name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    target_id BIGINT NOT NULL,
    target_type VARCHAR(30) NOT NULL,
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
    
    CONSTRAINT fk_trainer_status_logs_trainer_id FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL,
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