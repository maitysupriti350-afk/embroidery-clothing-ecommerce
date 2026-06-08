<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.conn.DBConnect" %>
<%
    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    int pid = Integer.parseInt(idParam);
    String name = "";
    String desc = "";
    String image = "";
    String category = "";
    java.math.BigDecimal price = null;

    try (Connection conn = DBConnect.getConn();
         PreparedStatement ps = conn.prepareStatement("SELECT p_name, p_desc, p_image, p_price, p_category FROM products WHERE p_id = ?")) {
        ps.setInt(1, pid);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                name = rs.getString("p_name");
                desc = rs.getString("p_desc");
                image = rs.getString("p_image");
                price = rs.getBigDecimal("p_price");
                category = rs.getString("p_category");
            } else {
                response.sendRedirect("index.jsp");
                return;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= name.replaceAll("[<>\"']", "") %> - THE GILDED STITCH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <style>
        .product-page { max-width:1400px; margin:40px auto; display:grid; grid-template-columns: 1fr 1fr; gap:40px; align-items:start; padding: 0 20px; }
        .image-container { position: relative; width: 100%; padding-bottom: 125%; background: #f8f8f8; border-radius: 16px; overflow: hidden; }
        .image-container img { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s ease; }
        .image-container:hover img { transform: scale(1.05); }
        .details h1 { margin-bottom:12px; font-size: 2rem; line-height: 1.2; }
        .category { color:#d7387c; font-weight:700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.5px; }
        .price { color:#b13665; font-weight:800; font-size:1.8rem; margin: 16px 0; }
        .desc { margin-top:16px; color:#6b3a53; line-height: 1.7; font-size: 1rem; }
        .actions { margin-top:24px; display:flex; gap:12px; flex-wrap: wrap; }
        .btn { padding:14px 24px; border-radius:10px; border:none; cursor:pointer; font-weight:700; font-size: 1rem; transition: all 0.3s ease; }
        .btn-add { background:linear-gradient(45deg,#ff8fb8,#ff5da3); color:white; box-shadow: 0 4px 12px rgba(255, 93, 163, 0.3); }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(255, 93, 163, 0.4); }
        .btn-wish { background:#fff5fb; color:#7b2c4e; border:2px solid #f4d0df; }
        .btn-wish:hover { background:#f4d0df; }

        /* Mobile Responsive Styles */
        @media (max-width: 768px) {
            .product-page {
                grid-template-columns: 1fr;
                margin: 20px auto;
                gap: 24px;
                padding: 0 16px;
            }
            
            .image-container {
                border-radius: 12px;
            }
            
            .details h1 {
                font-size: 1.6rem;
            }
            
            .price {
                font-size: 1.5rem;
            }
            
            .desc {
                font-size: 0.95rem;
            }
            
            .actions {
                flex-direction: column;
                gap: 12px;
            }
            
            .btn {
                width: 100%;
                padding: 14px 20px;
                font-size: 1rem;
            }
            
            #review-form textarea {
                min-height: 80px;
                padding: 12px;
                font-size: 14px;
            }
            
            #review-form .star-button {
                font-size: 24px;
                padding: 4px;
            }
        }

        @media (max-width: 480px) {
            .product-page {
                margin: 16px auto;
                gap: 20px;
                padding: 0 12px;
            }
            
            .details h1 {
                font-size: 1.4rem;
            }
            
            .price {
                font-size: 1.3rem;
            }
            
            .desc {
                font-size: 0.9rem;
            }
            
            .btn {
                padding: 12px 16px;
                font-size: 0.95rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="common/header.jsp" %>
    <div class="product-page">
        <div class="image-container">
            <img src="${pageContext.request.contextPath}/product_img/<%= image %>" alt="<%= name.replaceAll("[<>\"']", "") %>" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg'">
        </div>
        <div class="details">
            <div class="category" style="color:#d7387c;font-weight:700"><%= category.replaceAll("[<>\"']", "") %></div>
            <h1><%= name.replaceAll("[<>\"']", "") %></h1>
            <div class="price">₹<%= price %></div>
            <div class="desc"><%= desc.replaceAll("[<>\"']", "") %></div>

            <div class="actions">
                <button class="btn btn-add" onclick="location.href='${pageContext.request.contextPath}/AddCartServlet?p_id=<%= pid %>'">Add to Cart</button>
                <button class="btn btn-wish" onclick="location.href='${pageContext.request.contextPath}/WishlistServlet?p_id=<%= pid %>&action=add'">Add to Wishlist</button>
            </div>
            
            <div id="reviews-section" style="margin-top:22px;">
                <h3>Customer Reviews</h3>
                <div id="review-summary">Loading reviews…</div>
                <div id="review-list" style="margin-top:12px;"></div>

                <div id="review-form" style="margin-top:18px;">
                    <h4>Write a review</h4>
                    <div style="margin:8px 0;">
                        <button type="button" class="star-button" data-rating="1" onclick="setRating(<%= pid %>,1)">★</button>
                        <button type="button" class="star-button" data-rating="2" onclick="setRating(<%= pid %>,2)">★</button>
                        <button type="button" class="star-button" data-rating="3" onclick="setRating(<%= pid %>,3)">★</button>
                        <button type="button" class="star-button" data-rating="4" onclick="setRating(<%= pid %>,4)">★</button>
                        <button type="button" class="star-button" data-rating="5" onclick="setRating(<%= pid %>,5)">★</button>
                        <input type="hidden" id="rating-value-<%= pid %>" value="0">
                    </div>
                    <textarea id="review-text-<%= pid %>" style="width:100%;min-height:90px;padding:10px;border:1px solid #ddd;border-radius:8px;" placeholder="Share your experience..."></textarea>
                    <div style="margin-top:8px;display:flex;gap:8px;">
                        <button class="btn btn-add" type="button" onclick="submitReview(<%= pid %>)">Submit Review</button>
                        <div id="review-feedback-<%= pid %>" style="align-self:center;color:#16a34a"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
            <script>
                function setRating(pid, rating) {
                    const buttons = document.querySelectorAll('#review-form .star-button');
                    buttons.forEach(btn => {
                        const r = Number(btn.dataset.rating);
                        if (r <= rating) btn.style.color = '#ffb400'; else btn.style.color = '#ddd';
                    });
                    const hidden = document.getElementById('rating-value-' + pid);
                    if (hidden) hidden.value = rating;
                }

                function fetchReviewsFor(pid) {
                    fetch('${pageContext.request.contextPath}/AddReviewServlet?p_id=' + pid)
                        .then(r => r.json())
                        .then(data => {
                            const summary = document.getElementById('review-summary');
                            const list = document.getElementById('review-list');
                            if (!data || !data.reviews || data.reviews.length === 0) {
                                if (summary) summary.textContent = 'No reviews yet.';
                                if (list) list.innerHTML = '';
                                return;
                            }
                            if (summary) summary.innerHTML = '<strong>Average:</strong> ' + data.average + ' ★ from ' + data.count + ' review(s)';
                            if (list) {
                                list.innerHTML = '';
                                data.reviews.forEach(r => {
                                    const el = document.createElement('div');
                                    el.style.padding = '10px 0';
                                    el.style.borderBottom = '1px solid #f0f0f0';
                                    el.innerHTML = '<strong>' + (r.user||'Guest') + '</strong> &nbsp; ' + r.rating + ' ★<br><div style="color:#333;margin-top:6px;">' + r.comment + '</div><div style="color:#999;font-size:12px;margin-top:6px;">' + r.date + '</div>';
                                    list.appendChild(el);
                                });
                            }
                        }).catch(err => console.error('fetchReviewsFor error', err));
                }

                function submitReview(pid) {
                    const rating = Number(document.getElementById('rating-value-' + pid).value || 0);
                    const comment = document.getElementById('review-text-' + pid).value.trim();
                    const feedback = document.getElementById('review-feedback-' + pid);
                    if (rating < 1) { feedback.textContent = 'Please choose a rating.'; feedback.style.color = '#b91c1c'; return; }
                    if (!comment) { feedback.textContent = 'Please write a short review.'; feedback.style.color = '#b91c1c'; return; }
                    const body = new URLSearchParams();
                    body.append('p_id', pid);
                    body.append('rating', rating);
                    body.append('comment', comment);
                    fetch('${pageContext.request.contextPath}/AddReviewServlet', { method: 'POST', headers: { 'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8' }, body: body.toString() })
                        .then(r => r.text()).then(txt => {
                            if (txt && txt.trim() === 'success') {
                                feedback.textContent = 'Review submitted.'; feedback.style.color = '#16a34a';
                                document.getElementById('review-text-' + pid).value = '';
                                fetchReviewsFor(pid);
                            } else {
                                feedback.textContent = 'Could not submit review.'; feedback.style.color = '#b91c1c'; console.error(txt);
                            }
                        }).catch(err => { feedback.textContent = 'Network error.'; feedback.style.color = '#b91c1c'; console.error(err); });
                }

                document.addEventListener('DOMContentLoaded', function(){ fetchReviewsFor(<%= pid %>); });
            </script>
</body>
</html>