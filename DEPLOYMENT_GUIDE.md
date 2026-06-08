# Quick Start Deployment Guide

## Step 1: Database Setup

```sql
-- Create database
CREATE DATABASE IF NOT EXISTS clothingstore;
USE clothingstore;

-- Note: Tables will be auto-created by DBConnect.java on first connection
-- No manual schema creation needed!
```

## Step 2: Environment Configuration

### Option A: Environment Variables (Recommended)
```bash
# Database Configuration
export CLOTHING_DB_URL="jdbc:mysql://localhost:3306/clothingstore"
export CLOTHING_DB_USER="root"
export CLOTHING_DB_PASS="admin123"

# Email Configuration
export EMAIL_USER="your-gmail@gmail.com"
export EMAIL_PASS="your-app-password"

# Admin Configuration
export ADMIN_USER="admin@yourdomain.com"
```

### Option B: System Properties (Alternative)
Add to Tomcat `setenv.sh` or `setenv.bat`:
```bash
-Ddb.url=jdbc:mysql://localhost:3306/clothingstore
-Ddb.user=root
-Ddb.pass=admin123
-Demail.user=your-gmail@gmail.com
-Demail.pass=your-app-password
-Dadmin.email=admin@yourdomain.com
```

## Step 3: Compile (Optional - Already Pre-compiled)

If rebuilding from source:
```bash
cd c:\Users\supri\eclipse-workspace\ClothingStore_Final

# Compile Java sources
javac --release 21 -d build/classes src/main/java/com/**/*.java

# Or use Maven if available
mvn clean compile -DskipTests
```

## Step 4: Deploy to Tomcat

### For Development (Eclipse)
1. In Eclipse, right-click project → **Run on Server** → Select Tomcat 9.0.71
2. Application will auto-deploy to `http://localhost:8080/ClothingStore_Final/`

### For Production
```bash
# Build WAR package (if using Maven)
mvn clean package -DskipTests

# OR manually create WAR
# Place entire webapp folder contents in war package

# Deploy to Tomcat
cp target/clothingstore-1.0-SNAPSHOT.war $TOMCAT_HOME/webapps/

# Start Tomcat
$TOMCAT_HOME/bin/startup.sh

# Access at: http://localhost:8080/clothingstore/
```

## Step 5: Initial Testing

1. **Access Login Page:**
   ```
   http://localhost:8080/clothingstore/
   ```

2. **Test User Registration:**
   - Email: `testuser@example.com`
   - OTP will be sent to email (check spam folder)
   - Enter 6-digit OTP
   - Should redirect to dashboard

3. **Test Admin Access:**
   - Login with admin email (configured in ADMIN_USER env var)
   - Admin Dashboard link should appear
   - Can add/edit/delete products

4. **Test Shopping Flow:**
   - Browse Collections → Search/Filter products
   - Add product to Cart (select size & qty)
   - Add product to Wishlist (heart icon)
   - Checkout → Place Order
   - View Orders page

## Step 6: Populate Sample Data

### Add Sample Products (via Admin Panel)

After logging in as admin, go to **Admin Panel** → **Add New Product**

```
Product 1:
- Name: Red Silk Saree
- Category: Saree
- Price: 2500
- Description: Traditional red silk saree with temple border
- Image: red_saree.jpg

Product 2:
- Name: Blue Kurti
- Category: Kurti
- Price: 1200
- Description: Casual blue kurti with embroidery
- Image: blue_kurti.jpg

Product 3:
- Name: Lehenga Choli Set
- Category: Lehenga
- Price: 4500
- Description: Bridal lehenga set with heavy embroidery
- Image: lehenga.jpg
```

Place product images in: `src/main/webapp/product_img/`

## Troubleshooting

### Issue: "Access denied for user 'root'"
**Solution:** Set correct MySQL credentials
```bash
export CLOTHING_DB_USER="your_mysql_user"
export CLOTHING_DB_PASS="your_mysql_password"
```

### Issue: "Failed to send OTP email"
**Steps to fix:**
1. Verify Gmail app password (not regular password)
   - Go to: https://myaccount.google.com/apppasswords
   - Create new app password for "Mail"
