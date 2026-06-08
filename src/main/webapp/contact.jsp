<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        /* Sophisticated palette */
        .sophisticated-container{
            max-width:900px;
            margin:48px auto;
            padding:28px 32px;
            background: linear-gradient(180deg,#F6F1ED 0%, #fff 100%);
            border-radius:12px;
            box-shadow:0 8px 20px rgba(46,58,63,0.12);
            border:1px solid rgba(75,34,65,0.06);
            color:#2E3A3F;
            font-family: 'Segoe UI', Roboto, Arial, sans-serif;
        }
        .sophisticated-container h2{
            color:#4B2241;
            margin-top:0;
        }
        .sophisticated-hr{
            height:2px;background:linear-gradient(90deg,#D4AF37,transparent);border:none;margin:18px 0 22px;
        }
        .sophisticated-contact{font-size:15px;line-height:1.6;color:#445156}
        @media (max-width:600px){ .sophisticated-container{padding:20px;margin:20px} }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<div class="sophisticated-container">
    <h2>Contact Us</h2>
    <div class="sophisticated-hr"></div>
    <div class="sophisticated-contact">
        <p><strong>Helpline:</strong> 1800-123-4567</p>
        <p><strong>Email:</strong> support@thegildedstitch.example</p>
        <p>Our customer care team is available Monday–Saturday, 9am–7pm.</p>
    </div>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>