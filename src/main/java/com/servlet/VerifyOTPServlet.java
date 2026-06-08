package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import com.conn.DBConnect;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/VerifyOTPServlet")
public class VerifyOTPServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String enteredOtp = request.getParameter("otp");
        HttpSession session = request.getSession(false); 
        
        // ১. সেশন চেক
        if (session == null || session.getAttribute("tempUser") == null) {
            response.sendRedirect("auth.jsp?msg=session_expired");
            return;
        }

        String uid = (String) session.getAttribute("tempUser");

        String sql = "select otp_generated_at from user where userid=? and otp=?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, uid);
            ps.setString(2, enteredOtp);
            
            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    Timestamp generatedAt = rs.getTimestamp("otp_generated_at");
                    long now = System.currentTimeMillis();
                    long expiryMillis = 5 * 60 * 1000; // 5 minutes
                    if (generatedAt == null || now - generatedAt.getTime() > expiryMillis) {
                        response.sendRedirect("verifyOTP.jsp?expired=true");
                        return;
                    }

                    // OTP matched and is still valid - set permanent session and clear OTP
                    session.setAttribute("user", uid);
                    session.removeAttribute("tempUser");
                    // Clear the OTP so it can't be reused
                    try (PreparedStatement psClear = conn.prepareStatement("UPDATE user SET otp = NULL, otp_generated_at = NULL WHERE userid = ?")) {
                        psClear.setString(1, uid);
                        psClear.executeUpdate();
                    }
                    response.sendRedirect("dashboard.jsp"); 
                } else {
                    // ৪. ভুল ওটিপি হলে ওটিপি পেজেই ফেরত পাঠানো
                    response.sendRedirect("verifyOTP.jsp?invalid=true");
                }
            }
            
            // রিসোর্স ক্লোজ করা - now automatic with try-with-resources

        } catch (Exception e) {
            e.printStackTrace();
            
            response.sendRedirect("auth.jsp?error=server_issue");
        }
    }
}