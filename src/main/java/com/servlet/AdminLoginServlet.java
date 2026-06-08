package com.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uid = request.getParameter("userid");
        String adminKey = request.getParameter("adminKey");
        if (uid == null || adminKey == null || uid.trim().isEmpty() || adminKey.trim().isEmpty()) {
            response.sendRedirect("adminAuth.jsp?error=invalid");
            return;
        }

        String adminEmails = System.getenv("ADMIN_EMAILS");
        if (adminEmails == null || adminEmails.trim().isEmpty()) {
            adminEmails = System.getProperty("admin.emails", "maitysupriti350@gmail.com");
        }

        boolean allowed = false;
        for (String a : adminEmails.split("\\s*,\\s*")) {
            if (a != null && !a.trim().isEmpty() && uid.equalsIgnoreCase(a.trim())) { allowed = true; break; }
        }
        if (!allowed) {
            response.sendRedirect("adminAuth.jsp?error=not_admin");
            return;
        }

        // verify adminKey against env or system property
        String secret = System.getenv("ADMIN_SECRET");
        if (secret == null || secret.trim().isEmpty()) secret = System.getProperty("admin.secret", "admin123");
        if (!secret.equals(adminKey)) {
            response.sendRedirect("adminAuth.jsp?error=bad_key");
            return;
        }

        // success -> set session and redirect to admin dashboard
        HttpSession session = request.getSession();
        session.setAttribute("user", uid);
        session.setAttribute("isAdmin", true);
        session.setAttribute("lastAccessTime", System.currentTimeMillis());
        session.setAttribute("adminIP", request.getRemoteAddr());
        session.setMaxInactiveInterval(30 * 60); // 30 minutes server-side timeout
        response.sendRedirect("adminDashboard.jsp");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("adminAuth.jsp");
    }
}
