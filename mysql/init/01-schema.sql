CREATE TABLE IF NOT EXISTS service_request (
  id BIGINT NOT NULL AUTO_INCREMENT,
  request_no VARCHAR(32) NOT NULL,
  customer_category VARCHAR(20) NOT NULL,
  applicant_name VARCHAR(80) NOT NULL,
  company_name VARCHAR(120) NULL,
  email VARCHAR(255) NOT NULL,
  contact_method VARCHAR(20) NOT NULL,
  phone VARCHAR(30) NULL,
  service_plan VARCHAR(20) NOT NULL,
  additional_request_flag BOOLEAN NOT NULL,
  additional_request_detail VARCHAR(500) NULL,
  notes VARCHAR(500) NULL,
  processing_status VARCHAR(30) NOT NULL,
  priority_flag BOOLEAN NOT NULL,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_request_request_no (request_no),
  KEY idx_service_request_created_at (created_at)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

