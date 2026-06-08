<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        .sophisticated-container{
            max-width:900px;margin:40px auto;padding:28px 32px;background:linear-gradient(180deg,#FFEDED 0%,#FFF6F6 100%);border-radius:12px;box-shadow:0 8px 18px rgba(46,58,63,.04);border:1px solid rgba(160,40,40,.04);color:#3A0F10;font-family:'Segoe UI',Roboto,Arial,sans-serif;
        }
        .sophisticated-container h2{color:#7C1A1A;margin-top:0}
        .lead{color:#5A1517;font-size:15px;line-height:1.7}
        .accent{color:#8A1F1F}
        @media (max-width:600px){ .sophisticated-container{margin:20px;padding:20px} }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<div class="sophisticated-container">
    <h2>About THE GILDED STITCH</h2>
    <p class="lead">We curate elegant traditional clothing with love and craftsmanship. Our mission is to bring heritage fashion to modern wardrobes.</p>
    <p class="lead"><span class="accent">Craftsmanship.</span> We work with artisans to preserve handwork and fine fabrics. <span class="accent">Sustainability.</span> We choose responsible materials wherever possible.</p>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>