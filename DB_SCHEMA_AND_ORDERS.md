Orders feature — DB schema and setup

1) SQL to create a minimal `orders` table used by the new Orders feature:

```sql
CREATE TABLE IF NOT EXISTS orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  userid VARCHAR(255) NOT NULL,
  products_summary TEXT,
  status VARCHAR(64) DEFAULT 'Placed',
  total DECIMAL(10,2) DEFAULT 0,
  placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

2) Example row insertion (for testing):

```sql
INSERT INTO orders (userid, products_summary, status, total) VALUES
('testuser@example.com', '1x Embroidered Kurti; 1x Silk Saree', 'Placed', 4798.00),
('testuser@example.com', '1x Lehenga Set', 'Shipped', 4999.00),
('someone@domain.com', '1x Designer Kurti', 'Out for Delivery', 1599.00);
```

3) How it works
- `OrdersServlet` (GET /OrdersServlet) loads rows from `orders` for the logged-in `session.user` and forwards to `orders.jsp`.
- `orders.jsp` displays order metadata, product summary, status, and a Cancel button when cancellation is allowed.
- `CancelOrderServlet` (POST /CancelOrderServlet) sets `status = 'Cancelled'` only when current status is not shipped/out for/delivered/cancelled.

4) Testing locally
- Ensure your DB credentials are configured (use environment variables or system properties as `DBConnect` supports).
- Create the `orders` table and insert test rows. Log in as a user matching the `userid` used in test rows.
- Visit the `Orders` link in the header (orders.jsp). Try cancelling an order with status `Placed` and confirm the status updates to `Cancelled`.

5) Next improvements (optional)
- Add an `order_items` table to store structured item rows and join product images/titles dynamically.
- Emit email notifications on cancellations and status changes.
- Add pagination, filtering and order detail pages.

6) `order_items` table schema (recommended)

```sql
CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  p_id INT NOT NULL,
  quantity INT DEFAULT 1,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (p_id) REFERENCES products(p_id) ON DELETE SET NULL
);
```

After creating `order_items`, populate it with product IDs and quantities for existing orders and remove `products_summary` usage.
