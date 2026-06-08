<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="promo-bar">Limited time: Free shipping on orders over ₹999 — <a href="#featured">Shop Deals</a></div>
<style>
    /* Critical Mobile Fix - Force Proper Scaling */
    html {
        -webkit-text-size-adjust: 100%;
        -ms-text-size-adjust: 100%;
    }
    
    body {
        margin: 0;
        padding: 0;
        width: 100%;
        max-width: 100%;
        overflow-x: hidden;
    }
    
    * {
        box-sizing: border-box;
    }

    /* Header sizing fixes to avoid tall header from long addresses */
    .global-nav .nav-bar .brand { white-space: nowrap; overflow: hidden; }
    .global-nav .nav-bar .nav-location { max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    /* removed products dropdown/mega-menu for simplified header */
    .search-form input[type="text"]{ min-width: 180px; max-width: 640px; }
    
    @media (max-width: 900px){
        .global-nav .nav-bar { flex-wrap: wrap; gap: 8px; }
        .search-form { flex-basis: 100%; }
        .global-nav .nav-bar .nav-location { max-width: 100%; }
    }

    /* Custom Logo Styles */
    .gilded-stitch-logo {
        display: flex;
        align-items: center;
        gap: 10px;
        font-family: 'Playfair Display', Georgia, serif;
        text-decoration: none;
    }
    
    .logo-icon {
        width: 40px;
        height: 40px;
        background: linear-gradient(135deg, #d4af37 0%, #f4e4bc 50%, #d4af37 100%);
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        color: #1a1a1a;
        box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .logo-icon::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: linear-gradient(45deg, transparent, rgba(255,255,255,0.3), transparent);
        transform: rotate(45deg);
        animation: logoShine 3s infinite;
    }
    
    @keyframes logoShine {
        0% { transform: translateX(-100%) rotate(45deg); }
        100% { transform: translateX(100%) rotate(45deg); }
    }
    
    .logo-text {
        font-size: 15px;
        font-weight: 800;
        color: #d4af37;
        letter-spacing: 1px;
        text-transform: uppercase;
        text-shadow: 0 2px 4px rgba(212, 175, 55, 0.2);
    }
    
    .logo-text span {
        color: #f4e4bc;
    }

    .scratch-launcher {
        position: fixed;
        top: 90px;
        right: 18px;
        z-index: 1100;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 10px 16px;
        border-radius: 999px;
        background: linear-gradient(135deg,#ff3386,#ff91c9);
        color: #fff;
        font-size: 0.95rem;
        font-weight: 700;
        text-decoration: none;
        box-shadow: 0 18px 40px rgba(255,91,155,0.26);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .scratch-launcher:hover {
        transform: translateY(-2px);
        box-shadow: 0 20px 46px rgba(255,91,155,0.38);
    }

    @media (max-width: 900px) {
        .scratch-launcher {
            display: none;
        }
    }

    /* Mobile Menu Toggle */
    .mobile-menu-toggle {
        display: none;
        background: none;
        border: none;
        font-size: 24px;
        color: var(--text);
        cursor: pointer;
        padding: 8px;
        z-index: 1001;
    }

    @media (max-width: 768px) {
        .mobile-menu-toggle {
            display: block;
        }

        .global-nav .nav-bar {
            flex-wrap: nowrap;
            padding: 8px 0;
        }

        .global-nav .nav-bar > div:first-child {
            flex: 1;
            min-width: auto;
        }

        .search-form {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: var(--nav-bg);
            padding: 16px;
            border-bottom: 1px solid var(--border);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            z-index: 1000;
        }

        .search-form.active {
            display: flex;
            flex-direction: column;
        }

        .search-form select,
        .search-form input {
            width: 100%;
            margin-bottom: 8px;
        }

        .search-form button {
            width: 100%;
        }

        .global-nav .nav-bar > div:last-child {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: var(--nav-bg);
            padding: 16px;
            border-bottom: 1px solid var(--border);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            flex-direction: column;
            align-items: stretch;
        }

        .global-nav .nav-bar > div:last-child.active {
            display: flex;
        }

        .global-nav .nav-bar > div:last-child > div,
        .global-nav .nav-bar > div:last-child > a {
            width: 100%;
            text-align: center;
            padding: 12px;
            border-bottom: 1px solid var(--border);
        }

        .global-nav .nav-bar > div:last-child > div > div {
            flex-wrap: wrap;
            justify-content: center;
        }

        .nav-location {
            display: none;
        }
    }
</style>
<%
    String headerSearchParam = request.getParameter("search");
    if (headerSearchParam == null) headerSearchParam = "";
    String headerEscapedSearch = headerSearchParam.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>

<div class="global-nav">
    <div class="nav-bar container-centered" style="display:flex;align-items:center;gap:12px;padding:10px 0;position:relative">
        <button class="mobile-menu-toggle" onclick="toggleMobileMenu()">
            <i class="fas fa-bars"></i>
        </button>
        
        <div style="display:flex;align-items:center;gap:12px;min-width:220px">
            <a class="brand gilded-stitch-logo" href="${pageContext.request.contextPath}/index.jsp" style="text-decoration:none">
                <div class="logo-icon">✦</div>
                <div class="logo-text">Gilded<span>Stitch</span></div>
            </a>
            <!-- products dropdown removed -->
            <div class="nav-location" style="font-size:0.9rem;color:var(--muted)">
                <% String deliverTo = null; try { java.sql.Connection _c = com.conn.DBConnect.getConn(); java.sql.PreparedStatement _ps = _c.prepareStatement("SELECT address FROM user WHERE userid = ?"); if (session.getAttribute("user")!=null) { _ps.setString(1, (String)session.getAttribute("user")); java.sql.ResultSet _rs = _ps.executeQuery(); if(_rs.next()) deliverTo = _rs.getString("address"); _rs.close(); } _ps.close(); _c.close(); } catch(Exception ignore) {} %>
                Deliver to: <strong><%= (deliverTo!=null && !deliverTo.isEmpty())? (deliverTo.length()>30?deliverTo.substring(0,30)+"...":deliverTo):"Select location" %></strong>
            </div>
        </div>

            <form method="get" action="${pageContext.request.contextPath}/index.jsp" class="search-form" style="flex:1;display:flex;gap:8px;align-items:center">
            <select name="category" aria-label="Search category" style="min-width:120px">
                <option value="">All</option>
                <option value="Saree">Sarees</option>
                <option value="Lehenga">Lehengas</option>
                <option value="Kurti">Kurtis</option>
                <option value="Suit">Suits</option>
            </select>
            <input type="text" name="search" placeholder="Search for products, brands and more" value="<%= headerEscapedSearch %>">
            <button class="search-btn" type="submit"><i class="fas fa-search"></i> Search</button>
        </form>

        <div style="display:flex;align-items:center;gap:14px;min-width:220px;justify-content:flex-end">
            <% if (Boolean.TRUE.equals(session.getAttribute("isAdmin"))) { %>
                <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="admin-switch-btn">Admin</a>
            <% } %>

                 <% if (session.getAttribute("user") != null) {
                   String uid = (String) session.getAttribute("user");
            %>
                    <div style="text-align:right;display:flex;flex-direction:column;gap:6px">
                    <div style="font-size:0.9rem;color:var(--muted)">Hello, <strong><%= uid %></strong></div>
                    <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;justify-content:center">
                        <a href="${pageContext.request.contextPath}/profile.jsp" style="font-size:0.85rem;color:var(--accent);text-decoration:none;padding:8px">Profile</a>
                        <a href="${pageContext.request.contextPath}/wishlist.jsp" style="font-size:0.85rem;color:var(--accent);text-decoration:none;padding:8px">Wishlist</a>
                        <a href="${pageContext.request.contextPath}/OrdersServlet" style="font-size:0.85rem;color:var(--accent);text-decoration:none;padding:8px">Orders</a>
                        <a href="${pageContext.request.contextPath}/LogoutServlet" style="font-size:0.85rem;color:var(--accent);text-decoration:none;padding:8px">Sign out</a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/cart.jsp" style="display:flex;align-items:center;gap:8px;padding:8px 12px;background:var(--brand-primary);border-radius:6px;color:#111;font-weight:700;text-decoration:none;justify-content:center"> <i class="fas fa-shopping-cart"></i> Cart</a>
                <a href="${pageContext.request.contextPath}/scratcher.jsp" class="scratch-launcher" aria-label="Scratch &amp; Win">Scratch &amp; Win</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/auth.jsp" style="color:var(--accent);text-decoration:none;font-weight:700;padding:8px">Sign in</a>
                <a href="${pageContext.request.contextPath}/cart.jsp" style="display:flex;align-items:center;gap:8px;padding:8px 12px;background:var(--brand-primary);border-radius:6px;color:#111;font-weight:700;text-decoration:none;justify-content:center"> <i class="fas fa-shopping-cart"></i> Cart</a>
            <% } %>

        </div>
    </div>
</div>

<script>
function toggleMobileMenu() {
    const navRight = document.querySelector('.global-nav .nav-bar > div:last-child');
    const searchForm = document.querySelector('.search-form');
    
    if (navRight) {
        navRight.classList.toggle('active');
    }
    
    if (searchForm) {
        searchForm.classList.toggle('active');
    }
}

// Close mobile menu when clicking outside
document.addEventListener('click', function(e) {
    const nav = document.querySelector('.global-nav');
    const toggle = document.querySelector('.mobile-menu-toggle');
    
    if (nav && !nav.contains(e.target) && !toggle.contains(e.target)) {
        const navRight = document.querySelector('.global-nav .nav-bar > div:last-child');
        const searchForm = document.querySelector('.search-form');
        
        if (navRight) navRight.classList.remove('active');
        if (searchForm) searchForm.classList.remove('active');
    }
});
</script>
