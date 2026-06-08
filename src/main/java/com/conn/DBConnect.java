package com.conn;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBConnect {
    private static volatile boolean schemaInitialized = false;
    // Return a fresh connection for each caller. Callers should close the connection when done.
    public static Connection getConn() {
        // Allow overriding via environment variables for easier local configuration and to avoid hard-coded secrets
        String url = System.getenv("CLOTHING_DB_URL");
        String user = System.getenv("CLOTHING_DB_USER");
        String pass = System.getenv("CLOTHING_DB_PASS");

        if (url == null) url = System.getProperty("db.url", "jdbc:mysql://localhost:3306/clothingstore");
        if (user == null) user = System.getProperty("db.user", "root");
        if (pass == null) pass = System.getProperty("db.pass", "admin123");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Log the URL and user (do not log the password)
            System.out.println("DBConnect: connecting to " + url + " as user=" + user);
            Connection conn = DriverManager.getConnection(url, user, pass);
            initializeSchema(conn);
            return conn;
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("Access denied")) {
                throw new RuntimeException("Failed to connect to DB: Access denied for user '" + user + "'.\n" +
                        "Verify credentials and/or the user host in MySQL. You can set environment variables CLOTHING_DB_USER and CLOTHING_DB_PASS,\n" +
                        "or system properties db.user and db.pass.", e);
            }
            throw new RuntimeException("Failed to establish DB connection: " + e.getMessage(), e);
        }
    }

    public static boolean hasColumn(Connection conn, String tableName, String columnName) {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?")) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            return false;
        }
    }

    private static void initializeSchema(Connection conn) {
        if (schemaInitialized) {
            return;
        }
        synchronized (DBConnect.class) {
            if (schemaInitialized) {
                return;
            }
            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `user` ("
                        + "`userid` VARCHAR(255) NOT NULL,"
                        + "`full_name` VARCHAR(255) DEFAULT NULL,"
                        + "`phone` VARCHAR(20) DEFAULT NULL,"
                        + "`address` TEXT DEFAULT NULL,"
                        + "`membership` VARCHAR(20) DEFAULT 'Standard',"
                        + "`otp` VARCHAR(6) DEFAULT NULL,"
                        + "`otp_generated_at` TIMESTAMP NULL DEFAULT NULL,"
                        + "`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                        + "PRIMARY KEY (`userid`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `products` ("
                        + "`p_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`p_name` VARCHAR(255) NOT NULL,"
                        + "`p_category` VARCHAR(100) DEFAULT NULL,"
                        + "`p_price` DECIMAL(10,2) NOT NULL,"
                        + "`p_image` VARCHAR(255) DEFAULT NULL,"
                        + "`p_desc` TEXT DEFAULT NULL,"
                        + "`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "PRIMARY KEY (`p_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `cart` ("
                        + "`c_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`user_id` VARCHAR(255) NOT NULL,"
                        + "`p_id` INT NOT NULL,"
                        + "`p_name` VARCHAR(255) NOT NULL,"
                        + "`p_price` DECIMAL(10,2) NOT NULL,"
                        + "`p_image` VARCHAR(255) DEFAULT NULL,"
                        + "`size` VARCHAR(10) DEFAULT NULL,"
                        + "`quantity` INT NOT NULL DEFAULT 1,"
                        + "`added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "PRIMARY KEY (`c_id`),"
                        + "INDEX (`user_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `wishlist` ("
                        + "`w_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`p_id` INT NOT NULL,"
                        + "`user_id` VARCHAR(255) NOT NULL,"
                        + "`added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "PRIMARY KEY (`w_id`),"
                        + "UNIQUE KEY `unique_wishlist_item` (`p_id`, `user_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `orders` ("
                        + "`o_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`user_id` VARCHAR(255) NOT NULL,"
                        + "`total_amount` DECIMAL(10,2) NOT NULL,"
                        + "`status` ENUM('pending','confirmed','shipped','delivered','cancelled','out_of_stock') DEFAULT 'pending',"
                        + "`shipping_address` TEXT,"
                        + "`shipping_pincode` VARCHAR(20) DEFAULT NULL,"
                        + "`location_verified` BOOLEAN DEFAULT FALSE,"
                        + "`payment_method` VARCHAR(50) DEFAULT 'COD',"
                        + "`payment_status` ENUM('pending','completed','failed','refunded') DEFAULT 'pending',"
                        + "`payment_id` VARCHAR(100) DEFAULT NULL,"
                        + "`payment_date` TIMESTAMP NULL DEFAULT NULL,"
                        + "`address_verified` BOOLEAN DEFAULT FALSE,"
                        + "`verified_at` TIMESTAMP NULL DEFAULT NULL,"
                        + "`verified_by` VARCHAR(255) DEFAULT NULL,"
                        + "`admin_approval_date` TIMESTAMP NULL DEFAULT NULL,"
                        + "`approval_status` ENUM('pending_review','approved','rejected','payment_verification_failed') DEFAULT 'pending_review',"
                        + "`approval_notes` TEXT DEFAULT NULL,"
                        + "`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
                        + "PRIMARY KEY (`o_id`),"
                        + "INDEX (`user_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `order_items` ("
                        + "`oi_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`o_id` INT NOT NULL,"
                        + "`p_id` INT NOT NULL,"
                        + "`p_name` VARCHAR(255) NOT NULL,"
                        + "`p_price` DECIMAL(10,2) NOT NULL,"
                        + "`p_image` VARCHAR(255) DEFAULT NULL,"
                        + "`size` VARCHAR(10) DEFAULT NULL,"
                        + "`quantity` INT NOT NULL,"
                        + "`subtotal` DECIMAL(10,2) NOT NULL,"
                        + "PRIMARY KEY (`oi_id`),"
                        + "FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,"
                        + "INDEX (`o_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `order_notifications` ("
                        + "`notif_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`o_id` INT NOT NULL,"
                        + "`user_id` VARCHAR(255) NOT NULL,"
                        + "`notification_type` ENUM('order_placed','payment_received','order_approved','order_shipped','order_delivered','payment_failed','address_verification_required') DEFAULT 'order_placed',"
                        + "`message` TEXT NOT NULL,"
                        + "`is_read` BOOLEAN DEFAULT FALSE,"
                        + "`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "PRIMARY KEY (`notif_id`),"
                        + "FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,"
                        + "INDEX (`user_id`),"
                        + "INDEX (`created_at`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                    // Coupons table: supports percent/fixed discounts, first-order only rules, expiry, usage limits
                    stmt.executeUpdate(
                        "CREATE TABLE IF NOT EXISTS `coupons` (" +
                        "`code` VARCHAR(100) NOT NULL PRIMARY KEY, " +
                        "`type` ENUM('percent','fixed') NOT NULL, " +
                        "`value` DECIMAL(10,2) NOT NULL, " +
                        "`max_discount` DECIMAL(10,2) DEFAULT NULL, " +
                        "`first_order_only` BOOLEAN DEFAULT FALSE, " +
                        "`usage_limit` INT DEFAULT 0, " +
                        "`uses` INT DEFAULT 0, " +
                        "`active` BOOLEAN DEFAULT TRUE, " +
                        "`expires_at` TIMESTAMP NULL DEFAULT NULL, " +
                        "`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
                    );

                    stmt.executeUpdate(
                        "CREATE TABLE IF NOT EXISTS `coupon_usage` (" +
                        "`id` INT NOT NULL AUTO_INCREMENT, " +
                        "`code` VARCHAR(100) NOT NULL, " +
                        "`user_id` VARCHAR(255) NOT NULL, " +
                        "`order_id` INT DEFAULT NULL, " +
                        "`used_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                        "PRIMARY KEY (`id`), " +
                        "INDEX (`code`), INDEX (`user_id`)" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
                    );

                    stmt.executeUpdate(
                        "CREATE TABLE IF NOT EXISTS `reward_game_usage` (" +
                        "`user_id` VARCHAR(255) NOT NULL PRIMARY KEY, " +
                        "`spin_used` BOOLEAN DEFAULT FALSE, " +
                        "`card_used` BOOLEAN DEFAULT FALSE, " +
                        "`scratch_used` BOOLEAN DEFAULT FALSE, " +
                        "`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                        "`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
                    );

                    // Seed a welcome coupon for first orders
                    try (java.sql.ResultSet rsC = stmt.executeQuery("SELECT COUNT(*) FROM coupons WHERE code = 'WELCOME10'")) {
                        if (rsC.next() && rsC.getInt(1) == 0) {
                        stmt.executeUpdate("INSERT INTO coupons (code, type, value, max_discount, first_order_only, usage_limit, uses, active) VALUES ('WELCOME10','percent',10.00,200.00,TRUE,1000,0,TRUE)");
                        System.out.println("DBConnect: Seeded coupon WELCOME10 (10% off, first order)");
                        }
                    } catch (Exception ignore) {}

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `payment_verification_log` ("
                        + "`pv_id` INT NOT NULL AUTO_INCREMENT,"
                        + "`o_id` INT NOT NULL,"
                        + "`payment_method` VARCHAR(50) NOT NULL,"
                        + "`transaction_id` VARCHAR(100) DEFAULT NULL,"
                        + "`amount` DECIMAL(10,2) NOT NULL,"
                        + "`status` VARCHAR(50) NOT NULL,"
                        + "`verification_result` JSON DEFAULT NULL,"
                        + "`verified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "`verified_by` VARCHAR(255) DEFAULT NULL,"
                        + "PRIMARY KEY (`pv_id`),"
                        + "FOREIGN KEY (`o_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,"
                        + "INDEX (`o_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS `payments` ("
                        + "`payment_id` VARCHAR(100) NOT NULL PRIMARY KEY,"
                        + "`user_id` VARCHAR(255) NOT NULL,"
                        + "`order_id` INT NOT NULL,"
                        + "`status` VARCHAR(50) NOT NULL,"
                        + "`payment_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                        + "FOREIGN KEY (`order_id`) REFERENCES `orders`(`o_id`) ON DELETE CASCADE,"
                        + "INDEX (`user_id`), INDEX (`order_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

                // Migrate: add profile columns to existing user table if missing (use information_schema checks for compatibility)
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'full_name'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `user` ADD COLUMN `full_name` VARCHAR(255) DEFAULT NULL AFTER `userid`");
                            System.out.println("DBConnect: Added full_name column to user");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add user.full_name column: " + e.getMessage());
                }
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'phone'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `user` ADD COLUMN `phone` VARCHAR(20) DEFAULT NULL AFTER `full_name`");
                            System.out.println("DBConnect: Added phone column to user");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add user.phone column: " + e.getMessage());
                }
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'address'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `user` ADD COLUMN `address` TEXT DEFAULT NULL AFTER `phone`");
                            System.out.println("DBConnect: Added address column to user");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add user.address column: " + e.getMessage());
                }
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'membership'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `user` ADD COLUMN `membership` VARCHAR(20) DEFAULT 'Standard' AFTER `address`");
                            System.out.println("DBConnect: Added membership column to user");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add user.membership column: " + e.getMessage());
                }
                // Ensure user.password column exists for optional password login
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'password'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `user` ADD COLUMN `password` VARCHAR(255) DEFAULT NULL AFTER `otp_generated_at`");
                            System.out.println("DBConnect: Added password column to user (nullable)");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add user.password column: " + e.getMessage());
                }
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'otp_generated_at'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `user` ADD COLUMN `otp_generated_at` TIMESTAMP NULL DEFAULT NULL AFTER `otp`");
                            System.out.println("DBConnect: Added otp_generated_at column to user");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not ensure user.otp_generated_at column: " + e.getMessage());
                }

                // Ensure orders.created_at and orders.updated_at exist (migration for older schemas)
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'orders' AND column_name = 'created_at'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `approval_notes`");
                            System.out.println("DBConnect: Added created_at column to orders");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add orders.created_at column: " + e.getMessage());
                }

                try {
                    try (java.sql.ResultSet rsCol2 = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'orders' AND column_name = 'updated_at'")) {
                        if (rsCol2.next() && rsCol2.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `created_at`");
                            System.out.println("DBConnect: Added updated_at column to orders");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not add orders.updated_at column: " + e.getMessage());
                }

                // Migrate: ensure cart table has user_id column
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'cart' AND column_name = 'user_id'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `cart` ADD COLUMN `user_id` VARCHAR(255) DEFAULT '' AFTER `c_id`");
                            System.out.println("DBConnect: Added user_id column to cart");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not ensure cart.user_id column: " + e.getMessage());
                }

                // Migrate: ensure wishlist table has user_id column
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'wishlist' AND column_name = 'user_id'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `wishlist` ADD COLUMN `user_id` VARCHAR(255) DEFAULT '' AFTER `p_id`");
                            System.out.println("DBConnect: Added user_id column to wishlist");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not ensure wishlist.user_id column: " + e.getMessage());
                }

                // Migrate: ensure orders table has user_id column
                try {
                    try (java.sql.ResultSet rsCol = stmt.executeQuery(
                            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'orders' AND column_name = 'user_id'")) {
                        if (rsCol.next() && rsCol.getInt(1) == 0) {
                            stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `user_id` VARCHAR(255) DEFAULT '' AFTER `o_id`");
                            System.out.println("DBConnect: Added user_id column to orders");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("DBConnect: Could not ensure orders.user_id column: " + e.getMessage());
                }

                try { stmt.executeUpdate("ALTER TABLE `orders` MODIFY COLUMN `status` ENUM('pending','confirmed','shipped','delivered','cancelled','out_of_stock') DEFAULT 'pending'"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `shipping_pincode` VARCHAR(20) DEFAULT NULL AFTER `shipping_address`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `location_verified` BOOLEAN DEFAULT FALSE AFTER `shipping_pincode`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `payment_status` ENUM('pending','completed','failed','refunded') DEFAULT 'pending' AFTER `payment_method`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `payment_id` VARCHAR(100) DEFAULT NULL AFTER `payment_status`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `payment_date` TIMESTAMP NULL DEFAULT NULL AFTER `payment_id`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `address_verified` BOOLEAN DEFAULT FALSE AFTER `shipping_address`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `verified_at` TIMESTAMP NULL DEFAULT NULL AFTER `address_verified`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `verified_by` VARCHAR(255) DEFAULT NULL AFTER `verified_at`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `admin_approval_date` TIMESTAMP NULL DEFAULT NULL AFTER `verified_by`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `approval_status` ENUM('pending_review','approved','rejected','payment_verification_failed') DEFAULT 'pending_review' AFTER `admin_approval_date`"); } catch (Exception ignore) {}
                try { stmt.executeUpdate("ALTER TABLE `orders` ADD COLUMN `approval_notes` TEXT DEFAULT NULL AFTER `approval_status`"); } catch (Exception ignore) {}

                // Seed default products if the products table is empty
                try (java.sql.ResultSet rsProd = stmt.executeQuery("SELECT COUNT(*) FROM products")) {
                    if (rsProd.next() && rsProd.getInt(1) == 0) {
                        stmt.executeUpdate("INSERT INTO products (p_name, p_category, p_price, p_image, p_desc) VALUES "
                            + "('Sapphire Silk Saree', 'Saree', 2499.00, 'saree_1.jpeg', 'Luxurious sapphire blue silk saree with golden zari border.'),"
                            + "('Morning Blossom Kurti', 'Kurti', 899.00, 'kurti_1.jpeg', 'Comfortable cotton kurti with floral embroidery.'),"
                            + "('Velvet Party Lehenga', 'Lehenga', 4999.00, 'lehenga_1.jpeg', 'Rich velvet lehenga set with elegant mirror work.'),"
                            + "('Emerald Anarkali', 'Suit', 1799.00, 'indo_western.jpeg', 'Premium emerald green anarkali with sequin accents.'),"
                            + "('Churidar Set', 'Churidar', 1299.00, 'churidar_1.jpeg', 'Elegant churidar set for traditional occasions.'),"
                            + "('Party Lehenga', 'Lehenga', 3999.00, 'lehenga_2.jpeg', 'Stunning party lehenga with intricate embroidery.'),"
                            + "('Casual Kurti', 'Kurti', 699.00, 'kurti_2.jpeg', 'Simple and stylish kurti for daily wear.'),"
                            + "('Indo Western Dress', 'Suit', 2199.00, 'indowestern_2.jpeg', 'Modern indo-western fusion dress.'),"
                            + "('Bridal Lehenga', 'Lehenga', 7999.00, 'lehenga_3.jpeg', 'Exquisite bridal lehenga with heavy work.'),"
                            + "('Orange Saree', 'Saree', 1899.00, 'orange.jpeg', 'Vibrant orange saree perfect for festivals.'),"
                            + "('Purple Suit', 'Suit', 1599.00, 'puple_1.jpeg', 'Royal purple suit with delicate patterns.'),"
                            + "('Designer Saree', 'Saree', 3499.00, 'saree_2.jpeg', 'Designer saree with contemporary design.'),"
                            + "('Traditional Lehenga', 'Lehenga', 2999.00, 'lehenga_4.jpeg', 'Traditional lehenga for cultural events.'),"
                            + "('Churidar Outfit', 'Churidar', 1099.00, 'churidar_2.jpeg', 'Comfortable churidar outfit for all day wear.'),"
                            + "('Indo Western Style', 'Suit', 2399.00, 'indowestern_3.jpeg', 'Trendy indo-western style outfit.'),"
                            + "('Silk Saree', 'Saree', 2799.00, 'saree_3.jpeg', 'Pure silk saree with rich texture.'),"
                            + "('Festive Saree', 'Saree', 3199.00, 'Saree_4.jpeg', 'Festive saree with golden motifs.'),"
                            + "('Elegant Saree', 'Saree', 2599.00, 'saree_6.jpeg', 'Elegant saree for special occasions.'),"
                            + "('Classic Saree', 'Saree', 2299.00, 'saree_8.jpeg', 'Classic saree with timeless appeal.')");
                        System.out.println("DBConnect: Seeded 19 default products.");
                    }
                }

                schemaInitialized = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}