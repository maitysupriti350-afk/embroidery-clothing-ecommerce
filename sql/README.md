# SQL Scripts for ClothingStore_Final

This folder contains the SQL files needed to set up the MySQL database used by the project.

## Files

- `schema.sql` - creates the `clothingstore` database and required tables:
  - `user` (for OTP login)
  - `products` (product catalog)
  - `cart` (user shopping carts)
  - `wishlist` (user wishlists)
  - `orders` (order records)
  - `order_items` (order line items)

- `sample-data.sql` - inserts sample products and a placeholder user for testing.

## Usage

1. Start your MySQL server.
2. Run `schema.sql` first.
3. Run `sample-data.sql` to populate sample products.

Example:

```sql
SOURCE /path/to/ClothingStore_Final/sql/schema.sql;
SOURCE /path/to/ClothingStore_Final/sql/sample-data.sql;
```

Make sure the project is configured to use `jdbc:mysql://localhost:3306/clothingstore` or update `DBConnect.java` if your connection differs.

## New Features

### Search & Filter
- Search products by name or description
- Filter by category (Saree, Kurti, Lehenga, Suit, Churidar)

### Order Management
- Place orders from cart
- View order history with status tracking
- Order statuses: pending, confirmed, shipped, delivered, cancelled

### Enhanced User Experience
- Checkout process with shipping address
- Multiple payment methods (COD, Card, UPI)
- Order confirmation with order ID

## Admin Setup

To access the admin panel:
- Log in with the admin email (default: `admin@example.com`)
- Or set the `ADMIN_USER` environment variable or `admin.email` system property to your desired admin email.

Admin features:
- View all products in `adminDashboard.jsp`
- Add new products via `addproduct.jsp`
- Edit existing products via `editProduct.jsp`
- Delete products from the admin dashboard

## Environment Variables

Set these environment variables for the application to work:

- `CLOTHING_DB_USER=root` (or your MySQL username)
- `CLOTHING_DB_PASS=your_mysql_password`
- `EMAIL_USER=your_gmail@gmail.com`
- `EMAIL_PASS=your_gmail_app_password`
- `ADMIN_USER=admin@example.com` (optional, for admin access)

## Build System

The project now includes a `pom.xml` for Maven builds. To build:

```bash
mvn clean compile
mvn package  # creates WAR file
```

For manual compilation (current setup):
```bash
javac -cp "lib/*" -d build/classes src/main/java/**/*.java
```

On Windows, set them in System Properties > Environment Variables, or use `setx` command.

## Database Setup

1. Install MySQL if not already installed.
2. Start MySQL service.
3. Run the SQL scripts:
   - `mysql -u root -p < sql/schema.sql`
   - `mysql -u root -p < sql/sample-data.sql`

Replace `root` with your MySQL username if different.

## Troubleshooting

- If JSP pages don't load, restart Tomcat after compiling classes.
- If login fails, check email credentials and MySQL connection.
- If admin panel doesn't show, ensure you're logged in with the admin email.
- If images don't load, ensure `product_img/` folder is accessible and paths match.
