package com.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;
import com.conn.DBConnect;
import com.utility.EmailUtility;
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uid = request.getParameter("userid");
        if (uid == null || uid.trim().isEmpty()) {
            try {
                response.getWriter().println("Error in LoginServlet: userid is required");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
            return;
        }

        // ৬ ডিজিটের OTP তৈরি করা
        Random rand = new Random();
        int otpValue = 100000 + rand.nextInt(900000);
        String otp = String.valueOf(otpValue);

        String checkSql = "select * from user where userid=?";
        String insertSql = "insert into user(userid, otp, otp_generated_at) values(?,?,NOW())";
        String updateSql = "update user set otp=?, otp_generated_at=NOW() where userid=?";

        try (Connection conn = DBConnect.getConn();
             PreparedStatement psCheck = conn.prepareStatement(checkSql)) {

            psCheck.setString(1, uid);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (!rs.next()) {
                    try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                        psInsert.setString(1, uid);
                        psInsert.setString(2, otp);
                        psInsert.executeUpdate();
                    }
                } else {
                    try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                        psUpdate.setString(1, otp);
                        psUpdate.setString(2, uid);
                        psUpdate.executeUpdate();
                    }
                }
            }

            // ইমেইল পাঠানো
            EmailUtility.sendOTP(uid, otp);

            // সেশন তৈরি করে লগইন প্রক্রিয়া শুরু করা
            HttpSession session = request.getSession();
            session.setAttribute("tempUser", uid);

            // Admin check: configurable via environment variable ADMIN_EMAILS (comma-separated)
            String adminEmails = System.getenv("ADMIN_EMAILS");
            if (adminEmails == null || adminEmails.trim().isEmpty()) {
                adminEmails = System.getProperty("admin.emails", "maitysupriti350@gmail.com");
            }
            System.out.println("LoginServlet: Checking admin list for " + uid + ". Admins=" + adminEmails);
            boolean adminFound = false;
            for (String a : adminEmails.split("\\s*,\\s*")) {
                if (a != null && !a.trim().isEmpty() && uid.equalsIgnoreCase(a.trim())) {
                    adminFound = true;
                    break;
                }
            }
            if (adminFound) {
                // Admins must use the dedicated admin sign-in page
                response.sendRedirect("adminAuth.jsp?notice=use_admin_login");
            } else {
                session.setAttribute("tempUser", uid);
                response.sendRedirect("verifyOTP.jsp");
            }

        } catch (Exception e) {
            // If DBConnect failed it will throw a RuntimeException; report full stack trace server-side
            e.printStackTrace();
            try {
                response.getWriter().println("Error in LoginServlet: " + e.getMessage());
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("auth.jsp");
    }
}