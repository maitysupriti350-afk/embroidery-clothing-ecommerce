<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("tempUser") == null) {
        response.sendRedirect("auth.jsp?msg=session_expired");
        return;
    }
    String invalidOtp = request.getParameter("invalid");
    String expiredOtp = request.getParameter("expired");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>Verify OTP - Maity's Collection</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #ffdce6, #ffb7d8); display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .otp-card { background: #fff5fb; padding: 40px; border-radius: 12px; box-shadow: 0 8px 25px rgba(93, 32, 80, 0.18); width: 360px; text-align: left; }
        .back-btn { font-size: 24px; cursor: pointer; text-decoration: none; color: #7b2c4e; display: block; margin-bottom: 20px; }
        h2 { font-size: 22px; margin: 0 0 10px 0; color: #381a2d; }
        p { color: #6b3a53; font-size: 14px; margin-bottom: 30px; }
        .otp-input-container { display: flex; gap: 10px; margin-bottom: 30px; }
        .otp-box { width: 45px; height: 45px; border: 1px solid #f4d0df; text-align: center; font-size: 18px; border-radius: 6px; }
        /* Real input hidden but functional */
        .real-otp { width: 100%; padding: 12px; border: 1px solid #f4d0df; border-radius: 6px; font-size: 16px; letter-spacing: 6px; text-align: center; background: #fff5fb; color: #3d1729; }
        .real-otp:focus { border-color: #ff8fb8; outline: none; box-shadow: 0 0 0 3px rgba(255, 143, 184, 0.18); }
        .verify-btn { width: 100%; padding: 15px; background-color: #ff8fb8; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; text-transform: uppercase; }
        .verify-btn:hover { background-color: #ff5da3; }
        .resend { margin-top: 20px; font-size: 13px; color: #7b3a5a; }
        .resend span { color: #d73a78; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>

    <div class="otp-card">
        <a href="${pageContext.request.contextPath}/auth.jsp" class="back-btn">←</a>
        <h2>Verify with OTP</h2>
        <p>Sent to: <strong><%= session.getAttribute("tempUser") != null ? session.getAttribute("tempUser").toString().replaceAll("[<>\"']", "") : "" %></strong></p>
        
        <form id="otpForm" action="${pageContext.request.contextPath}/VerifyOTPServlet" method="post" data-expired="<%= expiredOtp != null ? "true" : "false" %>">
            <input type="text" name="otp" class="real-otp" placeholder="Enter 6-digit OTP" maxlength="6" required>
            <br><br>
            <div id="timer" style="font-size:14px;color:#6b3a53;margin-bottom:12px;">OTP expires in 05:00</div>
            <button type="submit" id="verifyBtn" class="verify-btn">Verify &amp; Login</button>
        </form>
        <% if (invalidOtp != null) { %>
            <p style="color: #b91c1c; margin-top: 16px;">Invalid OTP, please try again.</p>
        <% } %>
        <% if (expiredOtp != null) { %>
            <p style="color: #b91c1c; margin-top: 16px;">OTP expired. Please request a new one.</p>
        <% } %>

        <div class="resend">
            Didn't receive OTP? <span>Resend OTP</span>
        </div>
    </div>

    <script>
        (function() {
            var totalSeconds = 300; // 5 minutes
            var timerEl = document.getElementById('timer');
            var verifyBtn = document.getElementById('verifyBtn');
            var otpForm = document.getElementById('otpForm');
            var isExpired = otpForm.getAttribute('data-expired') === 'true';

            function formatTime(seconds) {
                var minutes = Math.floor(seconds / 60);
                var remaining = seconds % 60;
                return (minutes < 10 ? '0' + minutes : minutes) + ':' + (remaining < 10 ? '0' + remaining : remaining);
            }

            function updateTimer() {
                if (totalSeconds >= 0) {
                    timerEl.textContent = 'OTP expires in ' + formatTime(totalSeconds);
                    if (totalSeconds === 0) {
                        timerEl.textContent = 'OTP has expired. Please request a new OTP.';
                        verifyBtn.disabled = true;
                        verifyBtn.style.backgroundColor = '#ccc';
                        verifyBtn.style.cursor = 'not-allowed';
                    }
                    totalSeconds--;
                }
            }

            if (isExpired) {
                verifyBtn.disabled = true;
                verifyBtn.style.backgroundColor = '#ccc';
                verifyBtn.style.cursor = 'not-allowed';
                timerEl.textContent = 'OTP has expired. Please request a new OTP.';
            } else {
                updateTimer();
                setInterval(updateTimer, 1000);
            }

            otpForm.addEventListener('submit', function(event) {
                if (verifyBtn.disabled) {
                    event.preventDefault();
                }
            });
        })();
    </script>
</body>
</html>
