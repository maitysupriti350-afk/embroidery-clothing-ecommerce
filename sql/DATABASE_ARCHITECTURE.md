# THE GILDED STITCH - Database Architecture Documentation

## Overview
This document describes the database architecture for THE GILDED STITCH ecommerce platform. The database is designed to support user management, product catalog, shopping cart, order processing, payment tracking, and customer loyalty features.

## Database Information
- **Database Name**: `clothingstore`
- **Character Set**: utf8mb4
- **Collation**: utf8mb4_unicode_ci
- **Engine**: InnoDB (for transaction support and foreign key constraints)

## Core Tables

### 1. User Table (`user`)
Stores customer and admin user information with role-based access control.

| Column | Type | Description |
|--------|------|-------------|
| `userid` | VARCHAR(255) | Primary key, user's email address |
| `full_name` | VARCHAR(255) | User's full name |
| `phone` | VARCHAR(20) | Contact phone number |
| `address` | TEXT | User's address |
| `membership` | VARCHAR(20) | Membership tier (Standard, Gold, Platinum) |
| `otp` | VARCHAR(6) | One-time password for login |
| `password_hash` | VARCHAR(255) | Hashed password using BCrypt |
| `role` | ENUM('customer', 'admin') | User role for access control |
| `is_active` | BOOLEAN | Account status (active/inactive) |
| `last_login` | TIMESTAMP | Last successful login timestamp |
| `created_at` | TIMESTAMP | Account creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**Indexes**:
- PRIMARY KEY on `userid`
- INDEX on `role`
- INDEX on `is_active`

**Security Features**:
- Passwords are hashed using BCrypt (not stored in plain text)
- Role-based access control (customer vs admin)
- Account activation/deactivation capability
- OTP-based authentication support

### 2. Products Table (`products`)
Catalog of all available products with inventory management.

| Column | Type | Description |
|--------|------|-------------|
| `p_id` | INT | Primary key, auto-increment |
| `p_name` | VARCHAR(255) | Product name |
| `p_category` | VARCHAR(100) | Product category (Saree, Kurti, Lehenga, Suit, Churidar) |
| `p_price` | DECIMAL(10,2) | Product price |
| `p_image` | VARCHAR(255) | Product image filename |
| `p_desc` | TEXT | Product description |
| `stock_quantity` | INT | Available stock quantity |
| `reorder_level` | INT | Minimum stock level for reordering |
| `is_active` | BOOLEAN | Product availability status |
| `sku` | VARCHAR(50) | Unique Stock Keeping Unit |
| `weight` | DECIMAL(6,2) | Product weight in kg |
| `brand` | VARCHAR(100) | Product brand |
| `material` | VARCHAR(100) | Product material/fabric |
| `color` | VARCHAR(50) | Product color |
| `created_at` | TIMESTAMP | Product creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**Indexes**:
- PRIMARY KEY on `p_id`
- INDEX on `p_category`
- INDEX on `is_active`
- INDEX on `sku`

**Inventory Management**:
- Stock quantity tracking
- Reorder level alerts
- Product activation/deactivation
- SKU for inventory tracking

### 3. Cart Table (`cart`)
Shopping cart contents per user.

| Column | Type | Description |
|--------|------|-------------|
| `c_id` | INT | Primary key, auto-increment |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `p_id` | INT | Foreign key to products table |
| `p_name` | VARCHAR(255) | Product name (denormalized) |
| `p_price` | DECIMAL(10,2) | Product price at time of adding |
| `p_image` | VARCHAR(255) | Product image (denormalized) |
| `size` | VARCHAR(10) | Selected size (S, M, L, XL) |
| `quantity` | INT | Quantity in cart |
| `added_at` | TIMESTAMP | When item was added to cart |
| `created_at` | TIMESTAMP | Cart creation timestamp |

**Foreign Keys**:
- `user_id` → `user.userid` (CASCADE DELETE)
- `p_id` → `products.p_id` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `c_id`
- INDEX on `user_id`

### 4. Orders Table (`orders`)
Customer orders with comprehensive tracking.

