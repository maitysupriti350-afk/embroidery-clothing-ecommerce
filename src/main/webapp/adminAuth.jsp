<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Sign In - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        body{font-family:Inter,Segoe UI,Arial,sans-serif;background:#fff;padding:40px}
        .card{max-width:420px;margin:40px auto;padding:28px;border-radius:12px;box-shadow:0 6px 24px rgba(16,24,40,0.06)}
        .card h2{margin-bottom:12px}
        .input-group{margin-bottom:12px}
        input{width:100%;padding:12px;border-radius:8px;border:1px solid #e6e6e6}
        .btn{background:#7c2241;color:#fff;padding:12px 16px;border-radius:8px;border:none;cursor:pointer}
        .note{font-size:13px;color:#6b7280;margin-top:10px}
    </style>
</head>
<body>
    <div class="card">
        <h2>Administrator Sign In</h2>
        <form method="post" action="${pageContext.request.contextPath}/AdminLoginServlet">
            <div class="input-group"><input type="email" name="userid" placeholder="Admin email" required></div>
            <div class="input-group"><input type="password" name="adminKey" placeholder="Admin key" required></div>
            <button class="btn" type="submit">Sign in as Admin</button>
        </form>
        <div class="note">Administrators must use this sign-in. Regular users: <a href="${pageContext.request.contextPath}/auth.jsp">Sign in here</a>.</div>
    </div>
</body>
</html>
