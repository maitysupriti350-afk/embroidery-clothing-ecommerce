<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Returns & Refund Policy for THE GILDED STITCH - Learn about our easy return process, refund timeline, and exchange policies.">
    <meta name="keywords" content="returns policy, refund policy, exchange policy, THE GILDED STITCH">
    <title>Returns & Refund Policy - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: #f9e79f;
            color: #2c3e50;
            line-height: 1.6;
        }
        .returns-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 40px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .returns-header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 3px solid #ff9800;
        }
        .returns-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            color: #ff9800;
            margin-bottom: 10px;
        }
        .returns-header p {
            color: #666;
            font-size: 0.95rem;
        }
        .returns-content h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            color: #ff9800;
            margin: 30px 0 15px 0;
        }
        .returns-content h3 {
            font-size: 1.2rem;
            color: #333;
            margin: 20px 0 10px 0;
        }
        .returns-content p {
            margin-bottom: 15px;
            color: #555;
        }
        .returns-content ul {
            margin: 15px 0 15px 30px;
        }
        .returns-content li {
            margin-bottom: 8px;
            color: #555;
        }
        .returns-content strong {
            color: #ff9800;
        }
        .highlight-box {
            background: #fff9e7;
            border-left: 4px solid #ff9800;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .highlight-box p {
            margin: 0;
            color: #333;
        }
        .last-updated {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #888;
            font-size: 0.85rem;
        }
        @media (max-width: 768px) {
            .returns-container {
                margin: 20px auto;
                padding: 24px;
            }
            .returns-header h1 {
                font-size: 1.8rem;
            }
            .returns-content h2 {
                font-size: 1.3rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="common/header.jsp" %>
    
    <div class="returns-container">
        <div class="returns-header">
            <h1>Returns & Refund Policy</h1>
            <p>Last Updated: May 30, 2026</p>
        </div>
        
        <div class="returns-content">
            <div class="highlight-box">
                <p><strong>Our Promise:</strong> At THE GILDED STITCH, we want you to be completely satisfied with your purchase. If you're not happy for any reason, we're here to help make it right.</p>
            </div>
            
            <h2>1. Return Eligibility</h2>
            <p>You can return products within <strong>7 days</strong> of delivery if they meet the following conditions:</p>
            <ul>
                <li>Product is unused, unworn, and in original condition</li>
                <li>All original tags and packaging are intact</li>
                <li>Product is not damaged or soiled</li>
                <li>Return request is made within the specified timeframe</li>
                <li>Original invoice or proof of purchase is provided</li>
            </ul>
            
            <h3>Non-Returnable Items</h3>
            <p>The following items cannot be returned:</p>
            <ul>
                <li><strong>Customized or personalized products</strong></li>
                <li><strong>Items marked as "Final Sale"</strong></li>
                <li><strong>Undergarments and intimate apparel</strong></li>
                <li><strong>Products with damaged or missing tags</strong></li>
                <li><strong>Items used for photoshoots or events</strong></li>
            </ul>
            
            <h2>2. Return Process</h2>
            <h3>How to Initiate a Return</h3>
            <ol>
                <li>Log in to your account on our Website</li>
                <li>Go to "My Orders" and select the order you wish to return</li>
                <li>Click on "Return Request" and select the items</li>
                <li>Choose a reason for return from the dropdown</li>
                <li>Submit your request and wait for confirmation</li>
            </ol>
            
            <h3>Return Confirmation</h3>
            <p>Once your return request is submitted, our team will review it within <strong>24-48 hours</strong>. You will receive an email confirmation with return instructions.</p>
            
            <h2>3. Shipping Returns</h2>
            <h3>Return Shipping</h3>
            <p><strong>Free Return Shipping:</strong> We provide free return shipping for all eligible returns. You will receive a prepaid shipping label via email once your return is approved.</p>
            
            <h3>Packaging Guidelines</h3>
            <p>When returning items, please:</p>
            <ul>
                <li>Use the original packaging if possible</li>
                <li>Securely wrap the item to prevent damage</li>
                <li>Include all original tags and accessories</li>
                <li>Attach the prepaid shipping label on the package</li>
                <li>Drop off the package at the designated courier location</li>
            </ul>
            
            <h2>4. Refund Process</h2>
            <h3>Refund Timeline</h3>
            <p>Once we receive and inspect your returned item:</p>
            <ul>
                <li><strong>Inspection:</strong> 1-2 business days after receipt</li>
                <li><strong>Refund Initiation:</strong> Within 24 hours of approval</li>
                <li><strong>Refund Completion:</strong> 5-7 business days to your original payment method</li>
            </ul>
            
            <h3>Refund Methods</h3>
            <p>Refunds will be processed to the original payment method used for purchase:</p>
            <ul>
                <li><strong>Credit/Debit Card:</strong> Refund to the same card used for purchase</li>
                <li><strong>Net Banking:</strong> Refund to the bank account used for payment</li>
                <li><strong>UPI:</strong> Refund to the UPI ID used for payment</li>
                <li><strong>COD Orders:</strong> Refund via bank transfer or store credit</li>
            </ul>
            
            <h2>5. Exchange Policy</h2>
            <p>We offer <strong>one-time exchange</strong> for eligible products within 7 days of delivery. You can exchange for:</p>
            <ul>
                <li>Different size of the same product</li>
                <li>Different color of the same product</li>
                <li>Product of equal or higher value (you pay the difference)</li>
            </ul>
            
            <p>Exchange requests follow the same process as returns. If the desired item is unavailable, you will be offered a refund or store credit.</p>
            
            <h2>6. Damaged or Defective Items</h2>
            <p>If you receive a damaged or defective product, please contact us within <strong>48 hours</strong> of delivery. We will:</p>
            <ul>
                <li>Arrange for free pickup of the damaged item</li>
                <li>Provide a full refund or replacement at no additional cost</li>
                <li>Cover all shipping costs for the replacement</li>
            </ul>
            
            <p>Please provide photos of the damaged item and packaging to expedite the resolution process.</p>
            
            <h2>7. Cancellation Policy</h2>
            <h3>Order Cancellation</h3>
            <p>You can cancel your order:</p>
            <ul>
                <li><strong>Before Shipping:</strong> Full refund, no questions asked</li>
                <li><strong>After Shipping:</strong> Follow our return policy once delivered</li>
            </ul>
            
            <p>To cancel an order, contact our customer service or use the "Cancel Order" option in your account.</p>
            
            <h2>8. Store Credit</h2>
            <p>As an alternative to refunds, you may choose to receive store credit. Store credit:</p>
            <ul>
                <li>Never expires</li>
                <li>Can be used on any purchase</li>
                <li>Can be combined with other offers</li>
                <li>Is transferable to other customers</li>
            </ul>
            
            <h2>9. Special Circumstances</h2>
            <h3>Festival Season Returns</h3>
            <p>During festival seasons (Diwali, Eid, Christmas, etc.), our return policy may be extended to <strong>14 days</strong> to accommodate gifting needs. Check our website for current seasonal policies.</p>
            
            <h3>International Orders</h3>
            <p>International returns may have different timelines and shipping costs. Please contact our customer service for specific international return policies.</p>
            
            <h2>10. Contact Information</h2>
            <p>If you have any questions about our Returns & Refund Policy, please contact us:</p>
            <ul>
                <li><strong>Email:</strong> returns@thegildedstitch.com</li>
                <li><strong>Phone:</strong> +91-XXXXXXXXXX</li>
                <li><strong>WhatsApp:</strong> +91-XXXXXXXXXX</li>
                <li><strong>Address:</strong> THE GILDED STITCH, [Your Address], India</li>
            </ul>
            
            <h2>11. Policy Updates</h2>
            <p>We reserve the right to modify this Returns & Refund Policy at any time. Changes will be effective immediately upon posting on our Website. Your continued use of our services after changes constitutes acceptance of the revised policy.</p>
            
            <div class="highlight-box">
                <p><strong>Customer Satisfaction Guarantee:</strong> If you're not completely satisfied with our return process, please contact our management team directly at management@thegildedstitch.com. We value your feedback and will do our best to resolve any issues.</p>
            </div>
        </div>
        
        <div class="last-updated">
            <p>This Returns & Refund Policy was last updated on May 30, 2026</p>
        </div>
    </div>
    
    <%@ include file="common/footer.jsp" %>
</body>
</html>
