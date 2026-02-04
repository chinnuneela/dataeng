-- ============================================
-- LinkedIn Data Model - Basic Level
-- Compatible with https://erd.dbdesigner.net/
-- ============================================

-- Drop tables if they exist (for clean import)
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS user_skills;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS work_experience;
DROP TABLE IF EXISTS connections;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS users;

-- ============================================
-- 1. USERS TABLE
-- ============================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    headline VARCHAR(200),
    profile_photo_url VARCHAR(500),
    location VARCHAR(100),
    about TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_name (first_name, last_name)
);

-- ============================================
-- 2. COMPANIES TABLE
-- ============================================
CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(100),
    company_size VARCHAR(50),
    headquarters VARCHAR(100),
    website VARCHAR(200),
    description TEXT,
    logo_url VARCHAR(500),
    founded_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_company_name (company_name)
);

-- ============================================
-- 3. POSTS TABLE
-- ============================================
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- ============================================
-- 4. COMMENTS TABLE
-- ============================================
CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id)
);

-- ============================================
-- 5. LIKES TABLE
-- ============================================
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_post_like (user_id, post_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id)
);

-- ============================================
-- 6. CONNECTIONS TABLE (Self-referencing M:N)
-- ============================================
CREATE TABLE connections (
    connection_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id_1 INT NOT NULL,
    user_id_2 INT NOT NULL,
    status ENUM('pending', 'accepted', 'blocked') DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id_1) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id_2) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_connection (user_id_1, user_id_2),
    CHECK (user_id_1 != user_id_2),
    INDEX idx_user1 (user_id_1),
    INDEX idx_user2 (user_id_2),
    INDEX idx_status (status)
);

-- ============================================
-- 7. WORK EXPERIENCE TABLE
-- ============================================
CREATE TABLE work_experience (
    experience_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    company_id INT,
    job_title VARCHAR(100) NOT NULL,
    employment_type ENUM('Full-time', 'Part-time', 'Contract', 'Freelance', 'Internship') DEFAULT 'Full-time',
    start_date DATE NOT NULL,
    end_date DATE NULL,
    description TEXT,
    is_current BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_company_id (company_id),
    INDEX idx_dates (start_date, end_date)
);

-- ============================================
-- 8. EDUCATION TABLE
-- ============================================
CREATE TABLE education (
    education_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    institution_name VARCHAR(200) NOT NULL,
    degree VARCHAR(100),
    field_of_study VARCHAR(100),
    start_year INT,
    end_year INT NULL,
    grade VARCHAR(20),
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_institution (institution_name)
);

-- ============================================
-- 9. SKILLS TABLE (Master List)
-- ============================================
CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50),
    INDEX idx_skill_name (skill_name),
    INDEX idx_category (category)
);

-- ============================================
-- 10. USER_SKILLS TABLE (Junction Table)
-- ============================================
CREATE TABLE user_skills (
    user_skill_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Intermediate',
    years_of_experience INT DEFAULT 0,
    endorsed_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_skill (user_id, skill_id),
    INDEX idx_user_id (user_id),
    INDEX idx_skill_id (skill_id)
);

-- ============================================
-- 11. MESSAGES TABLE
-- ============================================
CREATE TABLE messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (sender_id != receiver_id),
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_sent_at (sent_at)
);

-- ============================================
-- SAMPLE DATA FOR TESTING
-- ============================================

-- Insert sample users
INSERT INTO users (first_name, last_name, email, password_hash, headline, location, about) VALUES
('John', 'Doe', 'john.doe@email.com', 'hashed_password_123', 'Software Engineer at Tech Corp', 'San Francisco, CA', 'Passionate about building scalable systems'),
('Jane', 'Smith', 'jane.smith@email.com', 'hashed_password_456', 'Product Manager at StartupXYZ', 'New York, NY', 'Driving product innovation'),
('Mike', 'Johnson', 'mike.j@email.com', 'hashed_password_789', 'Data Scientist at AI Labs', 'Boston, MA', 'Machine learning enthusiast'),
('Sarah', 'Williams', 'sarah.w@email.com', 'hashed_password_321', 'UX Designer at Creative Co', 'Austin, TX', 'Designing delightful user experiences'),
('David', 'Brown', 'david.b@email.com', 'hashed_password_654', 'Marketing Director at Brand Inc', 'Chicago, IL', 'Building brands that matter');

