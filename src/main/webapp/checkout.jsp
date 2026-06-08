<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.conn.DBConnect, java.math.BigDecimal, java.util.ArrayList, java.util.HashMap, java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>Checkout - THE GILDED STITCH</title>
    <style>
        :root{ --accent:#ec4899; --muted:#6b7280; --card:#ffffff; --glass:rgba(255,255,255,0.75); }
        html,body{height:100%;margin:0;font-family:Inter, Poppins, sans-serif;background:linear-gradient(180deg,#fffafc 0%, #fff6fb 30%, #fff 100%)}
        .checkout-wrap{max-width:1200px;margin:28px auto;padding:18px}
        .top-hero{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:18px}
        .breadcrumbs{color:var(--muted);font-size:13px}
        .hero-title{font-family:'Playfair Display',serif;font-size:28px;color:#2b0b2b;margin:0}
        .hero-sub{color:#5b4450;margin-top:6px}

        .checkout-grid{display:grid;grid-template-columns:1fr 380px;gap:22px}
        @media(max-width:1000px){.checkout-grid{grid-template-columns:1fr}}

        .card{background:var(--card);border-radius:14px;padding:20px;box-shadow:0 12px 30px rgba(34,18,30,0.06)}
        .card h2{margin:0 0 12px 0;font-size:20px;color:#2b0b2b}

        /* Progress steps */
        .steps{display:flex;gap:12px;margin-bottom:18px}
        .step{flex:1;padding:10px 12px;border-radius:10px;background:linear-gradient(90deg,#fff,#fff);border:1px solid #f1e5ee;color:var(--muted);font-weight:700;font-size:13px;text-align:center}
        .step.active{background:linear-gradient(90deg, rgba(236,72,153,0.08), rgba(236,72,153,0.03));border-color:rgba(236,72,153,0.18);color:var(--accent)}

        .field-label{display:block;font-weight:700;margin-bottom:8px;color:#3b2430}
        .field-control{width:100%;padding:12px 14px;border-radius:12px;border:1px solid #ececec;font-size:14px}
        .field-control:focus{outline:none;box-shadow:0 0 0 6px rgba(236,72,153,0.06);border-color:var(--accent)}

        .two-col{display:grid;grid-template-columns:1fr 160px;gap:12px}
        @media(max-width:640px){.two-col{grid-template-columns:1fr}}

        .coupon-row{display:flex;gap:10px}
        .coupon-row .field-control{flex:1}
        .btn{border-radius:12px;border:none;padding:12px 16px;font-weight:800;cursor:pointer}
        .btn-primary{background:var(--accent);color:#fff;box-shadow:0 10px 30px rgba(236,72,153,0.12)}
        .btn-ghost{background:transparent;border:1px dashed #e9d7df;color:#6b7280}

        /* Payment methods */
        .payment-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-top:8px}
        .pay-card{background:#fff;border-radius:10px;padding:12px;border:1px solid #f2e9ef;text-align:center;cursor:pointer;transition:transform .18s ease}
        .pay-card:hover{transform:translateY(-4px)}
        .pay-card.active{border:2px solid var(--accent);box-shadow:0 8px 20px rgba(236,72,153,0.08)}

        /* Summary (sticky) */
        .summary{position:relative}
        .summary .card{position:sticky;top:20px}
        .summary-list{max-height:340px;overflow:auto;padding-right:6px}
        .summary-item{display:flex;gap:10px;align-items:center;padding:10px 0;border-bottom:1px dashed #f3e9ef}
        .summary-item img{width:64px;height:64px;object-fit:cover;border-radius:8px}
        .summary-meta{flex:1}
        .summary-meta .name{font-weight:700;color:#2b0b2b}
        .summary-meta .qty{color:var(--muted);font-size:13px}
        .summary-price{font-weight:800;color:var(--accent)}

        .summary-footer{margin-top:12px}
        .summary-line{display:flex;justify-content:space-between;color:#5b4450;padding:6px 0}
        .total-line{display:flex;justify-content:space-between;font-weight:900;font-size:18px;color:#2b0b2b;margin-top:8px}

        .note{font-size:13px;color:var(--muted);margin-top:10px}
        
        /* Mobile responsiveness improvements */
        @media(max-width:768px){
            .checkout-wrap{margin:16px auto;padding:12px}
            .top-hero{flex-direction:column;align-items:flex-start;gap:8px}
            .hero-title{font-size:22px}
            .checkout-grid{grid-template-columns:1fr;gap:16px}
            .card{padding:16px}
            .payment-grid{grid-template-columns:repeat(2,1fr)}
            .summary .card{position:static}
            .summary-list{max-height:none}
        }
        
        @media(max-width:480px){
            .hero-title{font-size:18px}
            .card{padding:14px}
            .payment-grid{grid-template-columns:1fr}
            .two-col{grid-template-columns:1fr}
            .btn{padding:10px 14px;font-size:14px}
        }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<%
    String userId = null;
    boolean isGuest = false;
    if (session.getAttribute("user") == null) {
        isGuest = true;
        userId = "guest_" + System.currentTimeMillis();
    } else {
        userId = session.getAttribute("user").toString();
    }
    BigDecimal grandTotal = BigDecimal.ZERO;
    String cartTotalValue = "0.00";
    List<Map<String, String>> cartItems = new ArrayList<>();
    String errorMessage = (String) session.getAttribute("failedMsg");
    if (errorMessage != null) {
        session.removeAttribute("failedMsg");
    }
    try (Connection conn = DBConnect.getConn()) {
        boolean retried = false;
        boolean queryCompleted = false;
        while (!queryCompleted) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM cart WHERE user_id = ?")) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BigDecimal price = rs.getBigDecimal("p_price");
                        int qty = rs.getInt("quantity");
                        BigDecimal subtotal = price.multiply(BigDecimal.valueOf(qty));
                        grandTotal = grandTotal.add(subtotal);
                        Map<String, String> item = new HashMap<>();
                        item.put("name", rs.getString("p_name"));
                        item.put("qty", String.valueOf(qty));
                        item.put("subtotal", String.format("%.2f", subtotal));
                        // try to attach image name if exists
                        try { item.put("img", rs.getString("p_image") != null ? rs.getString("p_image") : "product_img/placeholder.png"); } catch(Exception ig) { item.put("img","product_img/placeholder.png"); }
                        cartItems.add(item);
                    }
                    queryCompleted = true;
                }
            } catch (SQLException sqle) {
                if (!retried && sqle.getMessage() != null && sqle.getMessage().contains("Unknown column 'user_id'")) {
                    retried = true;
                    try (Statement stmt = conn.createStatement()) {
                        stmt.executeUpdate("ALTER TABLE `cart` ADD COLUMN `user_id` VARCHAR(255) DEFAULT '' AFTER `c_id`");
                    }
                } else {
                    throw sqle;
                }
            }
        }
        cartTotalValue = String.format("%.2f", grandTotal);
    } catch (Exception e) {
        errorMessage = "Error loading cart: " + e.getMessage();
    }
%>

<div class="checkout-wrap">
    <div class="top-hero">
        <div>
            <div class="breadcrumbs">Home › Cart › <strong>Checkout</strong></div>
            <h1 class="hero-title">Secure Checkout</h1>
            <div class="hero-sub">Fast, secure and delightful — confirm your details to place the order.</div>
        </div>
        <div style="text-align:right">
            <div style="font-size:13px;color:var(--muted)">Estimated total</div>
            <div style="font-weight:900;font-size:20px;color:var(--accent);">₹ <%= cartTotalValue %></div>
        </div>
    </div>

    <div class="checkout-grid">
        <main>
            <div class="card">
                <div class="steps">
                    <div class="step active">1. Delivery</div>
                    <div class="step">2. Payment</div>
                    <div class="step">3. Review</div>
                </div>

                <h2>Delivery information</h2>
                <% if (isGuest) { %>
                    <div style="background: #fffaf6; border: 1px solid #fbefe9; border-radius: 10px; padding: 16px; margin-bottom: 16px;">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
                            <i class="fas fa-user-circle" style="color: #ff9800; font-size: 20px;"></i>
                            <strong style="color: #2b0b2b;">Guest Checkout</strong>
                        </div>
                        <p style="color: #666; font-size: 14px; margin: 0;">No account? No problem! Just provide your details below.</p>
                    </div>
                    <div class="two-col">
                        <div>
                            <label class="field-label" for="guest_name">Full Name *</label>
                            <input type="text" id="guest_name" name="guest_name" class="field-control" required placeholder="Enter your full name">
                        </div>
                        <div>
                            <label class="field-label" for="guest_email">Email *</label>
                            <input type="email" id="guest_email" name="guest_email" class="field-control" required placeholder="Enter your email">
                        </div>
                    </div>
                    <div style="margin-top: 12px;">
                        <label class="field-label" for="guest_phone">Phone Number *</label>
                        <input type="tel" id="guest_phone" name="guest_phone" class="field-control" required placeholder="10-digit mobile number" pattern="[0-9]{10}" maxlength="10">
                    </div>
                <% } %>
                <% if (errorMessage != null) { %>
                    <div style="color:#c62828;font-weight:800;margin-bottom:12px"><%= errorMessage %></div>
                <% } %>
                <form id="checkoutForm" action="${pageContext.request.contextPath}/MockPaymentServlet" method="post">
                    <div class="field-group">
                        <label class="field-label" for="shipping_address">Shipping Address</label>
                        <textarea id="shipping_address" name="shipping_address" class="field-control" rows="4" required placeholder="House number, street, area, city"><%
                            String savedAddress = "";
                            try (Connection addrConn = DBConnect.getConn();
                                 PreparedStatement psAddr = addrConn.prepareStatement("SELECT address FROM user WHERE userid = ?")) {
                                psAddr.setString(1, userId);
                                try (ResultSet rsAddr = psAddr.executeQuery()) {
                                    if (rsAddr.next() && rsAddr.getString("address") != null) {
                                        savedAddress = rsAddr.getString("address");
                                    }
                                }
                            } catch (Exception ignore) {}
                            out.print(savedAddress);
                        %></textarea>
                    </div>

                    <div class="two-col">
                        <div>
                            <label class="field-label" for="shipping_pincode">Pincode</label>
                            <input type="text" id="shipping_pincode" name="shipping_pincode" class="field-control" maxlength="6" inputmode="numeric" pattern="\d{6}" placeholder="6-digit pincode" required>
                        </div>
                        <div style="align-self:end">
                            <button type="button" id="verifyLocationBtn" class="btn btn-ghost" style="width:100%">Verify</button>
                        </div>
                    </div>

                    <div style="margin-top:14px" class="card">
                        <label class="field-label">Apply Coupon</label>
                        <div class="coupon-row">
                            <input type="text" id="coupon_code" name="coupon_code" class="field-control" placeholder="Enter coupon code">
                            <button type="button" id="applyCouponBtn" class="btn btn-primary">Apply</button>
                        </div>
                        <div id="couponStatus" style="margin-top:8px;color:var(--muted);font-weight:700" class="note"></div>
                    </div>

                    <div style="margin-top:14px" class="card">
                        <label class="field-label">Rewards</label>
                        <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
                            <div style="flex:1">
                                <div id="rewardSummary" class="note"><strong id="rewardAvailable">0</strong> points available — <span id="rewardPercentDisplay">0%</span> redeemable</div>
                            </div>
                            <div style="display:flex;gap:8px">
                                <button type="button" id="redeemPointsBtn" class="btn btn-primary">Redeem</button>
                                <button type="button" id="refreshRewardBtn" class="btn btn-ghost">Refresh</button>
                            </div>
                        </div>
                        <div id="rewardStatusMessage" class="note"></div>
                    </div>

                    <div style="margin-top:14px">
                        <label class="field-label">Payment method</label>
                        <div class="payment-grid" id="paymentGrid">
                            <div class="pay-card payment-method-btn" data-method="UPI" onclick="selectPaymentMethod(this,'UPI')">📱<div style="font-weight:700;margin-top:6px">UPI</div><div class="note">Fast &amp; secure</div></div>
                            <div class="pay-card payment-method-btn" data-method="Card" onclick="selectPaymentMethod(this,'Card')">💳<div style="font-weight:700;margin-top:6px">Card</div><div class="note">Visa, Mastercard</div></div>
                            <div class="pay-card payment-method-btn" data-method="Wallet" onclick="selectPaymentMethod(this,'Wallet')">👛<div style="font-weight:700;margin-top:6px">Wallet</div><div class="note">Paytm, Amazon</div></div>
                            <div class="pay-card active payment-method-btn" data-method="COD" onclick="selectPaymentMethod(this,'COD')">🚚<div style="font-weight:700;margin-top:6px">COD</div><div class="note">Pay on delivery</div></div>
                        </div>
                        <div id="paymentDetails" style="display:none;margin-top:10px;padding:12px;border-radius:10px;background:#fff8fb;border-left:4px solid var(--accent)"></div>
                        <input type="hidden" id="payment_method" name="payment_method" value="COD">
                    </div>

                    <input type="hidden" id="location_verified" name="location_verified" value="false">
                    <input type="hidden" id="subtotal" name="subtotal" value="<%= cartTotalValue %>">
                    <input type="hidden" id="discount_amount" name="discount_amount" value="0.00">
                    <input type="hidden" id="reward_points_used" name="reward_points_used" value="0">
                    <input type="hidden" id="reward_discount_percent" name="reward_discount_percent" value="0">
                    <input type="hidden" id="total_amount" name="total_amount" value="<%= cartTotalValue %>">
                    <% if (isGuest) { %>
                        <input type="hidden" id="is_guest" name="is_guest" value="true">
                    <% } %>

                    <div style="display:flex;gap:10px;margin-top:18px;flex-wrap:wrap">
                        <button type="submit" class="btn btn-primary" style="flex:1;padding:14px 18px;font-size:16px">Place Order — ₹ <span id="finalTotalSmall"><%= cartTotalValue %></span></button>
                        <a href="${pageContext.request.contextPath}/cart.jsp" class="btn btn-ghost" style="display:inline-flex;align-items:center;justify-content:center">Back to Cart</a>
                    </div>
                </form>
            </div>
        </main>

        <aside class="summary">
            <div class="card">
                <h2>Order summary</h2>
                <div class="summary-list">
                    <% if (cartItems.isEmpty()) { %>
                        <div style="color:#c62828;font-weight:800">Your cart is empty. Add items to continue.</div>
                    <% } else { %>
                        <% for (Map<String, String> item : cartItems) { %>
                            <div class="summary-item">
                                <img src="${pageContext.request.contextPath}/product_img/<%= item.get("img") %>" onerror="this.src='${pageContext.request.contextPath}/product_img/placeholder.png'" alt="product">
                                <div class="summary-meta">
                                    <div class="name"><%= item.get("name") %></div>
                                    <div class="qty">Qty: <%= item.get("qty") %></div>
                                </div>
                                <div class="summary-price">₹<%= item.get("subtotal") %></div>
                            </div>
                        <% } %>
                    <% } %>
                </div>

                <div class="summary-footer">
                    <div class="summary-line"><span>Subtotal</span><span>₹<%= cartTotalValue %></span></div>
                    <div class="summary-line"><span>Discount</span><span id="discountValue">- ₹0.00</span></div>
                    <div class="summary-line"><span>Delivery</span><span>Free</span></div>
                    <div class="total-line"><span>Order total</span><span id="finalTotal">₹<%= cartTotalValue %></span></div>
                </div>

                <div style="margin-top:12px;padding:12px;border-radius:10px;background:#fffaf6;border:1px solid #fbefe9">
                    <strong>Why choose us?</strong>
                    <div class="note">Fast delivery • Secure payments • Easy returns</div>
                </div>
            </div>
        </aside>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />

<script>
    // Maintain existing JS functionality — adapted for new selectors
    function selectPaymentMethod(el, method) {
        document.querySelectorAll('.payment-method-btn').forEach(b=>b.classList.remove('active'));
        el.classList.add('active');
        document.getElementById('payment_method').value = method;
        const info = {
            'UPI': 'Secure UPI: You will be redirected to your UPI app to complete payment.',
            'Card': 'Secure card payments. We accept Visa, Mastercard and Amex.',
            'Wallet': 'Pay via digital wallets for quick checkout.',
            'COD': 'Pay with cash when your order arrives.'
        };
        const pd = document.getElementById('paymentDetails');
        pd.textContent = info[method] || '';
        pd.style.display = 'block';
    }

    document.addEventListener('DOMContentLoaded', function(){
        // initialize
        const defaultBtn = document.querySelector('.payment-method-btn.active') || document.querySelector('.payment-method-btn');
        if(defaultBtn) selectPaymentMethod(defaultBtn, defaultBtn.dataset.method || 'UPI');

        // reuse earlier functions by id
        if(document.getElementById('verifyLocationBtn')) document.getElementById('verifyLocationBtn').addEventListener('click', verifyLocation);
        if(document.getElementById('applyCouponBtn')) document.getElementById('applyCouponBtn').addEventListener('click', applyCoupon);
        if(document.getElementById('pasteCouponBtn')) document.getElementById('pasteCouponBtn').addEventListener('click', function(){
            var savedCoupon = localStorage.getItem('gildedStitchScratchCoupon');
            var couponInput = document.getElementById('coupon_code');
            var couponStatus = document.getElementById('couponStatus');
            if (savedCoupon) { couponInput.value = savedCoupon; couponStatus.textContent = 'Scratch coupon pasted. Click Apply.'; couponStatus.className='note'; }
            else { if(couponStatus) couponStatus.textContent = 'No scratch coupon found.'; }
        });
        if(document.getElementById('redeemPointsBtn')) document.getElementById('redeemPointsBtn').addEventListener('click', redeemRewardPoints);
        if(document.getElementById('refreshRewardBtn')) document.getElementById('refreshRewardBtn').addEventListener('click', refreshRewardPoints);
        loadRewardData(); updateTotals();

        // Keep final total small updated
        const obs = new MutationObserver(()=>{ var el = document.getElementById('finalTotal'); if(el) document.getElementById('finalTotalSmall').textContent = el.textContent.replace('₹','').trim(); });
        var tEl = document.getElementById('finalTotal'); if(tEl) obs.observe(tEl, {childList:true,subtree:true});
    });

    // --- Original helper functions preserved (applyCoupon, verifyLocation, rewards, totals) ---
    var cartSubtotal = parseFloat('<%= cartTotalValue %>');
    var couponDiscount = 0; var rewardDiscount = 0; var discountAmount = 0; var rewardPoints = 0; var rewardPercent = 0; var rewardPointsUsed = 0;

    function loadRewardData(){ rewardPoints = parseInt(localStorage.getItem('gildedStitchRewardPoints')||'0',10); rewardPercent = Math.min(15, Math.floor(rewardPoints/20)); if(document.getElementById('rewardAvailable')) document.getElementById('rewardAvailable').textContent = rewardPoints + ' points'; if(document.getElementById('rewardPercentDisplay')) document.getElementById('rewardPercentDisplay').textContent = rewardPercent + '%'; }

    function updateTotals(){ discountAmount = couponDiscount + rewardDiscount; var final = cartSubtotal - discountAmount; if(final<0) final=0; if(document.getElementById('discountValue')) document.getElementById('discountValue').textContent = '- ₹' + discountAmount.toFixed(2); if(document.getElementById('finalTotal')) document.getElementById('finalTotal').textContent = '₹' + final.toFixed(2); if(document.getElementById('finalTotalSmall')) document.getElementById('finalTotalSmall').textContent = final.toFixed(2); document.getElementById('discount_amount').value = discountAmount.toFixed(2); document.getElementById('total_amount').value = final.toFixed(2); }

    function redeemRewardPoints(){ if(rewardPoints<20||rewardPointsUsed>0) return; rewardPercent = Math.min(15, Math.floor(rewardPoints/20)); rewardPointsUsed = rewardPercent*20; rewardDiscount = cartSubtotal * rewardPercent/100; localStorage.setItem('gildedStitchRewardPoints', String(rewardPoints - rewardPointsUsed)); if(document.getElementById('rewardStatusMessage')) document.getElementById('rewardStatusMessage').textContent = 'Redeemed '+rewardPointsUsed+' points for '+rewardPercent+'% off.'; loadRewardData(); updateTotals(); }
    function refreshRewardPoints(){ rewardPointsUsed=0; rewardDiscount=0; loadRewardData(); updateTotals(); }

    function applyCoupon(){ var couponInput = document.getElementById('coupon_code'); var couponStatus = document.getElementById('couponStatus'); var code = couponInput.value.trim(); if(!code){ couponDiscount=0; if(couponStatus) couponStatus.textContent='No coupon provided.'; updateTotals(); return; } if(couponStatus) couponStatus.textContent='Checking coupon...'; fetch('${pageContext.request.contextPath}/ValidateCouponServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'coupon_code='+encodeURIComponent(code)+'&subtotal='+encodeURIComponent(cartSubtotal)}).then(r=>r.json()).then(function(data){ if(!data.valid){ couponDiscount=0; if(couponStatus) { couponStatus.textContent=data.message; couponStatus.className='note'; } } else { couponDiscount=parseFloat(data.amount); if(couponStatus){ couponStatus.textContent=data.message; couponStatus.className='note'; } } updateTotals(); }).catch(function(){ couponDiscount=0; if(couponStatus) { couponStatus.textContent='Failed to validate coupon.'; couponStatus.className='note'; } updateTotals(); }); }

    function showLocationValidation(message, success){ var s = document.getElementById('locationStatus'); if(s){ s.textContent = message; s.style.color = success ? '#16a34a' : '#c02828'; } }
    function buildMapUrl(address,pincode){ var q = encodeURIComponent(address+' '+pincode); return 'https://www.google.com/maps?q='+q+'&output=embed'; }
    function verifyLocation(){ var address=document.getElementById('shipping_address').value.trim(); var pincode=document.getElementById('shipping_pincode').value.trim(); var hiddenField=document.getElementById('location_verified'); var mapContainer=document.getElementById('mapContainer'); var iframe=document.getElementById('locationMap'); if(!address){ showLocationValidation('Please enter your address.', false); hiddenField.value='false'; return; } if(!/^\d{6}$/.test(pincode)){ showLocationValidation('Enter a valid 6-digit pincode.', false); hiddenField.value='false'; return; } var pincodeMatched = address.includes(pincode); if(!pincodeMatched){ showLocationValidation('Pincode not found in address.', false); hiddenField.value='false'; return; } showLocationValidation('Pincode matches address.', true); hiddenField.value='true'; if(!iframe){ var cont = document.createElement('div'); cont.id='mapContainer'; cont.style.marginTop='12px'; cont.innerHTML='<iframe id="locationMap" width="100%" height="220" style="border:1px solid #eee;border-radius:8px" loading="lazy"></iframe>'; document.getElementById('checkoutForm').insertBefore(cont, document.getElementById('checkoutForm').children[document.getElementById('checkoutForm').children.length-1]); iframe=document.getElementById('locationMap'); } iframe.src = buildMapUrl(address,pincode); }

    // submit guard
    document.addEventListener('submit', function(e){ if(e.target && e.target.id==='checkoutForm'){ var hf = document.getElementById('location_verified'); if(hf && hf.value!=='true'){ e.preventDefault(); showLocationValidation('Please verify your pincode before placing the order.', false); } } });
</script>
</body>
</html>