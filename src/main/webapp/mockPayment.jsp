<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Payment - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        .payment-container { max-width: 600px; margin: 40px auto; padding: 28px; background: #fff; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); }
        .payment-header { text-align: center; margin-bottom: 28px; }
        .payment-header h2 { margin: 0; color: #111827; font-size: 24px; }
        .payment-info { background: #f0f9ff; border-left: 4px solid #3b82f6; padding: 16px; border-radius: 8px; margin-bottom: 20px; }
        .payment-info h3 { margin: 0 0 12px 0; color: #1e40af; font-size: 16px; }
        .info-row { display: flex; justify-content: space-between; padding: 8px 0; color: #374151; }
        .info-amount { font-weight: 600; color: #111827; }
        .payment-methods { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 24px 0; }
        .method-btn { 
            border: 2px solid #e5e7eb; 
            padding: 16px; 
            border-radius: 10px; 
            background: #f9fafb; 
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }
        .method-btn:hover { 
            border-color: #ec4899; 
            background: #fff5f8;
        }
        .method-btn.active { 
            border-color: #ec4899; 
            background: #fff5f8; 
            box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.1);
        }
        .method-icon { font-size: 24px; margin-bottom: 8px; }
        .method-name { font-weight: 600; color: #111827; font-size: 14px; }
        .pay-btn { 
            width: 100%; 
            background: #ec4899; 
            color: white; 
            border: none; 
            padding: 14px; 
            border-radius: 10px; 
            cursor: pointer; 
            font-weight: 600; 
            font-size: 16px;
            transition: background 0.3s ease;
        }
        .pay-btn:hover { background: #db2777; }
        .pay-btn:disabled { background: #d1d5db; cursor: not-allowed; }
        .security-badge { text-align: center; color: #6b7280; font-size: 12px; margin-top: 16px; }
        .error-msg { color: #dc2626; background: #fee2e2; padding: 12px; border-radius: 6px; margin-bottom: 16px; display: none; }
        .hidden-form { display: none; }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />

<div class="payment-container">
    <div class="payment-header">
        <h2>Complete Your Payment</h2>
        <p style="color: #6b7280; margin: 8px 0 0 0;">Secure &amp; encrypted payment processing</p>
    </div>

    <div class="payment-info">
        <h3>Order Summary</h3>
        <div class="info-row">
            <span>Subtotal:</span>
            <span class="info-amount">₹<%= request.getParameter("subtotal") != null ? request.getParameter("subtotal").replaceAll("[<>\"']", "") : "0.00" %></span>
        </div>
        <div class="info-row">
            <span>Discount:</span>
            <span class="info-amount">- ₹<%= request.getParameter("discount_amount") != null ? request.getParameter("discount_amount").replaceAll("[<>\"']", "") : "0.00" %></span>
        </div>
        <div class="info-row" style="border-top: 1px solid #bfdbfe; padding-top: 12px; margin-top: 12px; font-weight: 600; color: #111827; font-size: 16px;">
            <span>Total Amount:</span>
            <span id="totalAmount">₹<%= request.getParameter("total_amount") != null ? request.getParameter("total_amount").replaceAll("[<>\"']", "") : (request.getParameter("subtotal") != null ? request.getParameter("subtotal").replaceAll("[<>\"']", "") : "0.00") %></span>
        </div>
        <div class="info-row">
            <span>Payment Method:</span>
            <span class="info-amount"><%= request.getParameter("payment_method") != null ? request.getParameter("payment_method").replaceAll("[<>\"']", "") : "" %></span>
        </div>
    </div>

    <div class="error-msg" id="errorMsg"></div>

    <form id="paymentForm" method="post" action="${pageContext.request.contextPath}/PaymentVerificationServlet">
        <div class="payment-methods">
            <button type="button" class="method-btn active" data-method="UPI" onclick="selectPaymentMethod(this, 'UPI')">
                <div class="method-icon">📱</div>
                <div class="method-name">UPI</div>
            </button>
            <button type="button" class="method-btn" data-method="Card" onclick="selectPaymentMethod(this, 'Card')">
                <div class="method-icon">💳</div>
                <div class="method-name">Debit/Credit Card</div>
            </button>
            <button type="button" class="method-btn" data-method="Wallet" onclick="selectPaymentMethod(this, 'Wallet')">
                <div class="method-icon">👛</div>
                <div class="method-name">Digital Wallet</div>
            </button>
            <button type="button" class="method-btn" data-method="NetBanking" onclick="selectPaymentMethod(this, 'NetBanking')">
                <div class="method-icon">🏦</div>
                <div class="method-name">Net Banking</div>
            </button>
        </div>

        <%-- Re-post all original form values as hidden inputs --%>
        <%
            Map<String, String[]> pm = (Map<String, String[]>) request.getParameterMap();
            for (String k : pm.keySet()) {
                String[] vals = pm.get(k);
                if (vals != null) for (String v : vals) {
        %>
        <input type="hidden" name="<%= k %>" value="<%= v %>" />
        <%      }
            }
        %>
        
        <input type="hidden" id="selectedPaymentMethod" name="selected_payment_method" value="UPI" />
        <input type="hidden" id="orderId" name="order_id" value="ORD_<%= UUID.randomUUID().toString().substring(0, 8).toUpperCase() %>" />
        <input type="hidden" id="razorpayOrderId" name="razorpay_order_id" value="" />
        <input type="hidden" id="razorpayPaymentId" name="razorpay_payment_id" value="" />
        <input type="hidden" id="razorpaySignature" name="razorpay_signature" value="" />

        <button type="button" id="payBtn" class="pay-btn" onclick="initiatePayment()">
            Proceed to Payment
        </button>
    </form>

    <div class="security-badge">
        🔒 Your payment is secured with SSL encryption and PCI compliance
    </div>
</div>

<jsp:include page="/common/footer.jsp" />

<!-- Razorpay Checkout Script -->
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
    function selectPaymentMethod(button, method) {
        document.querySelectorAll('.method-btn').forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        document.getElementById('selectedPaymentMethod').value = method;
    }

    function initiatePayment() {
        const totalAmount = document.getElementById('totalAmount').textContent.replace('₹', '').trim();
        const amountInPaise = Math.round(parseFloat(totalAmount) * 100);
        const selectedMethod = document.getElementById('selectedPaymentMethod').value;
        const orderId = document.getElementById('orderId').value;
        const payBtn = document.getElementById('payBtn');

        if (amountInPaise <= 0) {
            showError('Invalid amount. Please contact support.');
            return;
        }

        payBtn.disabled = true;
        payBtn.textContent = 'Processing...';

        // Create Razorpay order on backend
        fetch('${pageContext.request.contextPath}/CreateRazorpayOrderServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'amount=' + amountInPaise + '&order_id=' + orderId + '&payment_method=' + selectedMethod
        })
        .then(res => res.json())
        .then(data => {
            if (data.success && data.razorpay_order_id) {
                openRazorpayCheckout(data.razorpay_order_id, amountInPaise, selectedMethod);
            } else {
                showError(data.error || 'Failed to initiate payment. Please try again.');
                payBtn.disabled = false;
                payBtn.textContent = 'Proceed to Payment';
            }
        })
        .catch(err => {
            showError('Network error. Please try again.');
            console.error(err);
            payBtn.disabled = false;
            payBtn.textContent = 'Proceed to Payment';
        });
    }

    function openRazorpayCheckout(razorpayOrderId, amountInPaise, selectedMethod) {
        const options = {
            key: 'rzp_test_1DP5MMOk9xsZq1', // Test key - Replace with live key in production
            amount: amountInPaise,
            currency: 'INR',
            name: 'THE GILDED STITCH',
            description: 'Clothing Order Payment',
            order_id: razorpayOrderId,
            handler: function(response) {
                document.getElementById('razorpayOrderId').value = razorpayOrderId;
                document.getElementById('razorpayPaymentId').value = response.razorpay_payment_id;
                document.getElementById('razorpaySignature').value = response.razorpay_signature;
                
                // Submit form to verify payment
                verifyPayment(response.razorpay_payment_id, razorpayOrderId);
            },
            prefill: {
                name: 'Customer',
                email: 'customer@example.com',
                contact: '9999999999'
            },
            notes: {
                payment_method: selectedMethod
            },
            theme: {
                color: '#ec4899'
            },
            method: getPaymentMethod(selectedMethod)
        };

        const rzp = new Razorpay(options);
        rzp.on('payment.failed', function(response) {
            showError('Payment Failed: ' + response.error.description);
            document.getElementById('payBtn').disabled = false;
            document.getElementById('payBtn').textContent = 'Proceed to Payment';
        });
        
        rzp.open();
    }

    function getPaymentMethod(selectedMethod) {
        const methodMap = {
            'UPI': { upi: { enabled: true } },
            'Card': { card: { enabled: true } },
            'Wallet': { wallet: { enabled: true } },
            'NetBanking': { netbanking: { enabled: true } }
        };
        return methodMap[selectedMethod] || {};
    }

    function verifyPayment(paymentId, orderId) {
        fetch('${pageContext.request.contextPath}/PaymentVerificationServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'payment_id=' + paymentId + '&order_id=' + orderId + '&verify=true'
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                // Payment verified, submit order form
                document.getElementById('paymentForm').submit();
            } else {
                showError('Payment verification failed. Please contact support.');
                document.getElementById('payBtn').disabled = false;
                document.getElementById('payBtn').textContent = 'Proceed to Payment';
            }
        })
        .catch(err => {
            console.error('Verification error:', err);
            // Even if verification fails on client, submit form for backend verification
            document.getElementById('paymentForm').submit();
        });
    }

    function showError(message) {
        const errorDiv = document.getElementById('errorMsg');
        errorDiv.textContent = message;
        errorDiv.style.display = 'block';
    }
</script>
</body>
</html>
