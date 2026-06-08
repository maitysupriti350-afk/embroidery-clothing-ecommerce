package com.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import com.conn.DBConnect;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Current session-ta khunje ber koro
        HttpSession session = request.getSession(false);
        
        if(session != null) {
            // 2. Clear reward usage for this user so logout resets play chances
            Object u = session.getAttribute("user");
            if (u != null) {
                String userId = u.toString();
                try (Connection conn = DBConnect.getConn();
                     PreparedStatement ps = conn.prepareStatement("DELETE FROM reward_game_usage WHERE user_id = ?")) {
                    ps.setString(1, userId);
                    ps.executeUpdate();
                } catch (Exception ex) {
                    // best-effort: log and continue with logout
                    ex.printStackTrace();
                }
            }
            // 3. Session-er bhetor theke user data muche dao and invalidate
            session.removeAttribute("user");
            session.invalidate();
        }
        
        // 4. Logout hoye gele abr Blue Login page-e pathiye dao
        response.sendRedirect("index.jsp");
    }
}