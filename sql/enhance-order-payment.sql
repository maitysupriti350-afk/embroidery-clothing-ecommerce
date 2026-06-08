-- ============================================================
-- Enhance Orders table with Payment & Approval workflow
-- Run this script to add payment and approval tracking
-- ============================================================

USE clothing_db;

-- Add payment tracking columns to orders table
ALTER TABLE `orders` MODIFY COLUMN `status` ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'out_of_stock') DEFAULT 'pending';
ALTER TABLE `orders` ADD COLUMN `payment_status` ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending' AFTER `payment_method`;
ALTER TABLE `orders` ADD COLUMN `payment_id` VARCHAR(100) DEFAULT NULL AFTER `payment_status`;
ALTER TABLE `orders` ADD COLUMN `payment_date` TIMESTAMP NULL DEFAULT NULL AFTER `payment_id`;

-- Add address verification column
ALTER TABLE `orders` ADD COLUMN `address_verified` BOOLEAN DEFAULT FALSE AFTER `shipping_address`;
ALTER TABLE `orders` ADD COLUMN `verified_at` TIMESTAMP NULL DEFAULT NULL AFTER `address_verified`;
ALTER TABLE `orders` ADD COLUMN `verified_by` VARCHAR(255) DEFAULT NULL AFTER `verified_at`;

-- Add approval workflow columns
ALTER TABLE `orders` ADD COLUMN `admin_approval_date` TIMESTAMP NULL DEFAULT NULL AFTER `verified_by`;
ALTER TABLE `orders` ADD COLUMN `approval_status` ENUM('pending_review', 'approved', 'rejected', 'payment_verification_failed') DEFAULT 'pending_review' AFTER `admin_approval_date`;
ALTER TABLE `orders` ADD COLUMN `approval_notes` TEXT DEFAULT NULL AFTER `approval_status`;

-- Order notifications tracking
CREATE TABLE IF NOT EXISTS `order_notifications` (
  `notif_id` INT NOT NULL AUTO_INCREMENT,
  `o_id` INT NOT NULL,
  `user_id` VARCHAR(255) NOT NULL,
  `notification_type` ENUM('order_placed', 'payment_received', 'order_approved', 'order_shipped', 'order_delivered', 'payment_failed', 'address_verification_required') DEFAULT 'order_placed',
  `message` TEXT NOT NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notif_id`),
  FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,
  INDEX (`user_id`),
  INDEX (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payment verification log
CREATE TABLE IF NOT EXISTS `payment_verification_log` (
  `pv_id` INT NOT NULL AUTO_INCREMENT,
  `o_id` INT NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL,
  `transaction_id` VARCHAR(100) DEFAULT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `verification_result` JSON DEFAULT NULL,
  `verified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `verified_by` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`pv_id`),
  FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,
  INDEX (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
