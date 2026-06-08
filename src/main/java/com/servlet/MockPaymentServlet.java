package com.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/MockPaymentServlet")
public class MockPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Read payment selection and forward to payment gateway
        String paymentMethod = req.getParameter("payment_method");
        if (paymentMethod == null) paymentMethod = "COD";

        // Copy parameters to request so payment page can show them
        req.setAttribute("formParams", req.getParameterMap());

        if ("COD".equalsIgnoreCase(paymentMethod)) {
            // For COD, directly forward to PlaceOrderServlet for processing
            req.getRequestDispatcher("/PlaceOrderServlet").forward(req, resp);
            return;
        }

        // For online payments (UPI, Card, Wallet), forward to payment gateway
        // This will integrate with Razorpay or similar payment gateway
        req.getRequestDispatcher("/mockPayment.jsp").forward(req, resp);
    }
}
