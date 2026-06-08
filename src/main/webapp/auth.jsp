<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>The Gilded Stitch - Login or Signup</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #ffdce6 0%, #ffb6d7 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #3d1729;
        }
        .login-card {
            background: #fff5fb;
            padding: 0;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(93, 32, 80, 0.18);
            width: 400px;
            overflow: hidden;
            text-align: center;
        }
        .banner-img {
            width: 100%;
            height: 180px;
            background: #ffe9f2;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .banner-img img {
            width: 120px;
        }
        .form-content {
            padding: 40px;
        }
        h1 { 
            color: #381a2d; 
            margin: 0; 
            font-size: 24px; 
            font-weight: 700;
        }
        .subtitle { 
            color: #7b3a5a; 
            margin-bottom: 30px; 
            font-size: 16px; 
        }
        .subtitle span {
            font-weight: bold;
            color: #3d1729;
        }
        .input-group { 
            position: relative;
            margin-bottom: 20px; 
        }
        input {
            width: 100%;
            padding: 15px;
            border: 1px solid #f4d0df;
            border-radius: 4px;
            box-sizing: border-box; 
            font-size: 16px;
            outline: none;
            transition: border-color 0.3s;
            background: #fff5fb;
            color: #3d1729;
        }
        input:focus {
            border-color: #ff8fb8;
        }
        .terms {
            font-size: 12px;
            color: #8b3a5d;
            margin-bottom: 25px;
            line-height: 1.6;
        }
        .terms a {
            color: #d73a78;
            text-decoration: none;
            font-weight: bold;
        }
        .login-btn {
            width: 100%;
            padding: 15px;
            background: #ff8fb8;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .login-btn:hover {
            background: #ff5da3;
        }
        .footer-help { 
            margin-top: 25px; 
            font-size: 13px; 
            color: #6b3a53; 
        }
        .footer-help a { 
            color: #d73a78; 
            text-decoration: none; 
            font-weight: bold; 
        }
        .back-link {
            position: absolute;
            top: 20px;
            left: 20px;
            color: #7b2c4e;
            text-decoration: none;
            font-size: 16px;
        }
        .back-link:hover {
            text-decoration: underline;
        }

        /* Mobile Responsive Styles */
        @media (max-width: 768px) {
            body {
                padding: 16px;
                height: auto;
                min-height: 100vh;
            }
            
            .login-card {
                width: 100%;
                max-width: 100%;
                margin: 0;
            }
            
            .banner-img {
                height: 140px;
            }
            
            .banner-img img {
                width: 100px;
            }
            
            .form-content {
                padding: 24px 20px;
            }
            
            h1 {
                font-size: 20px;
            }
            
            .subtitle {
                font-size: 14px;
                margin-bottom: 20px;
            }
            
            .input-group {
                margin-bottom: 16px;
            }
            
            input {
                padding: 14px 16px;
                font-size: 16px;
            }
            
            .login-btn {
                padding: 14px 20px;
                font-size: 15px;
            }
            
            .terms {
                font-size: 11px;
                margin-bottom: 20px;
            }
            
            .footer-help {
                font-size: 12px;
                margin-top: 20px;
            }
            
            .back-link {
                position: relative;
                top: auto;
                left: auto;
                display: block;
                text-align: center;
                margin-bottom: 16px;
                font-size: 14px;
            }
            
            .tabs {
                display: flex;
                flex-direction: column;
                gap: 8px;
                margin-bottom: 20px;
            }
            
            .tab-btn {
                padding: 12px 16px;
                font-size: 14px;
            }
        }

        @media (max-width: 480px) {
            .form-content {
                padding: 20px 16px;
            }
            
            h1 {
                font-size: 18px;
            }
            
            .banner-img {
                height: 120px;
            }
            
            .banner-img img {
                width: 80px;
            }
        }
    </style>
</head>
<body>
    <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">← Back to Shop</a>

    <div class="login-card">
        <div class="banner-img">
            <img src="https://img.icons8.com/color/144/gift--v1.png" alt="Welcome Gift">
        </div>

        <div class="form-content">
            <h1>Login <span>or</span> Signup</h1>
            <div class="subtitle">Premium Collection Experience</div>
            
            <div class="tabs">
                <button class="tab-btn active" data-tab="otp">Email / OTP</button>
                <button class="tab-btn" data-tab="password">Password</button>
                <button class="tab-btn" data-tab="social">Social</button>
            </div>

            <div class="tab-content" id="otp">
                <form action="${pageContext.request.contextPath}/LoginServlet" method="post">
                    <div class="input-group">
                        <input type="email" name="userid" placeholder="Enter Email Address for OTP" required>
                    </div>
                    <p class="terms">By continuing, I agree to the <a href="#">Terms</a> &amp; <a href="#">Privacy</a></p>
                    <button type="submit" class="login-btn">Send OTP</button>
                </form>
            </div>

            <div class="tab-content" id="password" style="display:none">
                <form action="${pageContext.request.contextPath}/PasswordLoginServlet" method="post">
                    <div class="input-group">
                        <input type="email" name="userid" placeholder="Enter Email Address" required>
                    </div>
                    <div class="input-group">
                        <input type="password" name="password" placeholder="Enter Password" required>
                    </div>
                    <p class="terms"><a href="${pageContext.request.contextPath}/forgotPassword.jsp">Forgot password?</a></p>
                    <button type="submit" class="login-btn">Sign In</button>
                </form>
            </div>

            <div class="tab-content" id="social" style="display:none">
                <div style="display:flex;flex-direction:column;gap:12px">
                    <a class="login-btn" style="background:#4285F4;" href="#">Continue with Google</a>
                    <a class="login-btn" style="background:#3b5998;" href="#">Continue with Facebook</a>
                    <a class="login-btn" style="background:#ff2d55;" href="#">Continue with Apple</a>
                </div>
            </div>

            <script>
                document.querySelectorAll('.tab-btn').forEach(btn => btn.addEventListener('click', function(){
                    document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
                    this.classList.add('active');
                    document.querySelectorAll('.tab-content').forEach(tc=>tc.style.display='none');
                    document.getElementById(this.dataset.tab).style.display='block';
                }));
            </script>

            <div class="footer-help">
                Having trouble logging in? <a href="#">Get help</a>
            </div>
            <% if (msg != null || error != null) { %>
                <div style="margin-top: 20px; color: #b91c1c; font-size: 14px;">
                    <% if ("session_expired".equals(msg)) { %>
                        Your session expired. Please login again.
                    <% } else if (error != null) { %>
                        Something went wrong. Please try again.
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

</body>
</html>
