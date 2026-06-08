<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.conn.DBConnect, java.math.BigDecimal" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>My Cart - THE GILDED STITCH</title>
    <style>
        body { background: #fff0f6; font-family: 'Poppins', sans-serif; margin: 0; padding: 20px; color: #3d1729; }
        .cart-container { width: 85%; max-width: 1000px; margin: auto; padding-top: 30px; }
        h2 { text-align: center; color: #381a2d; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 16px; border-bottom: 1px solid #f3d7e3; text-align: left; vertical-align: middle; }
        th { background-color: #ff9ac2; color: white; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        .cart-product-img { width: 90px; height: 90px; object-fit: cover; border-radius: 8px; transition: transform 0.3s ease; }
        .cart-product-img:hover { transform: scale(1.05); }
        .total-row { font-weight: bold; background-color: #fff4fb; }
        .qty-control { display: inline-flex; align-items: center; gap: 0; }
        .qty-btn {
            width: 30px; height: 30px; border: 1px solid #f4d0df; background: #fff5fb;
            cursor: pointer; font-size: 16px; font-weight: bold; color: #3d1729;
            display: flex; align-items: center; justify-content: center;
        }
        .qty-btn:hover { background: #ffe4f1; }
        .qty-value { width: 40px; height: 30px; text-align: center; border: 1px solid #f4d0df;
            border-left: none; border-right: none; font-size: 14px; font-weight: 600; line-height: 30px; background: white; }
        .remove-link { color: #d73a78; text-decoration: none; font-size: 13px; font-weight: 600; }
        .remove-link:hover { text-decoration: underline; }
        .cart-actions { display: flex; justify-content: center; gap: 15px; margin-top: 25px; flex-wrap: wrap; }
        .cart-actions a { padding: 12px 30px; border-radius: 5px; font-weight: bold; text-decoration: none; font-size: 14px; }
        .btn-checkout { background: #ff8fb8; color: white; }
        .btn-checkout:hover { background: #ff5da3; }
        .btn-continue { background: #7b2c4e; color: white; }
        .btn-continue:hover { background: #6a2342; }
        .empty-cart { text-align: center; padding: 60px 20px; color: #8b3a5d; }
        .empty-cart i { font-size: 48px; margin-bottom: 16px; display: block; color: #d89ab4; }
        .msg-bar { margin-bottom: 16px; padding: 12px 16px; border-radius: 8px; font-size: 14px; }
        .msg-success { background: #ffe4f0; color: #6a1d3f; }
        .msg-error { background: #ffd8df; color: #9f1d2d; }

        /* Mobile Responsive Styles */
        @media (max-width: 768px) {
            body {
                padding: 0;
            }
            
            .cart-container {
                width: 100%;
                max-width: 100%;
                padding: 16px;
                margin: 0;
            }
            
            h2 {
                font-size: 20px;
                margin-bottom: 16px;
            }
            
            table {
                display: block;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }
            
            table thead {
                display: none;
            }
            
            table tbody tr {
                display: block;
                margin-bottom: 16px;
                border: 1px solid #f3d7e3;
                border-radius: 12px;
                padding: 16px;
                background: white;
            }
            
            table tbody td {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 12px 0;
                border-bottom: 1px solid #f3d7e3;
            }
            
            table tbody td:last-child {
                border-bottom: none;
            }
            
            table tbody td::before {
                content: attr(data-label);
                font-weight: 600;
                color: #6b3a53;
                margin-right: 16px;
                font-size: 13px;
            }
            
            table tbody td img {
                width: 80px;
                height: 80px;
            }
            
            .qty-btn {
                width: 36px;
                height: 36px;
                font-size: 18px;
            }
            
            .qty-value {
                width: 44px;
                height: 36px;
                line-height: 36px;
                font-size: 15px;
            }
            
            .cart-actions {
                flex-direction: column;
                gap: 12px;
                padding: 0 16px 16px;
            }
            
            .cart-actions a {
                width: 100%;
                text-align: center;
                padding: 14px 20px;
                font-size: 15px;
            }
            
            .empty-cart {
                padding: 40px 16px;
            }
            
            .empty-cart i {
                font-size: 40px;
            }
            
            .empty-cart p {
                font-size: 16px;
            }
        }

        @media (max-width: 480px) {
            .cart-container {
                padding: 12px;
            }
            
            h2 {
                font-size: 18px;
            }
            
            table tbody tr {
                padding: 12px;
            }
            
            table tbody td {
                font-size: 13px;
            }
            
            table tbody td::before {
                font-size: 12px;
            }
            
            .qty-btn {
                width: 32px;
                height: 32px;
                font-size: 16px;
            }
            
            .qty-value {
                width: 40px;
                height: 32px;
                line-height: 32px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
%>
<jsp:include page="/common/header.jsp" />
    <div class="cart-container">
        <h2>Shopping Cart</h2>

        <% String succMsg = (String) session.getAttribute("succMsg");
           String failMsg = (String) session.getAttribute("failedMsg");
           if (succMsg != null) { %>
        <div class="msg-bar msg-success"><%= succMsg %></div>
        <% session.removeAttribute("succMsg"); }
           if (failMsg != null) { %>
        <div class="msg-bar msg-error"><%= failMsg %></div>
        <% session.removeAttribute("failedMsg"); } %>

        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Name</th>
                    <th>Price</th>
                    <th>Size</th>
                    <th>Quantity</th>
                    <th>Subtotal</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    String userId = session.getAttribute("user").toString();
                    BigDecimal grandTotal = BigDecimal.ZERO;
                    try (Connection conn = DBConnect.getConn()) {
                        boolean retried = false;
                        boolean queryCompleted = false;
                        while (!queryCompleted) {
                            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM cart WHERE user_id = ?")) {
                                ps.setString(1, userId);
                                try (ResultSet rs = ps.executeQuery()) {
                                    boolean hasItems = false;
                                    while(rs.next()) {
                                        hasItems = true;
                                        BigDecimal price = rs.getBigDecimal("p_price");
                                        int qty = rs.getInt("quantity");
                                        int cid = rs.getInt("c_id");
                                        BigDecimal subtotal = price.multiply(BigDecimal.valueOf(qty));
                                        grandTotal = grandTotal.add(subtotal);
                %>
                        <tr>
                            <td data-label="Product">
                                <img src="${pageContext.request.contextPath}/product_img/<%= rs.getString("p_image") %>" alt="<%= rs.getString("p_name") %>" class="cart-product-img" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg';">
                            </td>
                            <td data-label="Name" style="font-weight: 600;"><%= rs.getString("p_name") %></td>
                            <td data-label="Price"><%= String.format("₹%.2f", price) %></td>
                            <td data-label="Size"><%= rs.getString("size") %></td>
                            <td data-label="Quantity">
                                <div class="qty-control">
                                    <form action="${pageContext.request.contextPath}/UpdateCartServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="cid" value="<%= cid %>">
                                        <input type="hidden" name="quantity" value="<%= qty - 1 %>">
                                        <button type="submit" class="qty-btn">-</button>
                                    </form>
                                    <span class="qty-value"><%= qty %></span>
                                    <form action="${pageContext.request.contextPath}/UpdateCartServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="cid" value="<%= cid %>">
                                        <input type="hidden" name="quantity" value="<%= qty + 1 %>">
                                        <button type="submit" class="qty-btn">+</button>
                                    </form>
                                </div>
                            </td>
                            <td data-label="Subtotal" style="font-weight: 600;"><%= String.format("₹%.2f", subtotal) %></td>
                            <td data-label="Action">
                                <a href="${pageContext.request.contextPath}/RemoveCartServlet?cid=<%= cid %>" class="remove-link">Remove</a>
                            </td>
                        </tr>
                <%
                                    }
                                    if (!hasItems) {
                %>
                        <tr>
                            <td colspan="7">
                                <div class="empty-cart">
                                    <i class="fas fa-shopping-cart" style="font-size:48px;color:#cbd5e1;"></i>
                                    <p style="font-size:18px; color:#64748b;">Your cart is empty</p>
                                    <a href="${pageContext.request.contextPath}/collections.jsp" style="color:#ff3f6c; font-weight:600;">Browse Collections</a>
                                </div>
                            </td>
                        </tr>
                <%      } else { %>
                        <tr class="total-row">
                            <td colspan="5" style="text-align: right; font-size: 16px;">Grand Total:</td>
                            <td colspan="2" style="font-size: 16px;"><%= String.format("₹%.2f", grandTotal) %></td>
                        </tr>
                <%      }
                                    queryCompleted = true;
                                }
                            } catch (SQLException sqle) {
                                if (!retried && sqle.getMessage() != null && sqle.getMessage().contains("Unknown column 'user_id'")) {
                                    retried = true;
                                    try (Statement stmt = conn.createStatement()) {
                                        stmt.executeUpdate("ALTER TABLE `cart` ADD COLUMN `user_id` VARCHAR(255) DEFAULT '' AFTER `c_id`");
                                    } catch (Exception e2) {
                                        throw new Exception("Failed to repair cart schema: " + e2.getMessage(), e2);
                                    }
                                } else {
                                    throw sqle;
                                }
                            }
                        }
                    } catch(Exception e) {
                        out.println("<tr><td colspan='7' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        e.printStackTrace();
                    }
                %>
            </tbody>
        </table>
        <div class="cart-actions">
            <a href="${pageContext.request.contextPath}/checkout.jsp" class="btn-checkout">Proceed to Checkout</a>
            <a href="${pageContext.request.contextPath}/collections.jsp" class="btn-continue">Add More Items</a>
        </div>
    </div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