| Column | Type | Description |
|--------|------|-------------|
| `o_id` | INT | Primary key, auto-increment |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `total_amount` | DECIMAL(10,2) | Total order amount |
| `status` | ENUM | Order status (pending, confirmed, shipped, delivered, cancelled, out_of_stock) |
| `shipping_address` | TEXT | Delivery address |
| `payment_method` | VARCHAR(50) | Payment method (UPI, Card, Wallet, COD) |
| `payment_status` | ENUM | Payment status (pending, completed, failed, refunded) |
| `payment_id` | VARCHAR(100) | Payment transaction ID |
| `payment_date` | TIMESTAMP | Payment completion date |
| `address_verified` | BOOLEAN | Address verification status |
| `verified_at` | TIMESTAMP | Address verification timestamp |
| `verified_by` | VARCHAR(255) | Who verified the address |
| `admin_approval_date` | TIMESTAMP | Admin approval timestamp |
| `approval_status` | ENUM | Approval status (pending_review, approved, rejected, payment_verification_failed) |
| `approval_notes` | TEXT | Admin approval notes |
| `created_at` | TIMESTAMP | Order creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `user_id` → `user.userid` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `o_id`
- INDEX on `user_id`

### 5. Order Items Table (`order_items`)
Individual items within an order.

| Column | Type | Description |
|--------|------|-------------|
| `oi_id` | INT | Primary key, auto-increment |
| `o_id` | INT | Foreign key to orders table |
| `p_id` | INT | Foreign key to products table |
| `p_name` | VARCHAR(255) | Product name (denormalized) |
| `p_price` | DECIMAL(10,2) | Product price at time of order |
| `p_image` | VARCHAR(255) | Product image (denormalized) |
| `size` | VARCHAR(10) | Selected size |
| `quantity` | INT | Quantity ordered |
| `subtotal` | DECIMAL(10,2) | Line item subtotal |

**Foreign Keys**:
- `o_id` → `orders.o_id` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `oi_id`
- INDEX on `o_id`

## Additional Tables

### 6. Wishlist Table (`wishlist`)
Saved favorite products per user.

| Column | Type | Description |
|--------|------|-------------|
| `w_id` | INT | Primary key, auto-increment |
| `p_id` | INT | Foreign key to products table |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `added_at` | TIMESTAMP | When item was added |

**Indexes**:
- PRIMARY KEY on `w_id`
- UNIQUE KEY on (`p_id`, `user_id`)

### 7. Guest Orders Table (`guest_orders`)
Guest checkout functionality.

| Column | Type | Description |
|--------|------|-------------|
| `guest_id` | INT | Primary key, auto-increment |
| `guest_email` | VARCHAR(255) | Guest email address |
| `guest_name` | VARCHAR(255) | Guest full name |
| `guest_phone` | VARCHAR(20) | Guest phone number |
| `o_id` | INT | Foreign key to orders table |
| `created_at` | TIMESTAMP | Guest order creation timestamp |

**Foreign Keys**:
- `o_id` → `orders.o_id` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `guest_id`
- UNIQUE KEY on (`guest_email`, `o_id`)

### 8. Product Reviews Table (`product_reviews`)
Customer feedback and ratings.

| Column | Type | Description |
|--------|------|-------------|
| `review_id` | INT | Primary key, auto-increment |
| `p_id` | INT | Foreign key to products table |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `rating` | TINYINT | Rating (1-5 stars) |
| `review_text` | TEXT | Review content |
| `is_verified_purchase` | BOOLEAN | Verified purchase indicator |
| `is_approved` | BOOLEAN | Review approval status |
| `helpful_count` | INT | Number of helpful votes |
| `created_at` | TIMESTAMP | Review creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `p_id` → `products.p_id` (CASCADE DELETE)
- `user_id` → `user.userid` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `review_id`
- INDEX on `p_id`
- INDEX on `user_id`
- INDEX on `rating`

### 9. Coupons Table (`coupons`)
Promotional discount codes.

