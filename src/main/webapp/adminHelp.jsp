<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Help Tickets</title>
    <link rel="stylesheet" href="/css/common.css">
    <style>
        .ticket { background:#fff;padding:12px;border-radius:8px;margin-bottom:12px }
        .ticket h4 { margin:0 0 6px 0 }
        .btn { padding:6px 10px;border-radius:6px;border:none;cursor:pointer }
        .btn-respond { background:#3b82f6;color:#fff }
        .btn-close { background:#ef4444;color:#fff }
    </style>
</head>
<body>
<jsp:include page="/common/admin-header.jsp" />
<div style="max-width:1000px;margin:24px auto;">
    <h2>Help Tickets</h2>
    <div>
        <%
            try (Connection conn = DBConnect.getConn()) {
                String orderColumn = DBConnect.hasColumn(conn, "help_tickets", "created_at") ? "created_at" : "id";
                try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM help_tickets ORDER BY " + orderColumn + " DESC")) {
                    try (ResultSet rs = ps.executeQuery()) {
                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        int id = rs.getInt("id");
                        String userId = rs.getString("user_id");
                        String subject = rs.getString("subject");
                        String msg = rs.getString("message");
                        String status = rs.getString("status");
                        String adminResp = rs.getString("admin_response");
        %>
        <div class="ticket">
            <h4>Ticket #<%= id %> — <%= subject %> <small style="color:#6b3a53">by <%= userId %></small></h4>
            <p style="color:#475569"><%= msg %></p>
            <p style="font-size:13px;color:#6b3a53">Status: <strong><%= status %></strong></p>
            <% if (adminResp != null) { %>
                <div style="background:#f8fafc;padding:10px;border-radius:6px;margin-top:8px;color:#334155">Admin Response: <%= adminResp %></div>
            <% } %>
            <div style="margin-top:8px;display:flex;gap:8px;">
                <form action="${pageContext.request.contextPath}/AdminHelpServlet" method="post" style="display:inline-block;">
                    <input type="hidden" name="action" value="respond" />
                    <input type="hidden" name="ticketId" value="<%= id %>" />
                    <input type="text" name="response" placeholder="Write a response to user" style="padding:8px;border:1px solid #e2e8f0;border-radius:6px;min-width:300px" required />
                    <button class="btn btn-respond" type="submit">Respond &amp; Notify</button>
                </form>
                <form action="${pageContext.request.contextPath}/AdminHelpServlet" method="post" onsubmit="return confirm('Close ticket #<%= id %>?');">
                    <input type="hidden" name="action" value="close" />
                    <input type="hidden" name="ticketId" value="<%= id %>" />
                    <button class="btn btn-close" type="submit">Close</button>
                </form>
            </div>
        </div>
        <%
                    }
                    if (!any) {
                        out.println("<div style='color:#94a3b8;padding:20px;background:#fff;border-radius:8px'>No tickets found.</div>");
                    }
                }
            }
        %>
    </div>
</div>
<jsp:include page="/common/admin-footer.jsp" />
</body>
</html>