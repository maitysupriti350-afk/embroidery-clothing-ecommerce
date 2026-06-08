-- Create payments table for storing online payment records
CREATE TABLE IF NOT EXISTS `payments` (
  `payment_id` VARCHAR(255) PRIMARY KEY COMMENT 'Razorpay Payment ID',
  `user_id` VARCHAR(255) NOT NULL COMMENT 'User ID',
  `order_id` VARCHAR(255) NOT NULL COMMENT 'Order ID',
  `status` VARCHAR(50) NOT NULL COMMENT 'Payment status (SUCCESS, FAILED, PENDING)',
  `amount` DECIMAL(10, 2) DEFAULT NULL COMMENT 'Payment amount in INR',
  `payment_method` VARCHAR(50) DEFAULT NULL COMMENT 'Payment method (UPI, Card, Wallet, NetBanking)',
  `payment_date` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When payment was made',
  `notes` TEXT DEFAULT NULL COMMENT 'Additional notes',
  KEY `user_id_idx` (`user_id`),
  KEY `order_id_idx` (`order_id`),
  KEY `status_idx` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create payment_logs table for audit trail
CREATE TABLE IF NOT EXISTS `payment_logs` (
  `log_id` INT AUTO_INCREMENT PRIMARY KEY,
  `payment_id` VARCHAR(255),
  `event` VARCHAR(100) COMMENT 'Event type (INITIATED, PROCESSING, COMPLETED, FAILED, VERIFIED)',
  `details` TEXT COMMENT 'Event details',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