| Column | Type | Description |
|--------|------|-------------|
| `coupon_id` | INT | Primary key, auto-increment |
| `coupon_code` | VARCHAR(50) | Unique coupon code |
| `discount_type` | ENUM | Discount type (percentage, fixed) |
| `discount_value` | DECIMAL(10,2) | Discount amount |
| `min_order_value` | DECIMAL(10,2) | Minimum order value |
| `max_discount` | DECIMAL(10,2) | Maximum discount cap |
| `usage_limit` | INT | Total usage limit |
| `used_count` | INT | Current usage count |
| `valid_from` | TIMESTAMP | Valid from date |
| `valid_until` | TIMESTAMP | Valid until date |
| `is_active` | BOOLEAN | Coupon active status |
| `description` | TEXT | Coupon description |
| `created_at` | TIMESTAMP | Coupon creation timestamp |

**Indexes**:
- PRIMARY KEY on `coupon_id`
- UNIQUE KEY on `coupon_code`
- INDEX on `is_active`, `valid_from`, `valid_until`

### 10. User Coupons Table (`user_coupons`)
Track coupon usage per user.

| Column | Type | Description |
|--------|------|-------------|
| `uc_id` | INT | Primary key, auto-increment |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `coupon_id` | INT | Foreign key to coupons table |
| `order_id` | INT | Foreign key to orders table |
| `discount_applied` | DECIMAL(10,2) | Discount amount applied |
| `used_at` | TIMESTAMP | When coupon was used |

**Foreign Keys**:
- `user_id` → `user.userid` (CASCADE DELETE)
- `coupon_id` → `coupons.coupon_id` (CASCADE DELETE)
- `order_id` → `orders.o_id` (SET NULL)

**Indexes**:
- PRIMARY KEY on `uc_id`
- INDEX on `user_id`

### 11. Reward Points Table (`reward_points`)
Customer loyalty program points.

| Column | Type | Description |
|--------|------|-------------|
| `rp_id` | INT | Primary key, auto-increment |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `points_earned` | INT | Total points earned |
| `points_redeemed` | INT | Total points redeemed |
| `points_balance` | INT | Current point balance |
| `last_earned_at` | TIMESTAMP | Last points earned timestamp |
| `last_redeemed_at` | TIMESTAMP | Last points redeemed timestamp |
| `created_at` | TIMESTAMP | Account creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `user_id` → `user.userid` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `rp_id`
- UNIQUE KEY on `user_id`

### 12. Reward Transactions Table (`reward_transactions`)
Track point changes over time.

| Column | Type | Description |
|--------|------|-------------|
| `rt_id` | INT | Primary key, auto-increment |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `transaction_type` | ENUM | Transaction type (earned, redeemed, expired, adjusted) |
| `points` | INT | Points changed |
| `balance_after` | INT | Balance after transaction |
| `description` | VARCHAR(255) | Transaction description |
| `reference_id` | VARCHAR(100) | Order ID or other reference |
| `created_at` | TIMESTAMP | Transaction timestamp |

**Foreign Keys**:
- `user_id` → `user.userid` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `rt_id`
- INDEX on `user_id`
- INDEX on `transaction_type`

### 13. Shipping Addresses Table (`shipping_addresses`)
Multiple addresses per user.

| Column | Type | Description |
|--------|------|-------------|
| `address_id` | INT | Primary key, auto-increment |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `address_type` | ENUM | Address type (home, office, other) |
| `full_name` | VARCHAR(255) | Recipient name |
| `phone` | VARCHAR(20) | Recipient phone |
| `address_line1` | VARCHAR(255) | Address line 1 |
| `address_line2` | VARCHAR(255) | Address line 2 |
| `city` | VARCHAR(100) | City |
| `state` | VARCHAR(100) | State |
| `pincode` | VARCHAR(10) | Postal code |
| `is_default` | BOOLEAN | Default address indicator |
| `created_at` | TIMESTAMP | Address creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

**Foreign Keys**:
- `user_id` → `user.userid` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `address_id`
- INDEX on `user_id`

## Supporting Tables

### 14. Order Notifications Table (`order_notifications`)
Notifications for order workflow.

| Column | Type | Description |
|--------|------|-------------|
| `notif_id` | INT | Primary key, auto-increment |
| `o_id` | INT | Foreign key to orders table |
| `user_id` | VARCHAR(255) | Foreign key to user table |
| `notification_type` | ENUM | Notification type |
| `message` | TEXT | Notification message |
| `is_read` | BOOLEAN | Read status |
| `created_at` | TIMESTAMP | Notification timestamp |

