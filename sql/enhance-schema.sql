-- ============================================================
-- Database Schema Enhancements for THE GILDED STITCH
-- This script adds missing critical fields and relationships
-- Run this AFTER schema.sql to enhance the database structure
-- ============================================================

USE clothingstore;

-- -----------------------------------------------------------
-- Enhance User Table: Add password hashing and role management
-- -----------------------------------------------------------
ALTER TABLE `user` 
ADD COLUMN IF NOT EXISTS `password_hash` VARCHAR(255) DEFAULT NULL COMMENT 'Hashed password using BCrypt',
ADD COLUMN IF NOT EXISTS `role` ENUM('customer', 'admin') DEFAULT 'customer' COMMENT 'User role for access control',
ADD COLUMN IF NOT EXISTS `is_active` BOOLEAN DEFAULT TRUE COMMENT 'Account status',
ADD COLUMN IF NOT EXISTS `last_login` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last successful login timestamp';

-- Add index for role-based queries
CREATE INDEX IF NOT EXISTS idx_user_role ON `user`(`role`);
CREATE INDEX IF NOT EXISTS idx_user_active ON `user`(`is_active`);

-- -----------------------------------------------------------
-- Enhance Products Table: Add inventory management
-- -----------------------------------------------------------
ALTER TABLE `products`
ADD COLUMN IF NOT EXISTS `stock_quantity` INT DEFAULT 0 COMMENT 'Available stock quantity',
ADD COLUMN IF NOT EXISTS `reorder_level` INT DEFAULT 5 COMMENT 'Minimum stock level for reordering',
ADD COLUMN IF NOT EXISTS `is_active` BOOLEAN DEFAULT TRUE COMMENT 'Product availability status',
ADD COLUMN IF NOT EXISTS `sku` VARCHAR(50) DEFAULT NULL COMMENT 'Unique Stock Keeping Unit',
ADD COLUMN IF NOT EXISTS `weight` DECIMAL(6,2) DEFAULT NULL COMMENT 'Product weight in kg',
ADD COLUMN IF NOT EXISTS `brand` VARCHAR(100) DEFAULT NULL COMMENT 'Product brand',
ADD COLUMN IF NOT EXISTS `material` VARCHAR(100) DEFAULT NULL COMMENT 'Product material/fabric',
ADD COLUMN IF NOT EXISTS `color` VARCHAR(50) DEFAULT NULL COMMENT 'Product color',
ADD COLUMN IF NOT EXISTS `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Add indexes for product queries
CREATE INDEX IF NOT EXISTS idx_products_category ON `products`(`p_category`);
CREATE INDEX IF NOT EXISTS idx_products_active ON `products`(`is_active`);
CREATE INDEX IF NOT EXISTS idx_products_sku ON `products`(`sku`);

-- -----------------------------------------------------------
-- Enhance Cart Table: Add foreign key constraints
-- -----------------------------------------------------------
ALTER TABLE `cart`
ADD COLUMN IF NOT EXISTS `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD CONSTRAINT IF NOT EXISTS fk_cart_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE,
ADD CONSTRAINT IF NOT EXISTS fk_cart_product FOREIGN KEY (`p_id`) REFERENCES `products`(`p_id`) ON DELETE CASCADE;

-- -----------------------------------------------------------
-- Enhance Orders Table: Add foreign key constraint
-- -----------------------------------------------------------
ALTER TABLE `orders`
ADD CONSTRAINT IF NOT EXISTS fk_orders_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE;

