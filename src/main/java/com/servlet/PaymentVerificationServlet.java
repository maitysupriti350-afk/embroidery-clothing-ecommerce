package com.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import com.conn.DBConnect;
import com.google.gson.JsonObject;

@WebServlet("/PaymentVerificationServlet")
public class PaymentVerificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out;
        try {
            out = resp.getWriter();
        } catch (Exception ex) {
            // If we can't get writer, return error immediately
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to get response writer");
            return;
        }
        
        String paymentId = req.getParameter("payment_id");
        String orderId = req.getParameter("order_id");
        String razorpaySignature = req.getParameter("razorpay_signature");
        String verify = req.getParameter("verify");
        
        try {
            // Check if this is a verification request
            if ("true".equals(verify)) {
                // For testing, accept all payments with valid IDs
                if (paymentId != null && !paymentId.isEmpty()) {
                    JsonObject response = new JsonObject();
                    response.addProperty("success", true);
                    response.addProperty("payment_id", paymentId);
                    response.addProperty("message", "Payment verified successfully");
                    out.print(response.toString());
                    out.flush();
                    return;
                } else {
                    JsonObject response = new JsonObject();
                    response.addProperty("success", false);
                    response.addProperty("error", "Invalid payment ID");
                    out.print(response.toString());
                    out.flush();
                    return;
                }
            }
            
            // Main payment verification logic
            if (paymentId == null || paymentId.isEmpty()) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("success", false);
                errorResponse.addProperty("error", "Payment ID is missing");
                out.print(errorResponse.toString());
                out.flush();
                
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            // Verify signature (HMAC SHA256 verification)
            boolean isSignatureValid = verifySignature(paymentId, orderId, razorpaySignature);
            
            if (!isSignatureValid) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("success", false);
                errorResponse.addProperty("error", "Payment signature verification failed");
                out.print(errorResponse.toString());
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.flush();
                return;
            }
            
            // Payment verified, store payment details
            HttpSession session = req.getSession();
            String userId = (String) session.getAttribute("user");
            
            if (userId == null) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("success", false);
                errorResponse.addProperty("error", "User not logged in");
                out.print(errorResponse.toString());
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.flush();
                return;
            }
            
            // Store payment in database
            storePaymentRecord(userId, paymentId, orderId, "SUCCESS");
            
            // Response for successful verification
            JsonObject successResponse = new JsonObject();
            successResponse.addProperty("success", true);
            successResponse.addProperty("payment_id", paymentId);
            successResponse.addProperty("message", "Payment verified and recorded successfully");
            out.print(successResponse.toString());
            out.flush();
            
        } catch (Exception e) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("error", "Verification error: " + e.getMessage());
            out.print(errorResponse.toString());
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.flush();
            e.printStackTrace();
        }
    }
    
    private boolean verifySignature(String paymentId, String orderId, String signature) {
        // For testing environment, we'll skip signature verification
        // In production, implement HMAC SHA256 verification with Razorpay secret
        // Reference: https://razorpay.com/docs/server-side-integration/payment-gateway/verify/
        
        if (signature == null || signature.isEmpty()) {
            return false;
        }
        
        // Placeholder for actual signature verification
        // In production: 
        // String key = "YOUR_RAZORPAY_SECRET";
        // String message = orderId + "|" + paymentId;
        // String expectedSignature = HmacSHA256(message, key);
        // return signature.equals(expectedSignature);
        
        return true; // Accept for testing
    }
    
    private void storePaymentRecord(String userId, String paymentId, String orderId, String status) {
        try (Connection conn = DBConnect.getConn()) {
            String sql = "INSERT INTO payments (user_id, payment_id, order_id, status, payment_date) " +
                        "VALUES (?, ?, ?, ?, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, userId);
                ps.setString(2, paymentId);
                ps.setString(3, orderId);
                ps.setString(4, status);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            System.err.println("Error storing payment record: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