**Foreign Keys**:
- `o_id` → `orders.o_id` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `notif_id`
- INDEX on `user_id`
- INDEX on `created_at`

### 15. Payment Verification Log Table (`payment_verification_log`)
Payment verification tracking.

| Column | Type | Description |
|--------|------|-------------|
| `pv_id` | INT | Primary key, auto-increment |
| `o_id` | INT | Foreign key to orders table |
| `payment_method` | VARCHAR(50) | Payment method used |
| `transaction_id` | VARCHAR(100) | Transaction ID |
| `amount` | DECIMAL(10,2) | Payment amount |
| `status` | VARCHAR(50) | Verification status |
| `verification_result` | JSON | Detailed verification result |
| `verified_at` | TIMESTAMP | Verification timestamp |
| `verified_by` | VARCHAR(255) | Who verified |

**Foreign Keys**:
- `o_id` → `orders.o_id` (CASCADE DELETE)

**Indexes**:
- PRIMARY KEY on `pv_id`
- INDEX on `o_id`

## Key Relationships

### User-Product Relationships
- **User → Cart**: One-to-many (user can have multiple cart items)
- **User → Wishlist**: One-to-many (user can have multiple wishlist items)
- **User → Orders**: One-to-many (user can place multiple orders)
- **User → Reviews**: One-to-many (user can write multiple reviews)
- **User → Addresses**: One-to-many (user can have multiple addresses)

### Product-Order Relationships
- **Product → Cart Items**: One-to-many (product can be in multiple carts)
- **Product → Order Items**: One-to-many (product can be in multiple orders)
- **Product → Reviews**: One-to-many (product can have multiple reviews)

### Order-Item Relationships
- **Order → Order Items**: One-to-many (order contains multiple items)
- **Order → Guest Order**: One-to-one (order can have one guest record)

## Security Features

1. **Password Hashing**: Passwords are stored as BCrypt hashes, never in plain text
2. **Role-Based Access Control**: Users have roles (customer/admin) for access control
3. **Foreign Key Constraints**: Referential integrity maintained through foreign keys
4. **Cascade Deletes**: Automatic cleanup of related records when parent is deleted
5. **Account Activation**: User accounts can be activated/deactivated
6. **OTP Authentication**: Support for OTP-based login system

## Performance Optimizations

1. **Indexes**: Strategic indexes on frequently queried columns
2. **Foreign Keys**: Proper indexing on foreign key columns
3. **Denormalization**: Product details stored in cart/orders for performance
4. **Timestamp Tracking**: Created/updated timestamps for audit trails
5. **Unique Constraints**: Prevent duplicate entries (wishlist, coupons)

## Data Integrity

1. **ENUM Types**: Restricted values for status fields
2. **CHECK Constraints**: Rating values between 1-5
3. **NOT NULL Constraints**: Required fields enforced
4. **DEFAULT Values**: Sensible defaults for optional fields
5. **CASCADE Operations**: Automatic cleanup of orphaned records

## Migration Instructions

To apply the enhanced schema:

1. Run the base schema: `sql/schema.sql`
2. Run the enhancement script: `sql/enhance-schema.sql`
3. Load sample data: `sql/sample-data.sql`

The enhancement script is designed to be idempotent and can be run multiple times safely.

## Backup Recommendations

1. **Regular Backups**: Daily automated backups
2. **Point-in-Time Recovery**: Enable binary logging
3. **Backup Testing**: Regular restore testing
4. **Off-site Storage**: Store backups in multiple locations
5. **Retention Policy**: Keep backups for at least 30 days

## Monitoring & Maintenance

1. **Slow Query Log**: Monitor and optimize slow queries
2. **Index Usage**: Review index usage statistics
3. **Table Size**: Monitor table growth and archive old data
4. **Connection Pooling**: Use connection pooling for better performance
5. **Query Optimization**: Regular query performance analysis

## Future Enhancements

Potential future additions:
- Product variants (size, color combinations)
- Product categories hierarchy
- Tax calculation tables
- Shipping zone tables
- Return/refund tracking
- Customer segmentation tables
- A/B testing tables
- Analytics tracking tables
