package com.utility;

import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtility {
    private static final ExecutorService EMAIL_EXEC = Executors.newFixedThreadPool(2);

    @SuppressWarnings("unused")
    private static void shutdownExecutor() {
        EMAIL_EXEC.shutdown();
        try {
            if (!EMAIL_EXEC.awaitTermination(5, TimeUnit.SECONDS)) {
                EMAIL_EXEC.shutdownNow();
            }
        } catch (InterruptedException ignored) {
            EMAIL_EXEC.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }
    public static void sendOTP(String recipientEmail, String otp) {
       
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        // Try environment variables first
        String myEmail = System.getenv("EMAIL_USER");
        String password = System.getenv("EMAIL_PASS");

        // Fallback to system properties for containers that do not inherit env vars
        if (myEmail == null || myEmail.isEmpty()) {
            myEmail = System.getProperty("email.user");
        }
        if (password == null || password.isEmpty()) {
            password = System.getProperty("email.pass");
        }

        // Fallback to a classpath properties file if still unavailable
        if ((myEmail == null || myEmail.isEmpty()) || (password == null || password.isEmpty())) {
            try (java.io.InputStream in = EmailUtility.class.getResourceAsStream("/email.properties")) {
                if (in != null) {
                    java.util.Properties propsFile = new java.util.Properties();
                    propsFile.load(in);
                    if (myEmail == null || myEmail.isEmpty()) {
                        myEmail = propsFile.getProperty("email.user");
                    }
                    if (password == null || password.isEmpty()) {
                        password = propsFile.getProperty("email.pass");
                    }
                }
            } catch (Exception ignored) {
            }
        }

        if (myEmail == null || myEmail.isEmpty() || password == null || password.isEmpty()) {
            throw new RuntimeException("Email credentials not configured. Set EMAIL_USER and EMAIL_PASS environment variables, or use system properties email.user/email.pass, or provide /email.properties in classpath.");
        }

        final String emailAccount = myEmail;
        final String emailPassword = password;

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailAccount, emailPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(myEmail));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("Heritage Gallery - Login OTP");
            message.setText("Dear User, your verification code is: " + otp);

            Transport.send(message);
            System.out.println("Email Sent Successfully to " + recipientEmail);
        } catch (MessagingException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to send OTP email: " + e.getMessage(), e);
        }
    }

    public static void sendOrderCancellation(String recipientEmail, int orderId) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        String myEmail = System.getenv("EMAIL_USER");
        String password = System.getenv("EMAIL_PASS");
        if (myEmail == null || myEmail.isEmpty()) myEmail = System.getProperty("email.user");
        if (password == null || password.isEmpty()) password = System.getProperty("email.pass");

        if ((myEmail == null || myEmail.isEmpty()) || (password == null || password.isEmpty())) {
            // If email is not configured, just log and skip sending
            System.err.println("Email credentials not configured. Skipping cancellation email to " + recipientEmail);
            return;
        }

        final String emailAccount = myEmail;
        final String emailPassword = password;

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailAccount, emailPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(myEmail));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("Your order #" + orderId + " has been cancelled");
            String html = "<p>Dear Customer,</p>" +
                          "<p>Your order #" + orderId + " has been <strong>cancelled</strong> successfully. If you have any questions, reply to this email.</p>" +
                          "<p>Regards,<br/>THE GILDED STITCH</p>";
            message.setContent(html, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Cancellation email sent to " + recipientEmail + " for order " + orderId);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }

    public static void sendOrderPlaced(String recipientEmail, int orderId) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        String myEmail = System.getenv("EMAIL_USER");
        String password = System.getenv("EMAIL_PASS");
        if (myEmail == null || myEmail.isEmpty()) myEmail = System.getProperty("email.user");
        if (password == null || password.isEmpty()) password = System.getProperty("email.pass");

        if ((myEmail == null || myEmail.isEmpty()) || (password == null || password.isEmpty())) {
            System.err.println("Email credentials not configured. Skipping order placed email to " + recipientEmail);
            return;
        }

        final String emailAccount = myEmail;
        final String emailPassword = password;

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailAccount, emailPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(myEmail));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
            message.setSubject("Your order #" + orderId + " is placed successfully");

            String html = "<div style=\"font-family:Arial,Helvetica,sans-serif;color:#222\">" +
                    "<h2 style=\"color:#8a2140\">Thank you for your order!</h2>" +
                    "<p>We have received your order <strong>#" + orderId + "</strong>. We will notify you when it ships.</p>" +
                    "<hr/>" +
                    "<p style=\"font-size:13px;color:#555\">Regards,<br/>THE GILDED STITCH</p>" +
                    "</div>";

            message.setContent(html, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Order placed email sent to " + recipientEmail + " for order " + orderId);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }

    public static void sendOrderPlacedAsync(final String recipientEmail, final int orderId) {
        EMAIL_EXEC.submit(() -> sendOrderPlaced(recipientEmail, orderId));
    }

    public static void sendOrderStatusUpdateAsync(final String recipientEmail, final int orderId, final String status, final String messageBody) {
        EMAIL_EXEC.submit(() -> {
            try {
                // Build a simple HTML template for status update
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");

                String myEmail = System.getenv("EMAIL_USER");
                String password = System.getenv("EMAIL_PASS");
                if (myEmail == null || myEmail.isEmpty()) myEmail = System.getProperty("email.user");
                if (password == null || password.isEmpty()) password = System.getProperty("email.pass");
                if ((myEmail == null || myEmail.isEmpty()) || (password == null || password.isEmpty())) {
                    System.err.println("Email credentials not configured. Skipping status email to " + recipientEmail);
                    return;
                }

                final String emailAccount = myEmail;
                final String emailPassword = password;

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(emailAccount, emailPassword);
                    }
                });

                Message msg = new MimeMessage(session);
                msg.setFrom(new InternetAddress(myEmail));
                msg.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
                msg.setSubject("Update for order #" + orderId + ": " + status);

                String html = "<div style=\"font-family:Arial,Helvetica,sans-serif;color:#222\">" +
                        "<h3 style=\"color:#8a2140\">Order #" + orderId + " — " + status + "</h3>" +
                        "<p>" + messageBody + "</p>" +
                        "<hr/>" +
                        "<p style=\"font-size:13px;color:#555\">Regards,<br/>THE GILDED STITCH</p>" +
                        "</div>";

                msg.setContent(html, "text/html; charset=utf-8");
                Transport.send(msg);
                System.out.println("Status email sent to " + recipientEmail + " for order " + orderId + " => " + status);
            } catch (MessagingException e) {
                e.printStackTrace();
            }
        });
    }
}