2. Set environment variable:
   ```bash
   export EMAIL_USER="your-email@gmail.com"
   export EMAIL_PASS="generated-app-password"
   ```

### Issue: "UnsupportedClassVersionError"
**Solution:** Ensure Java 21+ and Tomcat 9.0.71+
```bash
java -version  # Should show Java 21+
```

### Issue: Static assets (CSS, images) not loading
**Solution:** Ensure context path is correctly set in JSP pages
- All paths use: `${pageContext.request.contextPath}/css/common.css`
- Verify CSS and product images exist in webapp folder

### Issue: Products not appearing
**Solution:** 
1. Check if admin has added products via Admin Panel
2. Verify database "clothingstore" exists
3. Check `products` table is populated
   ```sql
   SELECT * FROM products;
   ```

## Database Schema (Auto-Created)

```sql
-- Users Table
CREATE TABLE user (
  userid VARCHAR(255) PRIMARY KEY,
  otp VARCHAR(6),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE products (
  p_id INT AUTO_INCREMENT PRIMARY KEY,
  p_name VARCHAR(255),
  p_category VARCHAR(100),
  p_price DECIMAL(10,2),
  p_image VARCHAR(255),
  p_desc TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cart Table
CREATE TABLE cart (
  c_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(255),
  p_id INT,
  p_name VARCHAR(255),
  p_price DECIMAL(10,2),
  p_image VARCHAR(255),
  size VARCHAR(10),
  quantity INT DEFAULT 1,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY (user_id)
);

-- Wishlist Table
CREATE TABLE wishlist (
  w_id INT AUTO_INCREMENT PRIMARY KEY,
  p_id INT,
  user_id VARCHAR(255),
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY (p_id, user_id)
);

-- Orders Table
CREATE TABLE orders (
  o_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(255),
  total_amount DECIMAL(10,2),
  status ENUM('pending','confirmed','shipped','delivered','cancelled') DEFAULT 'pending',
  shipping_address TEXT,
  payment_method VARCHAR(50) DEFAULT 'COD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY (user_id)
);

-- Order Items Table
CREATE TABLE order_items (
  oi_id INT AUTO_INCREMENT PRIMARY KEY,
  o_id INT,
  p_id INT,
  p_name VARCHAR(255),
  p_price DECIMAL(10,2),
  p_image VARCHAR(255),
  size VARCHAR(10),
  quantity INT,
  subtotal DECIMAL(10,2),
  FOREIGN KEY (o_id) REFERENCES orders(o_id) ON DELETE CASCADE,
  KEY (o_id)
);
```

## Performance Tips

1. **Enable Database Query Caching** (MySQL):
   ```sql
   SET GLOBAL query_cache_size = 134217728; -- 128MB
   SET GLOBAL query_cache_type = 1;
   ```

2. **Add Database Indexes**:
   ```sql
   CREATE INDEX idx_user_id ON cart(user_id);
   CREATE INDEX idx_user_id ON wishlist(user_id);
   CREATE INDEX idx_user_id ON orders(user_id);
   ```

3. **Connection Pool Size** (Tomcat context.xml):
   ```xml
   <Resource name="jdbc/clothingstore"
     auth="Container"
     type="javax.sql.DataSource"
     maxTotal="20"
     maxIdle="10"
     minIdle="5"
     url="jdbc:mysql://localhost:3306/clothingstore"
     username="root"
     password="admin123"
     driverClassName="com.mysql.cj.jdbc.Driver" />
   ```

## Support Files Included

- **PROJECT_VERIFICATION.md** - Complete audit report
- **DEPLOYMENT_GUIDE.md** - This file
- **sql/schema.sql** - Manual schema creation (optional)
- **pom.xml** - Maven build configuration
- **WEB-INF/web.xml** - Servlet configuration

---

**Ready to go live!** 🚀

For issues, check console logs:
- Tomcat: `$TOMCAT_HOME/logs/catalina.out`
- MySQL: Check MySQL error log
