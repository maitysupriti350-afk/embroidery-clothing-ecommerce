package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.conn.DBConnect;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddCartServlet")
public class AddCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pidStr = request.getParameter("pid");
        String size = request.getParameter("size");
        String qtyStr = request.getParameter("qty");
        String removeFromWishlist = request.getParameter("removeWishlist");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }
        String userId = session.getAttribute("user").toString();

        try {
            if (pidStr == null || size == null || qtyStr == null) {
                session.setAttribute("failedMsg", "Please select size and quantity");
                response.sendRedirect("collections.jsp");
                return;
            }

            int pid = Integer.parseInt(pidStr);
            int qty = Integer.parseInt(qtyStr);
            
            try (Connection conn = DBConnect.getConn()) {
                // First, get product details
                String productSql = "SELECT * FROM products WHERE p_id=?";
                try (PreparedStatement ps1 = conn.prepareStatement(productSql)) {
                    ps1.setInt(1, pid);
                    try (ResultSet rs = ps1.executeQuery()) {
                        if (!rs.next()) {
                            session.setAttribute("failedMsg", "Product not found.");
                            response.sendRedirect("collections.jsp");
                            return;
                        }

                        // Check if this product+size already exists in the user's cart
                        String checkCartSql = "SELECT c_id, quantity FROM cart WHERE user_id = ? AND p_id = ? AND size = ?";
                        try (PreparedStatement psCheck = conn.prepareStatement(checkCartSql)) {
                            psCheck.setString(1, userId);
                            psCheck.setInt(2, pid);
                            psCheck.setString(3, size);
                            try (ResultSet rsCart = psCheck.executeQuery()) {
                                if (rsCart.next()) {
                                    // Product already in cart with same size - increment quantity
                                    int existingCartId = rsCart.getInt("c_id");
                                    int existingQty = rsCart.getInt("quantity");
                                    int newQty = existingQty + qty;
                                    String updateCartSql = "UPDATE cart SET quantity = ? WHERE c_id = ?";
                                    try (PreparedStatement psUpdate = conn.prepareStatement(updateCartSql)) {
                                        psUpdate.setInt(1, newQty);
                                        psUpdate.setInt(2, existingCartId);
                                        psUpdate.executeUpdate();
                                    }
                                    session.setAttribute("succMsg", "Cart quantity updated! (" + newQty + " items)");
                                } else {
                                    // New item - insert into cart
                                    String insertCartSql = "INSERT INTO cart(user_id, p_id, p_name, p_price, p_image, size, quantity) VALUES(?,?,?,?,?,?,?)";
                                    try (PreparedStatement ps2 = conn.prepareStatement(insertCartSql)) {
                                        ps2.setString(1, userId);
                                        ps2.setInt(2, rs.getInt("p_id"));
                                        ps2.setString(3, rs.getString("p_name"));
                                        ps2.setBigDecimal(4, rs.getBigDecimal("p_price"));
                                        ps2.setString(5, rs.getString("p_image"));
                                        ps2.setString(6, size);
                                        ps2.setInt(7, qty);
                                        int result = ps2.executeUpdate();
                                        if (result == 1) {
                                            session.setAttribute("succMsg", "Product Added to Cart!");
                                        } else {
                                            session.setAttribute("failedMsg", "Failed to add product!");
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // If coming from wishlist "Move to Bag", remove from wishlist
                if ("true".equals(removeFromWishlist)) {
                    String deleteWishSql = "DELETE FROM wishlist WHERE p_id = ? AND user_id = ?";
                    try (PreparedStatement psDelWish = conn.prepareStatement(deleteWishSql)) {
                        psDelWish.setInt(1, pid);
                        psDelWish.setString(2, userId);
                        psDelWish.executeUpdate();
                    }
                }
            }
            
            response.sendRedirect("cart.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cart.jsp?error=database");
        }
    }
}
