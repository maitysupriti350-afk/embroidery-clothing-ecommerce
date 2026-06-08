<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Coupons - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        .wrap{max-width:1000px;margin:30px auto}
        table{width:100%;border-collapse:collapse}
        th,td{padding:8px 10px;border-bottom:1px solid #eee;text-align:left}
        .form-row{display:flex;gap:8px;align-items:center}
        .btn{padding:8px 12px;border-radius:6px;border:none;cursor:pointer}
        .btn-primary{background:#7c2241;color:#fff}
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<div class="wrap">
    <h2>Coupons</h2>
    <form method="post" action="${pageContext.request.contextPath}/AdminCouponServlet">
        <input type="hidden" name="action" value="create" />
        <div class="form-row">
            <input name="code" placeholder="Code e.g. WELCOME10" required />
            <select name="type"><option value="percent">Percent</option><option value="fixed">Fixed</option></select>
            <input name="value" placeholder="Value" required />
            <input name="max_discount" placeholder="Max discount (optional)" />
            <label><input type="checkbox" name="first" /> First Order Only</label>
            <input name="usage_limit" placeholder="Usage limit (0 unlimited)" />
            <button class="btn btn-primary" type="submit">Create Coupon</button>
        </div>
    </form>

    <h3 style="margin-top:20px">Existing Coupons</h3>
    <table>
        <tr><th>Code</th><th>Type</th><th>Value</th><th>Max</th><th>First only</th><th>Uses</th><th>Limit</th><th>Active</th><th>Actions</th></tr>
        <%
            List<Map<String,Object>> coupons = (List<Map<String,Object>>) request.getAttribute("coupons");
            if (coupons != null) for (Map<String,Object> c : coupons) {
        %>
        <tr>
            <td><%= c.get("code") %></td>
            <td><%= c.get("type") %></td>
            <td><%= c.get("value") %></td>
            <td><%= c.get("max_discount") %></td>
            <td><%= c.get("first_order_only") %></td>
            <td><%= c.get("uses") %></td>
            <td><%= c.get("usage_limit") %></td>
            <td><%= c.get("active") %></td>
            <td>
                <form method="post" action="${pageContext.request.contextPath}/AdminCouponServlet" style="display:inline">
                    <input type="hidden" name="action" value="toggle" />
                    <input type="hidden" name="code" value="<%= c.get("code") %>" />
                    <button class="btn">Toggle</button>
                </form>
                <form method="post" action="${pageContext.request.contextPath}/AdminCouponServlet" style="display:inline" onsubmit="return confirm('Delete coupon?');">
                    <input type="hidden" name="action" value="delete" />
                    <input type="hidden" name="code" value="<%= c.get("code") %>" />
                    <button class="btn">Delete</button>
                </form>
            </td>
        </tr>
        <% } %>
    </table>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
