<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    String currentUser = session.getAttribute("user").toString();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help Center - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        .help-card { max-width:900px;margin:30px auto;padding:20px;background:#fff;border-radius:10px; }
        .field { margin-bottom:12px; }
        label { display:block;font-weight:600;margin-bottom:6px;color:#5d4037 }
        input[type=text], textarea { width:100%;padding:10px;border:1px solid #e5e0d6;border-radius:6px }
        .btn { background:#5d4037;color:#fff;padding:10px 14px;border-radius:8px;border:none;cursor:pointer }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<div class="help-card">
    <h2>Help Center</h2>
    <p>If you are facing any issue, submit a ticket below and our support team will get back to you.</p>
    <form method="post" action="${pageContext.request.contextPath}/HelpCenterServlet">
        <input type="hidden" name="user_id" value="<%= currentUser %>" />
        <div class="field">
            <label>Subject</label>
            <input type="text" name="subject" required />
        </div>
        <div class="field">
            <label>Message</label>
            <textarea name="message" rows="6" required></textarea>
        </div>
        <div style="display:flex;gap:10px;align-items:center">
            <button class="btn" type="submit">Submit Ticket</button>
            <a href="${pageContext.request.contextPath}/profile.jsp">Back to Profile</a>
        </div>
    </form>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>