-- Insert sample companies
INSERT INTO companies (company_name, industry, company_size, headquarters, website, founded_year) VALUES
('Tech Corp', 'Technology', '1000-5000', 'San Francisco, CA', 'www.techcorp.com', 2010),
('StartupXYZ', 'Technology', '50-200', 'New York, NY', 'www.startupxyz.com', 2018),
('AI Labs', 'Artificial Intelligence', '200-500', 'Boston, MA', 'www.ailabs.com', 2015),
('Creative Co', 'Design', '100-500', 'Austin, TX', 'www.creativeco.com', 2012),
('Brand Inc', 'Marketing', '500-1000', 'Chicago, IL', 'www.brandinc.com', 2008);

-- Insert sample connections
INSERT INTO connections (user_id_1, user_id_2, status, accepted_at) VALUES
(1, 2, 'accepted', NOW()),
(1, 3, 'accepted', NOW()),
(2, 3, 'accepted', NOW()),
(2, 4, 'pending', NULL),
(3, 5, 'accepted', NOW());

-- Insert sample posts
INSERT INTO posts (user_id, content) VALUES
(1, 'Excited to share that I just completed a major project on microservices architecture! #SoftwareEngineering'),
(2, 'Just launched our new product feature! Grateful for the amazing team. #ProductManagement'),
(3, 'Published a new research paper on neural networks. Link in comments. #MachineLearning'),
(4, 'Design thinking workshop was amazing! Here are my key takeaways... #UXDesign'),
(1, 'Looking for recommendations on best practices for API design. Thoughts?');

-- Insert sample comments
INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, 'Congratulations! Would love to hear more about your approach.'),
(1, 3, 'Great work! Microservices are the future.'),
(2, 1, 'Amazing achievement! The feature looks great.'),
(3, 1, 'Fascinating research! Will definitely read it.'),
(5, 2, 'RESTful design principles are a good starting point.');

-- Insert sample likes
INSERT INTO likes (post_id, user_id) VALUES
(1, 2), (1, 3), (1, 4),
(2, 1), (2, 3),
(3, 1), (3, 2), (3, 4), (3, 5),
(4, 1), (4, 2),
(5, 2), (5, 3);

-- Insert sample work experience
INSERT INTO work_experience (user_id, company_id, job_title, employment_type, start_date, is_current) VALUES
(1, 1, 'Senior Software Engineer', 'Full-time', '2020-01-15', TRUE),
(2, 2, 'Product Manager', 'Full-time', '2019-06-01', TRUE),
(3, 3, 'Lead Data Scientist', 'Full-time', '2021-03-10', TRUE),
(4, 4, 'Senior UX Designer', 'Full-time', '2018-09-01', TRUE),
(5, 5, 'Marketing Director', 'Full-time', '2017-11-20', TRUE);

-- Insert sample education
INSERT INTO education (user_id, institution_name, degree, field_of_study, start_year, end_year) VALUES
(1, 'Stanford University', 'Bachelor of Science', 'Computer Science', 2012, 2016),
(2, 'MIT', 'Master of Business Administration', 'Business Administration', 2015, 2017),
(3, 'Carnegie Mellon University', 'PhD', 'Machine Learning', 2016, 2021),
(4, 'Rhode Island School of Design', 'Bachelor of Fine Arts', 'Graphic Design', 2010, 2014),
(5, 'Northwestern University', 'Bachelor of Arts', 'Marketing', 2008, 2012);

