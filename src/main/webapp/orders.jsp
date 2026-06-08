<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    Object ordersObj = request.getAttribute("orders");
    List<Map<String, Object>> orders = ordersObj != null ? (List<Map<String, Object>>) ordersObj : null;
    String msg = request.getParameter("msg");
    String orderIdParam = request.getParameter("orderId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Track your orders - THE GILDED STITCH">
    <title>Order Tracking - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        :root {
            --primary: #ff9800;
            --primary-dark: #f57c00;
            --secondary: #ff3f6c;
            --success: #4caf50;
            --warning: #ff9800;
            --danger: #f44336;
            --info: #2196f3;
            --text-dark: #2c3e50;
            --text-light: #7f8c8d;
            --bg-light: #f9e79f;
            --white: #ffffff;
        }
        
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-light);
            color: var(--text-dark);
            min-height: 100vh;
        }
        
        .orders-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .page-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 10px;
        }
        
        .page-header p {
            color: var(--text-light);
            font-size: 1rem;
        }
        
        .message-box {
            padding: 16px 20px;
            border-radius: 10px;
            margin-bottom: 24px;
            font-weight: 600;
        }
        
        .message-success { background: #e8f5e9; color: var(--success); border-left: 4px solid var(--success); }
        .message-warning { background: #fff3e0; color: var(--warning); border-left: 4px solid var(--warning); }
        .message-error { background: #ffebee; color: var(--danger); border-left: 4px solid var(--danger); }
        
        .order-card {
            background: var(--white);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            border: 2px solid rgba(255,152,0,0.1);
            transition: all 0.3s ease;
        }
        
        .order-card:hover {
            box-shadow: 0 8px 30px rgba(255,152,0,0.15);
            transform: translateY(-2px);
        }
        
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 20px;
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 20px;
        }
        
        .order-id {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-dark);
        }
        
        .order-date {
            color: var(--text-light);
            font-size: 0.9rem;
            margin-top: 4px;
        }
        
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-pending { background: #fff3e0; color: var(--warning); }
        .status-confirmed { background: #e3f2fd; color: var(--info); }
        .status-shipped { background: #e8f5e9; color: var(--success); }
        .status-delivered { background: #f3e5f5; color: #9c27b0; }
        .status-cancelled { background: #ffebee; color: var(--danger); }
        .status-out_for_delivery { background: #fff8e1; color: #f57f17; }
        
        .order-body {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }
        
        .items-section h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            color: var(--text-dark);
            margin-bottom: 16px;
        }
        
        .item-row {
            display: flex;
            gap: 16px;
            padding: 16px;
            background: #fafafa;
            border-radius: 12px;
            margin-bottom: 12px;
            transition: all 0.3s ease;
        }
        
        .item-row:hover {
            background: #f5f5f5;
        }
        
        .item-image {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 10px;
            border: 2px solid rgba(255,152,0,0.2);
        }
        
        .item-details {
            flex: 1;
        }
        
        .item-name {
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 4px;
            text-decoration: none;
        }
        
        .item-name:hover {
            color: var(--primary);
        }
        
        .item-meta {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .item-price {
            font-weight: 700;
            color: var(--primary);
            font-size: 1.1rem;
        }
        
        .order-summary {
            background: #fff8e1;
            padding: 20px;
            border-radius: 12px;
            border: 2px solid rgba(255,152,0,0.1);
        }
        
        .order-summary h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            color: var(--text-dark);
            margin-bottom: 16px;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(0,0,0,0.05);
        }
        
        .summary-row:last-child {
            border-bottom: none;
        }
        
        .summary-total {
            font-weight: 700;
            font-size: 1.2rem;
            color: var(--primary);
            padding-top: 12px;
            border-top: 2px solid rgba(255,152,0,0.2);
            margin-top: 8px;
        }
        
        .status-timeline {
            margin-top: 20px;
        }
        
        .timeline {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin-top: 30px;
        }
        
        .timeline::before {
            content: '';
            position: absolute;
            top: 12px;
            left: 0;
            right: 0;
            height: 3px;
            background: #e0e0e0;
            z-index: 0;
        }
        
        .timeline-step {
            position: relative;
            z-index: 1;
            text-align: center;
            flex: 1;
        }
        
        .timeline-dot {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #e0e0e0;
            margin: 0 auto 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: #fff;
            transition: all 0.3s ease;
        }
        
        .timeline-step.active .timeline-dot {
            background: var(--primary);
            box-shadow: 0 0 0 4px rgba(255,152,0,0.2);
        }
        
        .timeline-step.completed .timeline-dot {
            background: var(--success);
        }
        
        .timeline-label {
            font-size: 0.85rem;
            color: var(--text-light);
            font-weight: 600;
        }
        
        .timeline-step.active .timeline-label {
            color: var(--primary);
        }
        
        .order-actions {
            display: flex;
            gap: 12px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            border: none;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: var(--primary);
            color: #fff;
        }
        
        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255,152,0,0.3);
        }
        
        .btn-secondary {
            background: #fff;
            color: var(--text-dark);
            border: 2px solid #e0e0e0;
        }
        
        .btn-secondary:hover {
            border-color: var(--primary);
            color: var(--primary);
        }
        
        .btn-danger {
            background: var(--danger);
            color: #fff;
        }
        
        .btn-danger:hover {
            background: #d32f2f;
        }
        
        .btn-disabled {
            background: #e0e0e0;
            color: #9e9e9e;
            cursor: not-allowed;
        }
        
        .invoice-section {
            margin-top: 24px;
            padding: 20px;
            background: #f5f5f5;
            border-radius: 12px;
            display: none;
        }
        
        .invoice-section.show {
            display: block;
        }
        
        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .invoice-header h3 {
            font-family: 'Playfair Display', serif;
            color: var(--text-dark);
        }
        
        .invoice-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .invoice-detail-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        
        .invoice-detail-item label {
            font-size: 0.85rem;
            color: var(--text-light);
            font-weight: 600;
        }
        
        .invoice-detail-item span {
            font-weight: 700;
            color: var(--text-dark);
        }
        
        .no-orders {
            text-align: center;
            padding: 60px 20px;
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }
        
        .no-orders i {
            font-size: 4rem;
            color: var(--text-light);
            margin-bottom: 20px;
        }
        
        .no-orders h2 {
            font-family: 'Playfair Display', serif;
            color: var(--text-dark);
            margin-bottom: 12px;
        }
        
        .no-orders p {
            color: var(--text-light);
            margin-bottom: 20px;
        }
        
        /* Mobile Responsiveness */
        @media (max-width: 768px) {
            .orders-container {
                margin: 20px auto;
                padding: 16px;
            }
            
            .page-header h1 {
                font-size: 1.8rem;
            }
            
            .order-body {
                grid-template-columns: 1fr;
            }
            
            .order-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }
            
            .invoice-details {
                grid-template-columns: 1fr;
            }
            
            .timeline {
                flex-wrap: wrap;
                gap: 20px;
            }
            
            .timeline::before {
                display: none;
            }
            
            .timeline-step {
                flex: 0 0 auto;
                min-width: 80px;
            }
            
            .order-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
        }
        
        @media (max-width: 480px) {
            .item-row {
                flex-direction: column;
                text-align: center;
            }
            
            .item-image {
                width: 100%;
                height: 200px;
            }
        }
    </style>
</head>
<body>
    <%@ include file="common/header.jsp" %>
    
    <div class="orders-container">
        <div class="page-header">
            <h1><i class="fas fa-box-open" style="margin-right: 12px;"></i>Order Tracking</h1>
            <p>Track your orders and view invoice details</p>
        </div>
        
        <% if ("cancelled".equals(msg)) { %>
            <div class="message-box message-success">
                <i class="fas fa-check-circle"></i> Order cancelled successfully.
            </div>
        <% } else if ("not_allowed".equals(msg)) { %>
            <div class="message-box message-warning">
                <i class="fas fa-exclamation-triangle"></i> Order cannot be cancelled at this stage.
            </div>
        <% } else if ("notfound".equals(msg)) { %>
            <div class="message-box message-error">
                <i class="fas fa-times-circle"></i> Order not found.
            </div>
        <% } else if ("error".equals(msg)) { %>
            <div class="message-box message-error">
                <i class="fas fa-exclamation-circle"></i> An error occurred. Try again later.
            </div>
        <% } %>

        <% if (orders == null || orders.isEmpty()) { %>
            <div class="no-orders">
                <i class="fas fa-shopping-bag"></i>
                <h2>No Orders Yet</h2>
                <p>You haven't placed any orders yet. Start shopping to see your orders here!</p>
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary">
                    <i class="fas fa-shopping-cart"></i> Start Shopping
                </a>
            </div>
        <% } else {
            for (Map<String, Object> o : orders) {
                Integer oid = (Integer) o.get("order_id");
                String status = (String) o.get("status");
                java.math.BigDecimal total = (java.math.BigDecimal) o.get("total");
                Object placedAt = o.get("placed_at");
                String shippingAddress = (String) o.get("shipping_address");
                String paymentMethod = (String) o.get("payment_method");
                String paymentStatus = (String) o.get("payment_status");
                List<Map<String, Object>> items = (List<Map<String, Object>>) o.get("items");
                
                // Determine status class
                String statusClass = "status-pending";
                if (status != null) {
                    String st = status.toLowerCase();
                    if (st.contains("confirmed")) statusClass = "status-confirmed";
                    else if (st.contains("shipped")) statusClass = "status-shipped";
                    else if (st.contains("delivered")) statusClass = "status-delivered";
                    else if (st.contains("cancelled")) statusClass = "status-cancelled";
                    else if (st.contains("out for")) statusClass = "status-out_for_delivery";
                }
                
                // Determine timeline step
                String st = status == null ? "pending" : status.toLowerCase();
                int step = 0;
                if (st.contains("cancel")) { step = -1; }
                else if (st.contains("delivered")) step = 4;
                else if (st.contains("out for")) step = 3;
                else if (st.contains("shipped")) step = 2;
                else if (st.contains("confirmed")) step = 1;
                else step = 0;
        %>
                <div class="order-card">
                    <div class="order-header">
                        <div>
                            <div class="order-id">Order #<%= oid %></div>
                            <div class="order-date"><i class="far fa-calendar-alt"></i> Placed: <%= placedAt %></div>
                        </div>
                        <span class="status-badge <%= statusClass %>"><%= status != null ? status : "Pending" %></span>
                    </div>

                    <div class="order-body">
                        <div class="items-section">
                            <h3><i class="fas fa-box" style="margin-right: 8px;"></i>Order Items</h3>
                            <% if (items != null && !items.isEmpty()) {
                                for (Map<String,Object> it : items) {
                                    Integer pid = (Integer) it.get("p_id");
                                    String pname = (String) it.get("p_name");
                                    String pimage = (String) it.get("p_image");
                                    Integer qty = (Integer) it.get("quantity");
                                    java.math.BigDecimal price = (java.math.BigDecimal) it.get("price");
                            %>
                            <div class="item-row">
                                <img src="${pageContext.request.contextPath}/product_img/<%= pimage %>" alt="<%= pname %>" class="item-image" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg';">
                                <div class="item-details">
                                    <a href="<%= request.getContextPath() %>/product.jsp?id=<%= pid %>" class="item-name"><%= pname %></a>
                                    <div class="item-meta">Quantity: <%= qty %> | Size: <%= it.get("size") != null ? it.get("size") : "N/A" %></div>
                                    <div class="item-price">₹<%= price %></div>
                                </div>
                            </div>
                            <%      }
                               } else { %>
                                <div class="item-row" style="justify-content: center;">No items found for this order.</div>
                            <% } %>
                            
                            <div class="status-timeline">
                                <h3><i class="fas fa-truck" style="margin-right: 8px;"></i>Order Status</h3>
                                <div class="timeline">
                                    <div class="timeline-step <%= step >= 0 ? "active" : "" %>">
                                        <div class="timeline-dot"><i class="fas fa-shopping-cart"></i></div>
                                        <div class="timeline-label">Placed</div>
                                    </div>
                                    <div class="timeline-step <%= step >= 1 ? "active" : "" %>">
                                        <div class="timeline-dot"><i class="fas fa-check"></i></div>
                                        <div class="timeline-label">Confirmed</div>
                                    </div>
                                    <div class="timeline-step <%= step >= 2 ? "active" : "" %>">
                                        <div class="timeline-dot"><i class="fas fa-shipping-fast"></i></div>
                                        <div class="timeline-label">Shipped</div>
                                    </div>
                                    <div class="timeline-step <%= step >= 3 ? "active" : "" %>">
                                        <div class="timeline-dot"><i class="fas fa-truck"></i></div>
                                        <div class="timeline-label">Out for Delivery</div>
                                    </div>
                                    <div class="timeline-step <%= step == 4 ? "active" : "" %>">
                                        <div class="timeline-dot"><i class="fas fa-home"></i></div>
                                        <div class="timeline-label">Delivered</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="order-summary">
                            <h3><i class="fas fa-receipt" style="margin-right: 8px;"></i>Order Summary</h3>
                            <div class="summary-row">
                                <span>Subtotal</span>
                                <span>₹<%= total %></span>
                            </div>
                            <div class="summary-row">
                                <span>Shipping</span>
                                <span>Free</span>
                            </div>
                            <div class="summary-row">
                                <span>Payment Method</span>
                                <span><%= paymentMethod != null ? paymentMethod : "COD" %></span>
                            </div>
                            <div class="summary-row summary-total">
                                <span>Total</span>
                                <span>₹<%= total %></span>
                            </div>
                            
                            <div class="order-actions">
                                <% boolean canCancel = status == null || (!status.toLowerCase().contains("shipped") && !status.toLowerCase().contains("out for") && !status.toLowerCase().contains("delivered") && !status.toLowerCase().contains("cancelled")); %>
                                <% if (canCancel) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/CancelOrderServlet" onsubmit="return confirm('Cancel this order?');" style="display: inline;">
                                        <input type="hidden" name="order_id" value="<%= oid %>" />
                                        <button type="submit" class="btn btn-danger">
                                            <i class="fas fa-times"></i> Cancel Order
                                        </button>
                                    </form>
                                <% } else { %>
                                    <button class="btn btn-disabled" disabled>
                                        <i class="fas fa-ban"></i> Cannot Cancel
                                    </button>
                                <% } %>
                                <button class="btn btn-secondary" onclick="toggleInvoice('<%= oid %>')">
                                    <i class="fas fa-file-invoice"></i> View Invoice
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Invoice Section -->
                    <div class="invoice-section" id="invoice-<%= oid %>">
                        <div class="invoice-header">
                            <h3><i class="fas fa-file-invoice-dollar"></i> Invoice Details</h3>
                            <button class="btn btn-secondary" onclick="toggleInvoice('<%= oid %>')">
                                <i class="fas fa-times"></i> Close
                            </button>
                        </div>
                        <div class="invoice-details">
                            <div class="invoice-detail-item">
                                <label>Order ID</label>
                                <span>#<%= oid %></span>
                            </div>
                            <div class="invoice-detail-item">
                                <label>Order Date</label>
                                <span><%= placedAt %></span>
                            </div>
                            <div class="invoice-detail-item">
                                <label>Payment Status</label>
                                <span><%= paymentStatus != null ? paymentStatus : "Pending" %></span>
                            </div>
                            <div class="invoice-detail-item">
                                <label>Payment Method</label>
                                <span><%= paymentMethod != null ? paymentMethod : "COD" %></span>
                            </div>
                            <div class="invoice-detail-item" style="grid-column: 1 / -1;">
                                <label>Shipping Address</label>
                                <span><%= shippingAddress != null ? shippingAddress : "Not provided" %></span>
                            </div>
                        </div>
                        <div class="order-actions">
                            <button class="btn btn-primary" onclick="window.print()">
                                <i class="fas fa-print"></i> Print Invoice
                            </button>
                            <button class="btn btn-secondary" onclick="downloadInvoice('<%= oid %>')">
                                <i class="fas fa-download"></i> Download PDF
                            </button>
                        </div>
                    </div>
                </div>
        <%  }
        } %>
    </div>
    
    <%@ include file="common/footer.jsp" %>
    
    <script>
        function toggleInvoice(orderId) {
            const invoiceSection = document.getElementById('invoice-' + orderId);
            invoiceSection.classList.toggle('show');
        }
        
        function downloadInvoice(orderId) {
            alert('Invoice download feature coming soon! Order ID: ' + orderId);
        }
        
        // Auto-show invoice if orderId parameter is present
        const urlParams = new URLSearchParams(window.location.search);
        const orderIdParam = urlParams.get('orderId');
        if (orderIdParam) {
            const invoiceSection = document.getElementById('invoice-' + orderIdParam);
            if (invoiceSection) {
                invoiceSection.classList.add('show');
                // Scroll to invoice
                invoiceSection.scrollIntoView({ behavior: 'smooth' });
            }
        }
    </script>
</body>
</html>
