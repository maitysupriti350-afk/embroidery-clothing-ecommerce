package com.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import com.google.gson.JsonObject;

@WebServlet("/CreateRazorpayOrderServlet")
public class CreateRazorpayOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();
        
        try {
            String amount = req.getParameter("amount");
            String orderId = req.getParameter("order_id");
            String paymentMethod = req.getParameter("payment_method");
            
            if (amount == null || amount.isEmpty() || orderId == null || orderId.isEmpty()) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("success", false);
                errorResponse.addProperty("error", "Invalid amount or order ID");
                out.print(errorResponse.toString());
                return;
            }
            
            int amountInPaise = Integer.parseInt(amount);
            if (amountInPaise <= 0) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("success", false);
                errorResponse.addProperty("error", "Amount must be greater than 0");
                out.print(errorResponse.toString());
                return;
            }
            
            // Generate Razorpay Order ID (in production, call Razorpay API)
            // For testing, we'll generate a mock order ID
            String razorpayOrderId = "order_" + System.currentTimeMillis();
            
            JsonObject successResponse = new JsonObject();
            successResponse.addProperty("success", true);
            successResponse.addProperty("razorpay_order_id", razorpayOrderId);
            successResponse.addProperty("amount", amountInPaise);
            successResponse.addProperty("order_id", orderId);
            successResponse.addProperty("payment_method", paymentMethod);
            
            out.print(successResponse.toString());
            out.flush();
            
        } catch (NumberFormatException e) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("error", "Invalid amount format");
            out.print(errorResponse.toString());
        } catch (Exception e) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("error", "Error creating order: " + e.getMessage());
            out.print(errorResponse.toString());
            e.printStackTrace();
        }
    }
}