-- Insert sample skills
INSERT INTO skills (skill_name, category) VALUES
('Python', 'Technical'),
('JavaScript', 'Technical'),
('Machine Learning', 'Technical'),
('Product Management', 'Business'),
('UX Design', 'Design'),
('SQL', 'Technical'),
('Leadership', 'Soft Skills'),
('Communication', 'Soft Skills'),
('Project Management', 'Business'),
('Data Analysis', 'Technical');

-- Insert sample user skills
INSERT INTO user_skills (user_id, skill_id, proficiency_level, years_of_experience, endorsed_count) VALUES
(1, 1, 'Expert', 8, 15),
(1, 2, 'Advanced', 6, 10),
(1, 6, 'Expert', 7, 12),
(2, 4, 'Expert', 5, 20),
(2, 9, 'Advanced', 6, 18),
(3, 1, 'Expert', 10, 25),
(3, 3, 'Expert', 8, 30),
(3, 10, 'Expert', 9, 22),
(4, 5, 'Expert', 12, 28),
(4, 8, 'Advanced', 10, 15),
(5, 4, 'Advanced', 8, 16),
(5, 7, 'Expert', 10, 20);

-- Insert sample messages
INSERT INTO messages (sender_id, receiver_id, content, is_read) VALUES
(1, 2, 'Hey Jane, would love to discuss the new API design!', TRUE),
(2, 1, 'Sure John! Let''s schedule a call this week.', TRUE),
(1, 3, 'Mike, your research paper was fascinating!', FALSE),
(3, 1, 'Thanks John! Happy to discuss it further.', FALSE),
(2, 4, 'Sarah, can you review the new design mockups?', TRUE);

-- ============================================
-- USEFUL QUERIES FOR TESTING
-- ============================================

-- Query 1: Get user profile with connection count
-- SELECT u.*, COUNT(DISTINCT c.connection_id) as connection_count
-- FROM users u
-- LEFT JOIN connections c ON (u.user_id = c.user_id_1 OR u.user_id = c.user_id_2) AND c.status = 'accepted'
-- WHERE u.user_id = 1
-- GROUP BY u.user_id;

-- Query 2: Get user's posts with engagement metrics
-- SELECT p.*, 
--        COUNT(DISTINCT l.like_id) as like_count,
--        COUNT(DISTINCT c.comment_id) as comment_count
-- FROM posts p
-- LEFT JOIN likes l ON p.post_id = l.post_id
-- LEFT JOIN comments c ON p.post_id = c.post_id
-- WHERE p.user_id = 1 AND p.is_deleted = FALSE
-- GROUP BY p.post_id
-- ORDER BY p.created_at DESC;

-- Query 3: Get user's skills
-- SELECT u.first_name, u.last_name, s.skill_name, us.proficiency_level, us.endorsed_count
-- FROM users u
-- JOIN user_skills us ON u.user_id = us.user_id
-- JOIN skills s ON us.skill_id = s.skill_id
-- WHERE u.user_id = 1
-- ORDER BY us.endorsed_count DESC;

-- Query 4: Get user's work history
-- SELECT we.job_title, c.company_name, we.employment_type, 
--        we.start_date, we.end_date, we.is_current
-- FROM work_experience we
-- LEFT JOIN companies c ON we.company_id = c.company_id
-- WHERE we.user_id = 1
-- ORDER BY we.start_date DESC;

-- Query 5: Get mutual connections between two users
-- SELECT u.user_id, u.first_name, u.last_name
-- FROM users u
-- WHERE u.user_id IN (
--     SELECT CASE 
--         WHEN c1.user_id_1 = 1 THEN c1.user_id_2
--         ELSE c1.user_id_1
--     END
--     FROM connections c1
--     WHERE (c1.user_id_1 = 1 OR c1.user_id_2 = 1) AND c1.status = 'accepted'
--     INTERSECT
--     SELECT CASE 
--         WHEN c2.user_id_1 = 2 THEN c2.user_id_2
--         ELSE c2.user_id_1
--     END
--     FROM connections c2
--     WHERE (c2.user_id_1 = 2 OR c2.user_id_2 = 2) AND c2.status = 'accepted'
-- );
