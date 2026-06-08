-- ============================================================
-- SQL schema for ClothingStore_Final project
-- Compatible with MySQL 8.0+
-- Run this script FIRST, then run sample-data.sql
-- ============================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS clothingstore
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE clothingstore;

-- -----------------------------------------------------------
-- User table: stores email as userid and OTP for login
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
  `userid` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(255) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `address` TEXT DEFAULT NULL,
  `membership` VARCHAR(20) DEFAULT 'Standard',
  `otp` VARCHAR(6) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Products table: catalog of all products
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `products` (
  `p_id` INT NOT NULL AUTO_INCREMENT,
  `p_name` VARCHAR(255) NOT NULL,
  `p_category` VARCHAR(100) DEFAULT NULL,
  `p_price` DECIMAL(10,2) NOT NULL,
  `p_image` VARCHAR(255) DEFAULT NULL,
  `p_desc` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`p_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Cart table: shopping cart per user
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cart` (
  `c_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `p_id` INT NOT NULL,
  `p_name` VARCHAR(255) NOT NULL,
  `p_price` DECIMAL(10,2) NOT NULL,
  `p_image` VARCHAR(255) DEFAULT NULL,
  `size` VARCHAR(10) DEFAULT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`c_id`),
  INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Wishlist table: saved favorite products per user
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `wishlist` (
  `w_id` INT NOT NULL AUTO_INCREMENT,
  `p_id` INT NOT NULL,
  `user_id` VARCHAR(255) NOT NULL,
  `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`w_id`),
  UNIQUE KEY `unique_wishlist_item` (`p_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Orders table: customer orders
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `o_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'out_of_stock') DEFAULT 'pending',
  `shipping_address` TEXT,
  `payment_method` VARCHAR(50) DEFAULT 'COD',
  `payment_status` ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  `payment_id` VARCHAR(100) DEFAULT NULL,
  `payment_date` TIMESTAMP NULL DEFAULT NULL,
  `address_verified` BOOLEAN DEFAULT FALSE,
  `verified_at` TIMESTAMP NULL DEFAULT NULL,
  `verified_by` VARCHAR(255) DEFAULT NULL,
  `admin_approval_date` TIMESTAMP NULL DEFAULT NULL,
  `approval_status` ENUM('pending_review', 'approved', 'rejected', 'payment_verification_failed') DEFAULT 'pending_review',
  `approval_notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`o_id`),
  INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Order items table: individual items within an order
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_items` (
  `oi_id` INT NOT NULL AUTO_INCREMENT,
  `o_id` INT NOT NULL,
  `p_id` INT NOT NULL,
  `p_name` VARCHAR(255) NOT NULL,
  `p_price` DECIMAL(10,2) NOT NULL,
  `p_image` VARCHAR(255) DEFAULT NULL,
  `size` VARCHAR(10) DEFAULT NULL,
  `quantity` INT NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`oi_id`),
  FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,
  INDEX (`o_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Order notifications table: notifications for order workflow
-- -----------------------------------------------------------
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

-- -----------------------------------------------------------
-- Payment verification log table
-- -----------------------------------------------------------
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
