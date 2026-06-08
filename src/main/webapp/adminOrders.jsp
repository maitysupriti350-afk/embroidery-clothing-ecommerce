<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    if (!isAdmin) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    request.setAttribute("adminActivePage", "orders");
    request.setAttribute("adminPageTitle", "Order Management");

    String filterStatus = request.getParameter("status");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Orders - Admin Panel</title>
<jsp:include page="/common/admin-style.jsp" />
<style>
    .filter-bar { display: flex; gap: 8px; flex-wrap: wrap; }
    .filter-btn { padding: 6px 16px; border-radius: 20px; border: 1px solid #e5e7eb; background: white; color: #64748b; font-size: 13px; cursor: pointer; text-decoration: none; transition: all 0.2s; }
    .filter-btn:hover { border-color: #ff3f6c; color: #ff3f6c; }
    .filter-btn.active { background: #ff3f6c; color: white; border-color: #ff3f6c; }
    .status-completed { background: #d1fae5; color: #166534; }
    .status-pending_review { background: #fef3c7; color: #92400e; }
    .status-approved { background: #dbeafe; color: #1e40af; }
    .status-rejected { background: #fee2e2; color: #7f1d1d; }
    .status-payment_verification_failed { background: #fee2e2; color: #7f1d1d; }

    .btn-expand { background: none; border: none; cursor: pointer; color: #64748b; font-size: 14px; padding: 5px; }
    .btn-expand:hover { color: #3b82f6; }

    .btn-approve { padding: 8px 14px; background: #10b981; color: white; border: none; border-radius: 6px; font-size: 12px; cursor: pointer; font-weight: 600; transition: background 0.2s; }
    .btn-approve:hover { background: #059669; }

    .btn-reject { padding: 8px 14px; background: #ef4444; color: white; border: none; border-radius: 6px; font-size: 12px; cursor: pointer; font-weight: 600; transition: background 0.2s; }
    .btn-reject:hover { background: #dc2626; }

    .btn-update { padding: 8px 14px; background: #3b82f6; color: white; border: none; border-radius: 6px; font-size: 12px; cursor: pointer; font-weight: 600; transition: background 0.2s; }
    .btn-update:hover { background: #2563eb; }

    .btn-delete { padding: 8px 14px; background: #ef4444; color: white; border: none; border-radius: 6px; font-size: 12px; cursor: pointer; text-decoration: none; transition: background 0.2s; }
    .btn-delete:hover { background: #dc2626; }

    .order-detail-row td { background: #f8fafc; padding: 20px 16px; }
    .order-detail-row ul { margin: 0; padding-left: 16px; color: #475569; font-size: 13px; }
    .order-detail-row li { margin-bottom: 4px; }

    .status-badge { padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; display: inline-block; }
    .status-pending { background: #fef3c7; color: #92400e; }
    .status-confirmed { background: #dbeafe; color: #1e40af; }
    .status-shipped { background: #cffafe; color: #0c4a6e; }
    .status-delivered { background: #d1fae5; color: #166534; }
    .status-out_of_stock { background: #f8d7da; color: #721c24; }
    .status-completed { background: #d1fae5; color: #166534; }
    .status-failed { background: #fee2e2; color: #7f1d1d; }
    .status-cancelled { background: #fee2e2; color: #7f1d1d; }
</style>
</head>
<body>
<jsp:include page="/common/admin-header.jsp" />

    <% String successMessage = (String) session.getAttribute("succMsg");
       String failedMessage = (String) session.getAttribute("failedMsg");
       if (successMessage != null) { %>
    <div class="msg-bar msg-success">
        <i class="fas fa-check-circle"></i> <%= successMessage %>
    </div>
    <% session.removeAttribute("succMsg"); }
       if (failedMessage != null) { %>
    <div class="msg-bar msg-error">
        <i class="fas fa-exclamation-circle"></i> <%= failedMessage %>
    </div>
    <% session.removeAttribute("failedMsg"); } %>

    <div class="section-card">
        <div class="section-header">
            <h2><i class="fas fa-shopping-bag" style="color: #2563eb; margin-right: 8px;"></i>Order Management &amp; Approval</h2>
            <div class="filter-bar">
                <a href="adminOrders.jsp" class="filter-btn <%= filterStatus == null ? "active" : "" %>">All</a>
                <a href="adminOrders.jsp?status=pending" class="filter-btn <%= "pending".equals(filterStatus) ? "active" : "" %>">Pending</a>
                <a href="adminOrders.jsp?status=confirmed" class="filter-btn <%= "confirmed".equals(filterStatus) ? "active" : "" %>">Confirmed</a>
                <a href="adminOrders.jsp?status=shipped" class="filter-btn <%= "shipped".equals(filterStatus) ? "active" : "" %>">Shipped</a>
                <a href="adminOrders.jsp?status=delivered" class="filter-btn <%= "delivered".equals(filterStatus) ? "active" : "" %>">Delivered</a>
                <a href="adminOrders.jsp?status=out_of_stock" class="filter-btn <%= "out_of_stock".equals(filterStatus) ? "active" : "" %>">Out of Stock</a>
                <a href="adminOrders.jsp?status=cancelled" class="filter-btn <%= "cancelled".equals(filterStatus) ? "active" : "" %>">Cancelled</a>
            </div>
        </div>
        <div style="overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Items</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Payment Method</th>
                    <th>Approval</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                String orderSql = "SELECT * FROM orders";
                if (filterStatus != null && !filterStatus.trim().isEmpty()) {
                    orderSql += " WHERE status = ?";
                }
                try (Connection conn = DBConnect.getConn()) {
                    String orderColumn = DBConnect.hasColumn(conn, "orders", "created_at") ? "created_at" : "o_id";
                    orderSql += " ORDER BY " + orderColumn + " DESC";
                    try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                    if (filterStatus != null && !filterStatus.trim().isEmpty()) {
                        ps.setString(1, filterStatus.trim());
                    }

                    try (ResultSet rs = ps.executeQuery()) {
                        boolean hasOrders = false;
                        while(rs.next()) {
                            hasOrders = true;
                            int orderId = rs.getInt("o_id");
                            String status = rs.getString("status");
                            String userId = rs.getString("user_id");

                            // Get order items count
                            int itemCount = 0;
                            try (PreparedStatement psItems = conn.prepareStatement("SELECT COUNT(*) FROM order_items WHERE o_id = ?")) {
                                psItems.setInt(1, orderId);
                                try (ResultSet rsItems = psItems.executeQuery()) {
                                    if (rsItems.next()) itemCount = rsItems.getInt(1);
                                }
                            }
            %>
                <tr>
                    <td><strong>#<%= orderId %></strong></td>
                    <td><%= userId %></td>
                    <td><%= itemCount %> item(s)</td>
                    <td><%= String.format("&#8377;%.2f", rs.getBigDecimal("total_amount")) %></td>
                    <td><span class="status-badge status-<%= status %>"><%= status %></span></td>
                    <td><span class="status-badge status-completed"><%= rs.getString("payment_method") %></span></td>
                    <td>
                        <%
                            String approvalStatus = rs.getString("approval_status");
                            String approvalClass = "pending_review".equals(approvalStatus) ? "status-pending_review" : 
                                                   "approved".equals(approvalStatus) ? "status-approved" : 
                                                   "rejected".equals(approvalStatus) ? "status-rejected" : 
                                                   "payment_verification_failed".equals(approvalStatus) ? "status-payment_verification_failed" : "status-pending";
                        %>
                        <span class="status-badge <%= approvalClass %>"><%= approvalStatus %></span>
                    </td>
                    <td><button type="button" class="btn-expand" data-order-id="<%= orderId %>"><i class="fas fa-chevron-down"></i></button></td>
                </tr>
                <tr class="order-detail-row" id="details-<%= orderId %>" style="display:none;">
                    <td colspan="8">
                        <div style="padding: 20px; background: #f8fafc; border-radius: 8px;">
                            <!-- Order Details -->
                            <div style="margin-bottom: 20px;">
                                <h4 style="margin-bottom: 10px;">Order Details</h4>
                                <ul style="list-style: none; padding: 0;">
                                    <li style="margin-bottom: 8px;"><strong>Order Date:</strong> <%= DBConnect.hasColumn(conn, "orders", "created_at") ? rs.getTimestamp("created_at") : "N/A" %></li>
                                    <li style="margin-bottom: 8px;"><strong>Total Amount:</strong> ₹<%= String.format("%.2f", rs.getBigDecimal("total_amount")) %></li>
                                    <li style="margin-bottom: 8px;"><strong>Payment Method:</strong> <%= rs.getString("payment_method") %></li>
                                    <li style="margin-bottom: 8px;"><strong>Payment Status:</strong> <span class="status-badge status-<%= rs.getString("payment_status") %>"><%= rs.getString("payment_status") %></span></li>
                                </ul>
                            </div>

                            <!-- Shipping Address -->
                            <div style="margin-bottom: 20px;">
                                <h4 style="margin-bottom: 10px;">
                                    Shipping Address 
                                    <%
                                        boolean addressVerified = rs.getBoolean("address_verified");
                                        String shippingPincode = rs.getString("shipping_pincode");
                                        boolean locationVerified = rs.getBoolean("location_verified");
                                        String mapQuery = "";
                                        try {
                                            mapQuery = java.net.URLEncoder.encode(rs.getString("shipping_address") + (shippingPincode != null ? " " + shippingPincode : ""), "UTF-8");
                                        } catch (Exception ignored) {
                                        }
                                        if (addressVerified) {
                                    %>
                                    <span class="status-badge status-confirmed" style="font-size: 11px;">✓ Verified</span>
                                    <% } else { %>
                                    <span class="status-badge status-pending" style="font-size: 11px;">⚠ Unverified</span>
                                    <% } %>
                                </h4>
                                <p style="background: white; padding: 10px; border-radius: 5px; margin: 0; color: #475569;">
                                    <%= rs.getString("shipping_address") %>
                                </p>
                                <p style="margin: 8px 0 0 0; color: #334155;"><strong>Pincode:</strong> <%= shippingPincode != null ? shippingPincode : "N/A" %></p>
                                <p style="margin: 8px 0 0 0; color: #334155;"><strong>Location Verified:</strong> <span class='status-badge <%= locationVerified ? "status-confirmed" : "status-pending" %>' style="font-size: 11px; margin-left: 8px;"><%= locationVerified ? "Yes" : "No" %></span></p>
                                <% if (locationVerified) { %>
                                <div style="margin-top: 15px; border-radius: 10px; overflow: hidden; box-shadow: 0 5px 18px rgba(15, 23, 42, 0.08);">
                                    <iframe width="100%" height="280" src="https://www.google.com/maps?q=<%= mapQuery %>&output=embed" style="border:0;"></iframe>
                                </div>
                                <% } %>
                                <% if (!addressVerified) { %>
                                <form action="${pageContext.request.contextPath}/OrderApprovalServlet" method="post" style="margin-top: 10px; display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
                                    <input type="hidden" name="action" value="verifyAddress">
                                    <input type="hidden" name="orderId" value="<%= orderId %>">
                                    <button type="submit" class="btn-approve">Verify Address</button>
                                </form>
                                <% } %>
                                <% if (!locationVerified) { %>
                                <form action="${pageContext.request.contextPath}/OrderApprovalServlet" method="post" style="margin-top: 10px; display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
                                    <input type="hidden" name="action" value="verifyLocation">
                                    <input type="hidden" name="orderId" value="<%= orderId %>">
                                    <button type="submit" class="btn-approve">Verify Location</button>
                                </form>
                                <% } %>
                            </div>

                            <!-- Order Items -->
                            <div style="margin-bottom: 20px;">
                                <h4 style="margin-bottom: 10px;">Items Ordered</h4>
                                <ul style="list-style: none; padding: 0; background: white; border-radius: 5px;">
                                    <%
                                        try (PreparedStatement psOI = conn.prepareStatement("SELECT * FROM order_items WHERE o_id = ?")) {
                                            psOI.setInt(1, orderId);
                                            try (ResultSet rsOI = psOI.executeQuery()) {
                                                while (rsOI.next()) {
                                    %>
                                    <li style="padding: 10px; border-bottom: 1px solid #e2e8f0;">
                                        <strong><%= rsOI.getString("p_name") %></strong>
                                        <br/>
                                        Size: <%= rsOI.getString("size") != null ? rsOI.getString("size") : "N/A" %> | 
                                        Qty: <%= rsOI.getInt("quantity") %> | 
                                        Price: ₹<%= String.format("%.2f", rsOI.getBigDecimal("p_price")) %> | 
                                        Subtotal: ₹<%= String.format("%.2f", rsOI.getBigDecimal("subtotal")) %>
                                    </li>
                                    <%
                                                }
                                            }
                                        }
                                    %>
                                </ul>
                            </div>

                            <!-- Approval Workflow -->
                            <div style="margin-bottom: 20px; padding: 15px; background: white; border-radius: 5px; border-left: 4px solid #3b82f6;">
                                <h4 style="margin-top: 0;">Approval Workflow</h4>
                                <div style="margin-bottom: 15px;">
                                    <strong>1. Payment Verification</strong>
                                    <% 
                                        String paymentStatus = rs.getString("payment_status");
                                        if ("completed".equals(paymentStatus)) {
                                    %>
                                    <span class="status-badge status-confirmed" style="margin-left: 10px;">✓ Verified</span>
                                    <% } else if ("failed".equals(paymentStatus)) { %>
                                    <span class="status-badge status-cancelled" style="margin-left: 10px;">✗ Failed</span>
                                    <% } else { %>
                                    <span class="status-badge status-pending" style="margin-left: 10px;">Pending</span>
                                    <% if (!"completed".equals(paymentStatus) && !"failed".equals(paymentStatus)) { %>
                                    <form action="${pageContext.request.contextPath}/OrderApprovalServlet" method="post" style="display: inline-block; margin-left: 10px;">
                                        <input type="hidden" name="action" value="verifyPayment">
                                        <input type="hidden" name="orderId" value="<%= orderId %>">
                                        <button type="submit" class="btn-approve">Verify Payment</button>
                                    </form>
                                    <% } %>
                                    <% } %>
                                </div>

                                <div style="margin-bottom: 15px;">
                                    <strong>2. Order Approval</strong>
                                    <% 
                                        String approvalStatus2 = rs.getString("approval_status");
                                        if ("approved".equals(approvalStatus2)) {
                                    %>
                                    <span class="status-badge status-confirmed" style="margin-left: 10px;">✓ Approved</span>
                                    <% } else if ("rejected".equals(approvalStatus2)) { %>
                                    <span class="status-badge status-cancelled" style="margin-left: 10px;">✗ Rejected</span>
                                    <% } else { %>
                                    <span class="status-badge status-pending" style="margin-left: 10px;">Pending</span>
                                    <% if ("pending_review".equals(approvalStatus2)) { %>
                                    <div style="margin-top: 10px;">
                                        <form action="${pageContext.request.contextPath}/OrderApprovalServlet" method="post" style="display: inline-block; margin-right: 10px;">
                                            <input type="hidden" name="action" value="approveOrder">
                                            <input type="hidden" name="orderId" value="<%= orderId %>">
                                            <textarea name="approvalNotes" placeholder="Approval notes (optional)" style="width: 200px; height: 50px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; margin-right: 10px; font-family: monospace; font-size: 12px;"></textarea>
                                            <button type="submit" class="btn-approve">Approve Order</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/OrderApprovalServlet" method="post" style="display: inline-block;">
                                            <input type="hidden" name="action" value="rejectOrder">
                                            <input type="hidden" name="orderId" value="<%= orderId %>">
                                            <textarea name="rejectionReason" placeholder="Rejection reason" style="width: 200px; height: 50px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; margin-right: 10px; font-family: monospace; font-size: 12px;"></textarea>
                                            <button type="submit" class="btn-reject" onclick="return confirm('Are you sure you want to reject this order?');">Reject Order</button>
                                        </form>
                                    </div>
                                    <% } %>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Order Status Update (for fulfillment) -->
                            <div>
                                <h4 style="margin-top: 0;">Fulfillment Status</h4>
                                <form action="${pageContext.request.contextPath}/AdminOrderServlet" method="post" style="display: flex; gap: 10px; align-items: center;">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="orderId" value="<%= orderId %>">
                                    <select name="status" style="padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                                        <option value="pending" <%= "pending".equals(status) ? "selected" : "" %>>Pending</option>
                                        <option value="confirmed" <%= "confirmed".equals(status) ? "selected" : "" %>>Confirmed</option>
                                        <option value="shipped" <%= "shipped".equals(status) ? "selected" : "" %>>Shipped</option>
                                        <option value="delivered" <%= "delivered".equals(status) ? "selected" : "" %>>Delivered</option>
                                        <option value="out_of_stock" <%= "out_of_stock".equals(status) ? "selected" : "" %>>Out of Stock</option>
                                        <option value="cancelled" <%= "cancelled".equals(status) ? "selected" : "" %>>Cancelled</option>
                                    </select>
                                    <button type="submit" class="btn-update">Update Status</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/AdminOrderServlet" method="post" style="display: inline;" onsubmit="return confirm('Delete order #<%= orderId %>?');">
                                    <input type="hidden" name="action" value="deleteOrder">
                                    <input type="hidden" name="orderId" value="<%= orderId %>">
                                    <button type="submit" class="btn-delete">Delete</button>
                                </form>
                            </div>
                        </div>
                    </td>
                </tr>
            <%
                        }
                        if (!hasOrders) {
                            out.println("<tr><td colspan='8' style='text-align:center; color:#94a3b8; padding:40px;'>No orders found.</td></tr>");
                        }
                    }
                }
            } catch(Exception e) {
                    out.println("<tr><td colspan='8' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
            </tbody>
        </table>
        </div>
    </div>

<script>
function toggleDetails(orderId) {
    const row = document.getElementById('details-' + orderId);
    if (row) {
        row.style.display = row.style.display === 'none' ? 'table-row' : 'none';
    }
}

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.btn-expand').forEach(function(button) {
        button.addEventListener('click', function() {
            const orderId = this.getAttribute('data-order-id');
            if (orderId) toggleDetails(orderId);
        });
    });
});
</script>
<jsp:include page="/common/admin-footer.jsp" />
