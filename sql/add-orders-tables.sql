-- ============================================================
-- Add Orders tables to existing clothing_db database
-- Run this script to add missing orders and order_items tables
-- ============================================================

USE clothing_db;

-- -----------------------------------------------------------
-- Orders table: customer orders
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `o_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(255) NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  `shipping_address` TEXT,
  `payment_method` VARCHAR(50) DEFAULT 'COD',
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

-- ============================================================
-- Sample orders data (optional - uncomment to add)
-- ============================================================

-- INSERT INTO `orders` (`user_id`, `total_amount`, `status`, `shipping_address`, `payment_method`) VALUES
-- ('test.user@example.com', 2499.00, 'delivered', '123 Main St, City, State 12345', 'COD');
-- 
-- SET @order1_id = LAST_INSERT_ID();
-- 
-- INSERT INTO `order_items` (`o_id`, `p_id`, `p_name`, `p_price`, `p_image`, `size`, `quantity`, `subtotal`) VALUES
-- (@order1_id, 1, 'Sapphire Silk Saree', 2499.00, 'saree_1.jpeg', 'Free Size', 1, 2499.00);