-- -----------------------------------------------------------
-- Add Guest Orders Table: For guest checkout functionality
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `guest_orders` (
  `guest_id` INT NOT NULL AUTO_INCREMENT,
  `guest_email` VARCHAR(255) NOT NULL,
  `guest_name` VARCHAR(255) NOT NULL,
  `guest_phone` VARCHAR(20) NOT NULL,
  `o_id` INT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`guest_id`),
  UNIQUE KEY `unique_guest_order` (`guest_email`, `o_id`),
  CONSTRAINT fk_guest_order FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Add Product Reviews Table: For customer feedback
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `product_reviews` (
  `review_id` INT NOT NULL AUTO_INCREMENT,
  `p_id` INT NOT NULL,
  `user_id` VARCHAR(255) NOT NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `review_text` TEXT,
  `is_verified_purchase` BOOLEAN DEFAULT FALSE,
  `is_approved` BOOLEAN DEFAULT TRUE,
  `helpful_count` INT DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  CONSTRAINT fk_review_product FOREIGN KEY (`p_id`) REFERENCES `products`(`p_id`) ON DELETE CASCADE,
  CONSTRAINT fk_review_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE,
  INDEX `idx_reviews_product` (`p_id`),
  INDEX `idx_reviews_user` (`user_id`),
  INDEX `idx_reviews_rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Add Coupons Table: For promotional discounts
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `coupons` (
  `coupon_id` INT NOT NULL AUTO_INCREMENT,
  `coupon_code` VARCHAR(50) NOT NULL UNIQUE,
  `discount_type` ENUM('percentage', 'fixed') DEFAULT 'percentage',
  `discount_value` DECIMAL(10,2) NOT NULL,
  `min_order_value` DECIMAL(10,2) DEFAULT 0,
  `max_discount` DECIMAL(10,2) DEFAULT NULL,
  `usage_limit` INT DEFAULT NULL,
  `used_count` INT DEFAULT 0,
  `valid_from` TIMESTAMP NOT NULL,
  `valid_until` TIMESTAMP NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `description` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`coupon_id`),
  INDEX `idx_coupons_code` (`coupon_code`),
  INDEX `idx_coupons_active` (`is_active`, `valid_from`, `valid_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Add User Coupons Table: Track coupon usage per user
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_coupons` (
  `uc_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `coupon_id` INT NOT NULL,
  `order_id` INT DEFAULT NULL,
  `discount_applied` DECIMAL(10,2) NOT NULL,
  `used_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`uc_id`),
  CONSTRAINT fk_uc_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE,
  CONSTRAINT fk_uc_coupon FOREIGN KEY (`coupon_id`) REFERENCES `coupons`(`coupon_id`) ON DELETE CASCADE,
  CONSTRAINT fk_uc_order FOREIGN KEY (`order_id`) REFERENCES `orders`(`o_id`) ON DELETE SET NULL,
  INDEX `idx_uc_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Add Reward Points Table: For customer loyalty program
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `reward_points` (
  `rp_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `points_earned` INT DEFAULT 0,
  `points_redeemed` INT DEFAULT 0,
  `points_balance` INT DEFAULT 0,
  `last_earned_at` TIMESTAMP NULL DEFAULT NULL,
  `last_redeemed_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rp_id`),
  UNIQUE KEY `unique_user_rewards` (`user_id`),
  CONSTRAINT fk_rewards_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Add Reward Transactions Table: Track point changes
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `reward_transactions` (
  `rt_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `transaction_type` ENUM('earned', 'redeemed', 'expired', 'adjusted') DEFAULT 'earned',
  `points` INT NOT NULL,
  `balance_after` INT NOT NULL,
  `description` VARCHAR(255),
  `reference_id` VARCHAR(100) DEFAULT NULL COMMENT 'Order ID or other reference',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rt_id`),
  CONSTRAINT fk_rt_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE,
  INDEX `idx_rt_user` (`user_id`),
  INDEX `idx_rt_type` (`transaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Add Shipping Addresses Table: Multiple addresses per user
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `shipping_addresses` (
  `address_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `address_type` ENUM('home', 'office', 'other') DEFAULT 'home',
  `full_name` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `address_line1` VARCHAR(255) NOT NULL,
  `address_line2` VARCHAR(255) DEFAULT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(100) NOT NULL,
  `pincode` VARCHAR(10) NOT NULL,
  `is_default` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  CONSTRAINT fk_address_user FOREIGN KEY (`user_id`) REFERENCES `user`(`userid`) ON DELETE CASCADE,
  INDEX `idx_address_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Update existing admin user with admin role
-- -----------------------------------------------------------
UPDATE `user` SET `role` = 'admin' WHERE `userid` = 'admin@example.com';

-- -----------------------------------------------------------
-- Initialize stock quantities for existing products
-- -----------------------------------------------------------
UPDATE `products` SET `stock_quantity` = 50 WHERE `stock_quantity` = 0;

-- ============================================================
-- Schema Enhancement Complete
-- ============================================================
-- Summary of changes:
-- 1. User table: Added password_hash, role, is_active, last_login
-- 2. Products table: Added stock_quantity, reorder_level, is_active, sku, weight, brand, material, color
-- 3. Cart table: Added foreign key constraints
-- 4. Orders table: Added foreign key constraint
-- 5. New tables: guest_orders, product_reviews, coupons, user_coupons, reward_points, reward_transactions, shipping_addresses
-- ============================================================
