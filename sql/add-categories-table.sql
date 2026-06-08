-- ============================================================
-- Add Categories Table for Dynamic Category Management
-- This allows admin to add/remove categories without code changes
-- Run this after schema.sql and enhance-schema.sql
-- ============================================================

USE clothingstore;

-- -----------------------------------------------------------
-- Create Categories Table
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `category_name` VARCHAR(100) NOT NULL UNIQUE,
  `category_description` TEXT DEFAULT NULL,
  `display_order` INT DEFAULT 0 COMMENT 'Order for displaying categories',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'Whether category is visible',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  INDEX `idx_categories_active` (`is_active`, `display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- Insert Default Categories
-- -----------------------------------------------------------
INSERT INTO `categories` (`category_name`, `category_description`, `display_order`, `is_active`) VALUES
('Saree', 'Traditional Indian sarees in various fabrics and designs', 1, TRUE),
('Kurti', 'Stylish kurtis and tops for modern women', 2, TRUE),
('Lehenga', 'Elegant lehengas for special occasions', 3, TRUE),
('Suit', 'Complete suit sets including salwar, kameez, and dupatta', 4, TRUE),
('Churidar', 'Churidar bottoms and traditional wear', 5, TRUE);

-- -----------------------------------------------------------
-- Add Foreign Key Constraint to Products Table
-- -----------------------------------------------------------
ALTER TABLE `products`
ADD COLUMN IF NOT EXISTS `category_id` INT DEFAULT NULL COMMENT 'Foreign key to categories table',
ADD CONSTRAINT IF NOT EXISTS fk_product_category FOREIGN KEY (`category_id`) REFERENCES `categories`(`category_id`) ON DELETE SET NULL;

-- -----------------------------------------------------------
-- Update existing products to link to categories
-- -----------------------------------------------------------
UPDATE `products` p
SET `category_id` = (
  SELECT `category_id` FROM `categories` c 
  WHERE LOWER(p.`p_category`) LIKE CONCAT('%', LOWER(c.`category_name`), '%')
  LIMIT 1
)
WHERE `category_id` IS NULL AND `p_category` IS NOT NULL;

-- -----------------------------------------------------------
-- Create Category Management View for Admin
-- -----------------------------------------------------------
CREATE OR REPLACE VIEW `v_category_stats` AS
SELECT 
  c.category_id,
  c.category_name,
  c.is_active,
  COUNT(p.p_id) AS product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name, c.is_active
ORDER BY c.display_order;

-- ============================================================
-- Complete
-- ============================================================
