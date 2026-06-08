<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        .sophisticated-container{
            max-width:900px;margin:40px auto;padding:28px 32px;background:linear-gradient(180deg,#FFEDED 0%,#FFF6F6 100%);border-radius:12px;box-shadow:0 6px 16px rgba(46,58,63,.04);border:1px solid rgba(160,40,40,.06);color:#3B0F11;font-family:'Segoe UI',Roboto,Arial,sans-serif;
        }
        .sophisticated-container h2{color:#7C1A1A;margin-top:0}
        .policy p{color:#4A1516;line-height:1.7}
        .policy small{color:#7A2B2B}
        @media (max-width:600px){ .sophisticated-container{margin:20px;padding:18px} }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<div class="sophisticated-container policy">
    <h2>Privacy Policy</h2>
    <p>We respect your privacy and handle personal data with care. This placeholder should be replaced with your full privacy policy describing data collection, storage, and usage practices.</p>
    <p><small>We use industry-standard safeguards and only retain personal data as necessary to provide our service.</small></p>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>