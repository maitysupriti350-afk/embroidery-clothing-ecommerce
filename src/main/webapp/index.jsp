<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.conn.DBConnect" %>
<%
    boolean isLoggedIn = session.getAttribute("user") != null;
    String searchParam = request.getParameter("search");
    String categoryParam = request.getParameter("category");
    if (searchParam == null) searchParam = "";
    if (categoryParam == null) categoryParam = "";
    String escapedSearch = searchParam.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>THE GILDED STITCH — Premium Ethnic Wear</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">

    <style>
        :root{
            /* Colorful Myntra-inspired color palette with yellow background */
            --bg-primary: #f9e79f;
            --bg-secondary: #f7dc6f;
            --accent-pink: #ff3f6c;
            --accent-magenta: #e91e63;
            --accent-purple: #9c27b0;
            --accent-blue: #2196f3;
            --accent-orange: #ff9800;
            --accent-green: #4caf50;
            --accent-light: #fef9e7;
            --accent-yellow: #f9e79f;
            --accent-orange-box: #ff9800;
            --muted: #9e9e9e;
            --glass-light: rgba(249, 231, 159, 0.95);
            --glass-dark: rgba(249, 231, 159, 0.9);
            --border-glass: rgba(0, 0, 0, 0.1);
            --shadow-glass: 0 2px 8px rgba(0, 0, 0, 0.1);
            --shadow-hover: 0 4px 16px rgba(0, 0, 0, 0.15);
            --max-w: 1440px;
            --content-padding: 48px;
            --section-spacing: 64px;
            --text-primary: #2c3e50;
            --text-secondary: #546e7a;
            --gradient-rainbow: linear-gradient(135deg, #ff3f6c 0%, #e91e63 25%, #9c27b0 50%, #2196f3 75%, #ff9800 100%);
        }

        *{box-sizing:border-box;margin:0;padding:0}
        html,body{height:100%}
        body{
            font-family:'Inter',sans-serif;
            background: var(--bg-primary);
            min-height:100vh;
            color: var(--text-primary);
            -webkit-font-smoothing:antialiased;
            position: relative;
            overflow-x: hidden;
        }
        
        body::before {
            display: none;
        }

        .page-container{max-width:var(--max-w);margin:0 auto;padding:var(--content-padding);width:100%}

        /* Myntra-style Hero Section with Colorful Gradient on Yellow */
        .hero-section { 
            max-width: var(--max-w); 
            margin: var(--section-spacing) auto; 
            padding: 56px; 
            background: linear-gradient(135deg, var(--accent-orange), var(--accent-pink), var(--accent-purple));
            border-radius: 12px;
            border: 2px solid rgba(0, 0, 0, 0.1);
            box-shadow: var(--shadow-hover);
            position: relative;
            overflow: hidden;
            width: 100%;
            min-height: 480px;
        }
        
        .hero-section::before {
            display: none;
        }

        .hero-content { 
            display: grid; 
            grid-template-columns: repeat(2, minmax(0, 1fr)); 
            gap: 56px; 
            align-items: center;
            position: relative;
            z-index: 1;
            min-height: 380px;
        }
        
        .hero-text h1 {
            font-family:'Playfair Display',serif;
            font-size: 3.2rem;
            color: #ffffff;
            margin-bottom: 20px;
            font-weight: 700;
            line-height: 1.15;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        
        .hero-text .subtitle {
            color: rgba(255, 255, 255, 0.95);
            font-size: 1.2rem;
            margin-bottom: 28px;
            line-height: 1.6;
        }
        
        .hero-features {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
            margin-bottom: 32px;
        }
        
        .feature-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 18px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .feature-item i {
            color: var(--accent-orange);
            font-size: 1.5rem;
        }
        
        .feature-item span {
            color: var(--text-primary);
            font-size: 1.05rem;
            font-weight: 500;
        }
        
        .cta-buttons {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        
        .cta-btn {
            padding: 16px 28px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            transition: all 0.3s ease;
            font-size: 1rem;
        }
        
        .cta-btn.primary {
            background: #ffffff;
            color: var(--accent-orange);
            border: none;
        }
        
        .cta-btn.primary:hover {
            background: var(--accent-light);
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        }
        
        .cta-btn.secondary {
            background: rgba(255, 255, 255, 0.25);
            color: #ffffff;
            border: 2px solid #ffffff;
        }
        
        .cta-btn.secondary:hover {
            background: rgba(255, 255, 255, 0.35);
            transform: translateY(-2px);
        }

        .hero-image img { 
            width:100%; 
            height:auto; 
            border-radius: 12px; 
            box-shadow: var(--shadow-hover);
            transition: transform 0.6s ease;
        }
        
        .hero-image img:hover {
            transform: scale(1.02);
        }

        /* Moodboard Banners - Savana Style */
        .moodboard-section {
            max-width: var(--max-w);
            margin: var(--section-spacing) auto;
            padding: 0 var(--content-padding);
        }

        .moodboard-title {
            font-family: 'Inter', sans-serif;
            font-weight: 300;
            font-size: 2rem;
            color: var(--text-primary);
            margin-bottom: 24px;
            letter-spacing: -0.5px;
        }

        .moodboard-container {
            display: flex;
            gap: 16px;
            overflow-x: auto;
            padding: 8px 4px;
            scroll-snap-type: x mandatory;
            -webkit-overflow-scrolling: touch;
            scrollbar-width: none;
        }

        .moodboard-container::-webkit-scrollbar {
            display: none;
        }

        .mood-tag {
            flex: 0 0 auto;
            padding: 14px 28px;
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.08);
            border-radius: 50px;
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            font-weight: 400;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.3s ease;
            scroll-snap-align: start;
            white-space: nowrap;
            letter-spacing: 0.3px;
        }

        .mood-tag:hover {
            background: var(--accent-pink);
            color: #ffffff;
            border-color: var(--accent-pink);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 63, 108, 0.3);
        }

        .mood-tag.active {
            background: var(--accent-pink);
            color: #ffffff;
            border-color: var(--accent-pink);
        }

        .mood-tag i {
            margin-right: 8px;
            font-size: 12px;
        }

        .rewards-panel {
            position: relative;
            margin: var(--section-spacing) auto;
            width: 100%;
            max-width: var(--max-w);
            background: linear-gradient(135deg, var(--accent-pink), var(--accent-magenta));
            border: none;
            border-radius: 12px;
            padding: 40px;
            box-shadow: var(--shadow-hover);
            overflow: hidden;
            z-index: 1;
        }
        
        .rewards-panel::before {
            display: none;
        }
        
        .rewards-panel::after {
            display: none;
        }

        /* Banner Slider */
        .banner-slider { position:relative; overflow:hidden; border-radius:12px; }
        .banner-slider .slide { width:100%; display:block; }
        .banner-slider .slides { display:flex; transition:transform .6s ease; }
        .banner-nav { position:absolute; left:12px; right:12px; bottom:12px; display:flex; justify-content:center; gap:8px; }
        .banner-dot { width:10px;height:10px;border-radius:50%;background:rgba(0,0,0,0.2);cursor:pointer }
        .banner-dot.active{ background:var(--accent-pink); box-shadow:0 6px 18px rgba(255,63,108,0.28)}

        /* Product carousel */
        .product-carousel { position:relative; margin:12px auto 18px; max-width:var(--max-w); }
        .product-list { display:flex; gap:16px; overflow-x:auto; scroll-behavior:smooth; padding:12px; }
        .product-list::-webkit-scrollbar{ height:10px }
        .product-list::-webkit-scrollbar-thumb{ background:rgba(0,0,0,0.12); border-radius:6px }
        .carousel-arrow { position:absolute; top:50%; transform:translateY(-50%); width:40px;height:40px;border-radius:50%;background:rgba(255,255,255,0.85);display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 6px 18px rgba(0,0,0,0.12)}
        .carousel-arrow.left{ left:-10px }
        .carousel-arrow.right{ right:-10px }

        /* Rewards emphasis */
        .reward-btn { font-size:1rem; padding:12px 18px }
        .reward-btn.primary { background: linear-gradient(135deg,#ff66a1,#ff3b8a); color:#fff }
        .spin-anim { width:36px;height:36px;border-radius:50%;display:inline-grid;place-items:center;background:linear-gradient(135deg,#fff,#ffe6f2);box-shadow:0 6px 18px rgba(255,90,154,0.15)}

        .rewards-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 24px;
            margin-bottom: 32px;
            position: relative;
            z-index: 1;
        }

        .reward-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 16px;
        }

        .reward-btn {
            min-width: 120px;
            padding: 12px 16px;
            font-size: 1rem;
            border-radius: 14px;
        }

        .reward-metric {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            margin-top: 20px;
            justify-content: center;
        }

        .metric-card {
            min-width: 160px;
            padding: 18px 20px;
            border-radius: 18px;
            background: rgba(255,255,255,0.12);
            text-align: center;
            color: #fff;
            font-weight: 600;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08);
        }

        .metric-card strong {
            display: block;
            font-size: 1.8rem;
        }

        .reward-card {
            position: relative;
            padding: 14px;
            min-height: 150px;
            border-radius: 18px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.14);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.14);
            overflow: hidden;
        }

        .rewards-title {
            font-family:'Playfair Display',serif;
            color: #fff;
            font-size: 2.6rem;
            margin: 0 0 16px 0;
            text-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
            letter-spacing: -0.5px;
        }

        .reward-status {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 20px;
            border-radius: 16px;
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            color: rgba(255, 255, 255, 0.98);
            font-weight: 700;
            font-size: 0.95rem;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
            position: relative;
            z-index: 1;
        }
        
        .reward-status i {
            font-size: 1.2rem;
        }

        .rewards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(340px, 1fr));
            gap: 28px;
            align-items: stretch;
            position: relative;
            z-index: 1;
            margin-bottom: 12px;
        }

        .reward-card {
            position: relative;
            padding: 32px;
            min-height: 220px;
            border-radius: 24px;
            background: rgba(255,255,255,0.14);
            border: 1px solid rgba(255,255,255,0.24);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255,255,255,0.12);
            overflow: hidden;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
        }
        
        .reward-card:hover {
            background: rgba(255,255,255,0.18);
            border-color: rgba(255,255,255,0.32);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2), inset 0 1px 0 rgba(255,255,255,0.15);
            transform: translateY(-4px);
        }

        .reward-card::before {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at top left, rgba(255, 255, 255, 0.18), transparent 34%);
            pointer-events: none;
        }

        .reward-card h3 {
            position: relative;
            z-index: 1;
            color: #fff;
            margin-bottom: 16px;
            font-size: 1.5rem;
            font-weight: 700;
            letter-spacing: -0.3px;
        }

        .reward-card p {
            position: relative;
            z-index: 1;
            color: rgba(255, 255, 255, 0.95);
            line-height: 1.6;
            margin: 0;
            font-size: 1.05rem;
        }

        .reward-buttons {
            margin-top: 20px;
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
            position: relative;
            z-index: 1;
        }

        .reward-btn {
            padding: 14px 20px;
            border-radius: 14px;
            border: 1px solid rgba(255,255,255,0.3);
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.98), rgba(255, 240, 245, 0.96));
            color: #c2185b;
            font-weight: 700;
            cursor: pointer;
            font-size: 1rem;
            transition: transform 0.25s ease, background 0.25s ease, box-shadow 0.25s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .reward-btn:hover:not(:disabled) {
            transform: translateY(-2px);
            background: linear-gradient(135deg, rgba(255, 255, 255, 1), rgba(255, 235, 238, 1));
            box-shadow: 0 8px 20px rgba(255, 105, 180, 0.3);
        }
        
        .reward-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .reward-metric {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            margin-top: 24px;
            position: relative;
            z-index: 1;
        }

        .metric-card {
            padding: 20px;
            border-radius: 16px;
            background: rgba(255,255,255,0.16);
            border: 1px solid rgba(255,255,255,0.26);
            text-align: center;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1), inset 0 1px 0 rgba(255,255,255,0.1);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            transition: all 0.3s ease;
        }
        
        .metric-card:hover {
            background: rgba(255,255,255,0.2);
            border-color: rgba(255,255,255,0.32);
            transform: translateY(-2px);
        }

        .metric-card strong {
            display: block;
            font-size: 1.8rem;
            color: #fff;
            margin-bottom: 8px;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }
        
        .metric-card {
            color: rgba(255, 255, 255, 0.95);
            font-weight: 600;
            font-size: 0.95rem;
        }

        .game-status {
            margin-top: 16px;
            padding: 14px 16px;
            border-radius: 12px;
            background: rgba(255,255,255,0.12);
            color: rgba(255, 255, 255, 0.95);
            min-height: 50px;
            font-size: 0.93rem;
            line-height: 1.6;
            border: 1px solid rgba(255,255,255,0.18);
            display: flex;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        .discount-level {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-weight: 700;
            color: #fff;
        }

        .discount-level span {
            font-size: 1.1rem;
            color: #ffe6f2;
        }

        .reward-fineprint {
            margin-top: 8px;
            font-size: 0.95rem;
            color: rgba(255,255,255,0.9);
            line-height: 1.5;
        }

        @media(max-width:900px){
            .rewards-grid { grid-template-columns: 1fr; }
            .rewards-title { font-size: 1.8rem; }
            .why-choose { position: static; width: auto; margin: 20px auto 0; grid-template-columns: repeat(2, 1fr) !important; }
        }

        @media(max-width:768px){
            .rewards-header { flex-direction: column; align-items: flex-start; }
            .rewards-title { font-size: 1.6rem; }
            .reward-metric { grid-template-columns: 1fr; }
            .why-choose { position: static; width: auto; margin: 20px auto 0; grid-template-columns: 1fr !important; }
        }

        /* Collections Gallery with Yellow Background and Orange Boxes */
        .collections-gallery {
            max-width: var(--max-w);
            margin: var(--section-spacing) auto;
            padding: 0 var(--content-padding);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 24px;
            align-items: stretch;
        }
        
        .collection-card {
            border: 2px solid rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative;
            border-radius: 12px;
            overflow: hidden;
            display: block;
            background: var(--accent-orange-box);
            box-shadow: var(--shadow-glass);
            text-decoration: none;
            color: inherit;
        }
        
        .collection-card:hover {
            transform: translateY(-8px) !important;
            box-shadow: 0 20px 40px rgba(255, 152, 0, 0.3) !important;
            border-color: rgba(255, 152, 0, 0.5) !important;
        }
        
        .collection-card img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            position: absolute;
            top: 0;
            left: 0;
        }
        
        .collection-card {
            position: relative;
            padding-bottom: 125%;
        }
        
        .collection-card:hover img {
            transform: scale(1.08);
        }
        
        .collection-card span {
            position: absolute;
            left: 20px;
            bottom: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            background: #ffffff;
            color: var(--accent-orange-box);
            font-weight: 800;
            font-size: 1.1rem;
        }

        /* Product Cards with Yellow Background and Orange Boxes */
        .container{
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(300px,1fr));
            gap:32px;
            margin:var(--section-spacing) auto;
            max-width: var(--max-w);
            padding: 0 var(--content-padding);
        }
        
        .product-card{
            background: var(--accent-orange-box);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: var(--shadow-glass);
            display: flex;
            flex-direction: column;
            border: 2px solid rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            min-height: 420px;
        }
        
        .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(255, 152, 0, 0.3);
            border-color: rgba(255, 152, 0, 0.5);
        }
        
        .product-image{position:relative;padding-bottom:125%;overflow:hidden}
        .product-image img{position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover;transition:transform .5s ease}
        .product-card:hover .product-image img{transform:scale(1.05)}
        
        .product-content{padding:28px;display:flex;flex-direction:column;gap:16px}
        .product-title{font-weight:700;color:var(--text-primary);font-size:1.2rem;line-height:1.3}
        .product-price{color: #ffffff;font-weight:800;font-size: 1.35rem}
        
        .product-actions{display:flex;gap:14px;margin-top:auto}
        .action-btn{
            flex:1;
            padding:16px;
            border-radius:8px;
            border: 2px solid rgba(0, 0, 0, 0.1);
            cursor:pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            font-size: 1rem;
            background: #ffffff;
            color: var(--text-primary);
        }
        
        .cart-btn{
            background: #ffffff;
            color: var(--accent-orange-box);
            border: none;
        }
        
        .cart-btn:hover {
            transform: translateY(-2px);
            background: var(--accent-light);
            box-shadow: 0 8px 16px rgba(255, 152, 0, 0.4);
        }
        
        .wishlist-btn{
            background: #ffffff;
            color: var(--text-primary);
        }
        
        .wishlist-btn:hover {
            background: var(--bg-secondary);
            color: var(--accent-orange-box);
        }

        /* Why Choose Cards with Yellow Background and Orange Boxes */
        .why-choose {
            max-width: var(--max-w);
            margin: var(--section-spacing) auto;
            padding: 40px var(--content-padding);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
            border-radius: 12px;
            background: #ffffff;
            border: 2px solid rgba(0, 0, 0, 0.1);
            box-shadow: var(--shadow-hover);
        }
        
        .why-choose > div {
            background: var(--accent-orange-box);
            border: 1px solid rgba(0, 0, 0, 0.1);
            padding: 24px;
            border-radius: 12px;
            box-shadow: var(--shadow-glass);
            transition: all 0.4s ease;
        }
        
        .why-choose > div:hover {
            transform: translateY(-4px);
            border-color: rgba(255, 152, 0, 0.5);
            box-shadow: 0 16px 36px rgba(255, 152, 0, 0.2);
        }

        /* Section spacing improvements */
        section {
            margin: var(--section-spacing) auto;
            max-width: var(--max-w);
        }

        /* Login Modal Styles */
        .login-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }

        .login-modal .modal-content {
            background: #ffffff;
            padding: 40px;
            border-radius: 16px;
            max-width: 480px;
            width: 90%;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .login-modal h2 {
            color: var(--text-primary);
            margin: 0 0 16px 0;
            font-family: 'Playfair Display', serif;
            font-size: 1.8rem;
        }

        .login-modal p {
            color: var(--text-secondary);
            margin: 0 0 24px 0;
            line-height: 1.6;
        }

        .login-modal .modal-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .login-modal .login-link,
        .login-modal .close-link {
            padding: 14px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .login-modal .login-link {
            background: var(--accent-pink);
            color: #ffffff;
        }

        .login-modal .login-link:hover {
            background: var(--accent-magenta);
            transform: translateY(-2px);
        }

        .login-modal .close-link {
            background: #f5f5f5;
            color: var(--text-primary);
        }

        .login-modal .close-link:hover {
            background: #e0e0e0;
        }

        .ai-advisor {
            max-width: var(--max-w);
            margin: var(--section-spacing) auto;
            padding: 40px;
            border-radius: 12px;
            background: var(--accent-orange-box);
            border: 2px solid rgba(0, 0, 0, 0.1);
            box-shadow: var(--shadow-glass);
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 32px;
            align-items: center;
        }

        .ai-advisor .advisor-copy h2 {
            margin: 0 0 16px 0;
            font-family: 'Playfair Display', serif;
            font-size: 2.6rem;
            color: #ffffff;
        }

        .ai-advisor .advisor-copy p {
            color: rgba(255, 255, 255, 0.9);
            line-height: 1.7;
            margin: 0 0 28px 0;
            font-size: 1.1rem;
        }

        .ai-advisor .advisor-copy .badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: #ffd4e8;
            font-size: 0.92rem;
            font-weight: 700;
        }

        .ai-advisor .advisor-panel {
            display: grid;
            gap: 14px;
        }

        .ai-advisor input[type="file"] {
            width: 100%;
            padding: 14px 16px;
            border-radius: 16px;
            border: 1px solid rgba(255, 255, 255, 0.22);
            background: rgba(255, 255, 255, 0.08);
            color: #fff;
            cursor: pointer;
        }

        .ai-advisor button.ai-action {
            width: 100%;
            padding: 14px 18px;
            border-radius: 16px;
            border: none;
            background: linear-gradient(135deg, #d4af37, #f8b400);
            color: #0f0c29;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .ai-advisor button.ai-action:hover {
            transform: translateY(-1px);
            box-shadow: 0 12px 28px rgba(212, 175, 55, 0.25);
        }

        .ai-advisor .ai-results {
            min-height: 180px;
            padding: 18px;
            border-radius: 18px;
            border: 1px solid rgba(255, 255, 255, 0.18);
            background: rgba(15, 12, 41, 0.64);
            color: #fff;
            line-height: 1.7;
            display: grid;
            gap: 12px;
        }

        .ai-advisor .ai-results strong {
            color: #ffd974;
            font-size: 1rem;
        }

        .ai-advisor .ai-results .result-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.16);
            color: #fff;
            font-size: 0.95rem;
        }

        @media(max-width:980px){
            .ai-advisor { grid-template-columns: 1fr; }
        }

        @media(max-width:760px){
            .ai-advisor { padding: 18px; }
            .ai-advisor .advisor-copy h2 { font-size: 1.7rem; }
        }

        /* Quick Access Links - Yellow Background with Orange Boxes */
        .quick-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 18px;
            border-radius: 8px;
            background: var(--accent-orange-box);
            border: 2px solid rgba(0, 0, 0, 0.1);
            text-decoration: none;
            color: #ffffff;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-glass);
        }
        
        .quick-link:hover {
            background: #ffffff;
            border-color: var(--accent-orange-box);
            color: var(--accent-orange-box);
            transform: translateY(-2px);
        }

        /* Filters Section - Yellow Background with Orange Boxes */
        .filters-section {
            max-width: var(--max-w);
            margin: var(--section-spacing) auto;
            padding: 0 var(--content-padding);
        }
        
        .filters-container {
            background: var(--accent-orange-box);
            border: 2px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            padding: 28px;
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
            box-shadow: var(--shadow-glass);
            align-items: center;
        }
        
        .search-box, .category-filter {
            flex: 1;
            min-width: 280px;
        }
        
        .search-box input, .category-filter select {
            width: 100%;
            padding: 16px 20px;
            background: #ffffff;
            border: 2px solid rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            color: var(--text-primary);
            outline: none;
            transition: all 0.3s ease;
            font-size: 16px;
        }
        
        .search-box input::placeholder {
            color: var(--text-secondary);
        }
        
        .search-box input:focus, .category-filter select:focus {
            background: #ffffff;
            border-color: var(--accent-orange-box);
        }
        
        .search-box button {
            background: #ffffff;
            color: var(--accent-orange-box) !important;
            border: none;
            padding: 16px 28px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 16px;
        }
        
        .search-box button:hover {
            transform: translateY(-2px);
            background: var(--accent-light);
            box-shadow: 0 8px 16px rgba(255, 152, 0, 0.4);
        }

        @media(max-width:900px){
            .hero-content { grid-template-columns: 1fr; }
            .hero-text h1 { font-size: 2.2rem; }
            .cta-buttons { flex-direction: column; }
            .collections-gallery { grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
            .container { grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
        }

        @media(max-width:768px){
            .hero-section { margin: 20px auto; padding: 24px; min-height: auto; }
            .hero-content { gap: 32px; min-height: auto; }
            .hero-text h1 { font-size: 1.8rem; line-height: 1.2; }
            .hero-text p { font-size: 0.95rem; }
            .filters-container { flex-direction: column; }
            .why-choose { grid-template-columns: 1fr; }
            .page-container { padding: 24px; }
        }

        @media(max-width:480px){
            .hero-section { padding: 20px; margin: 16px auto; }
            .hero-text h1 { font-size: 1.5rem; }
            .hero-text p { font-size: 0.9rem; }
            .cta-buttons { gap: 12px; }
            .cta-buttons a { padding: 12px 20px; font-size: 0.9rem; }
            .collections-gallery { grid-template-columns: 1fr; gap: 16px; }
            .container { grid-template-columns: 1fr; gap: 24px; }
            .page-container { padding: 16px; }
            .filters-container { padding: 20px; }
            .search-box, .category-filter { min-width: 100%; }
            .quick-link { padding: 10px 14px; font-size: 0.85rem; }
        }

        @media(max-width:360px){
            .hero-text h1 { font-size: 1.3rem; }
            .hero-text p { font-size: 0.85rem; }
            .cta-buttons a { padding: 10px 16px; font-size: 0.85rem; }
        }
    </style>

    <script>
        try{
            document.documentElement.classList.remove('theme-amazon','theme-flipkart','theme-myntra');
            document.documentElement.classList.add('theme-nykaa');
        }catch(e){}
    </script>
</head>
<body>
    <%@ include file="common/header.jsp" %>

    

    <!-- Top deal cards removed per request -->

    <!-- PREMIUM HERO SECTION -->
    <div class="hero-section">
        <div class="hero-bg-pattern"></div>
        <div class="hero-content">
            <div class="hero-text">
                <h1>Premium Ethnic Fashion Tailored for You</h1>
                <div class="subtitle">Discover artisanal sarees, elegant kurtis, and statement ensembles designed for modern celebrations.</div>
                <div class="cta-buttons">
                    <a href="${pageContext.request.contextPath}/collections.jsp?col=Trending" class="cta-btn primary">Explore Bestsellers</a>
                    <a href="${pageContext.request.contextPath}/collections.jsp?col=Kurti" class="cta-btn secondary">Shop Kurtis</a>
                </div>
            </div>
            <div class="hero-image">
                <img src="${pageContext.request.contextPath}/product_img/hero_1.jpeg" alt="Premium Ethnic Wear" onerror="this.src='https://via.placeholder.com/800x500?text=Premium+Ethnic+Wear'" style="width:100%;height:auto;border-radius:12px">
            </div>
        </div>
    </div>

    <!-- Moodboard Section - Savana Style -->
    <section class="moodboard-section">
        <h2 class="moodboard-title">Explore by Mood</h2>
        <div class="moodboard-container">
            <div class="mood-tag active" onclick="selectMood(this, 'all')">
                <i class="fas fa-fire"></i> All
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'cottagecore')">
                <i class="fas fa-leaf"></i> Cottagecore Vibes
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'streetwear')">
                <i class="fas fa-bolt"></i> Streetwear Essentials
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'pinterest')">
                <i class="fas fa-heart"></i> Pinterest Aesthetics
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'minimalist')">
                <i class="fas fa-feather"></i> Minimalist Chic
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'bohemian')">
                <i class="fas fa-sun"></i> Bohemian Dreams
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'vintage')">
                <i class="fas fa-clock"></i> Vintage Revival
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'festive')">
                <i class="fas fa-star"></i> Festive Glam
            </div>
            <div class="mood-tag" onclick="selectMood(this, 'casual')">
                <i class="fas fa-coffee"></i> Casual Comfort
            </div>
        </div>
    </section>

    <!-- Why Choose Section -->
    <section class="why-choose">
        <div style="grid-column: 1 / -1; margin-bottom: 24px;">
            <h2 style="color:var(--text-primary);font-family:'Playfair Display',serif;font-size:2.2rem;margin:0 0 16px 0;">Why choose The Gilded Stitch</h2>
            <p style="color:var(--text-secondary);margin:0;max-width:820px;line-height:1.75;font-size:1.05rem;">Luxury craftsmanship, surprise-filled shopping and trusted service make every purchase feel special.</p>
        </div>
        <div>
            <h3 style="margin:0 0 12px;color:var(--text-primary);font-size:1.15rem;">Curated premium wear</h3>
            <p style="margin:0;color:var(--text-secondary);line-height:1.6;">Handpicked fabrics and elegant designs that elevate your festive wardrobe.</p>
        </div>
        <div>
            <h3 style="margin:0 0 12px;color:var(--text-primary);font-size:1.15rem;">Scratch to reveal</h3>
            <p style="margin:0;color:var(--text-secondary);line-height:1.6;">Open the scratcher to uncover surprise coupons and premium styling extras.</p>
        </div>
        <div>
            <h3 style="margin:0 0 12px;color:var(--text-primary);font-size:1.15rem;">Trusted service</h3>
            <p style="margin:0;color:var(--text-secondary);line-height:1.6;">Fast support, easy returns, and a premium shopping experience every time.</p>
        </div>
    </section>

    <!-- COLLECTIONS GALLERY -->
    <div class="collections-gallery">
        <a href="${pageContext.request.contextPath}/collections.jsp?col=Saree" class="collection-card">
            <img src="${pageContext.request.contextPath}/product_img/saree_1.jpeg" alt="Sarees" onerror="this.src='https://via.placeholder.com/400x280?text=Sarees'">
            <span>Sarees</span>
        </a>

        <a href="${pageContext.request.contextPath}/collections.jsp?col=Kurti" class="collection-card">
            <img src="${pageContext.request.contextPath}/product_img/kurti_1.jpeg" alt="Kurtis" onerror="this.src='https://via.placeholder.com/400x280?text=Kurtis'">
            <span>Kurtis</span>
        </a>

        <a href="${pageContext.request.contextPath}/collections.jsp?col=Lehenga" class="collection-card">
            <img src="${pageContext.request.contextPath}/product_img/lehenga_1.jpeg" alt="Lehengas" onerror="this.src='https://via.placeholder.com/400x280?text=Lehengas'">
            <span>Lehengas</span>
        </a>

        <a href="${pageContext.request.contextPath}/collections.jsp?col=IndoWestern" class="collection-card">
            <img src="${pageContext.request.contextPath}/product_img/indo_western.jpeg" alt="Indo-Western" onerror="this.src='https://via.placeholder.com/400x280?text=Indo-Western'">
            <span>Indo-Western</span>
        </a>

        <a href="${pageContext.request.contextPath}/collections.jsp?col=Trending" class="collection-card">
            <img src="${pageContext.request.contextPath}/product_img/indowestern_2.jpeg" alt="Trending" onerror="this.src='https://via.placeholder.com/400x280?text=Trending'">
            <span>Trending</span>
        </a>
    </div>

        <section id="featured-dresses" style="max-width:var(--max-w);margin:var(--section-spacing) auto;padding:0 var(--content-padding);">
            <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:20px;margin-bottom:32px;">
                <div>
                    <h2 style="font-family:'Playfair Display',serif;font-size:2.6rem;color:var(--accent-orange-box);margin:0;">Featured Dresses</h2>
                    <p style="margin:12px 0 0;color:var(--text-secondary);font-size:1.1rem;">Discover our latest dresses crafted for elegance and comfort.</p>
                </div>
                <a href="${pageContext.request.contextPath}/collections.jsp?col=Kurti" class="cta-btn secondary" style="padding:16px 28px;">Shop Dresses</a>
            </div>
            <div class="container">
                <div class="product-card">
                    <div class="product-image">
                        <img src="${pageContext.request.contextPath}/product_img/kurti_1.jpeg" alt="Embroidered Kurti">
                    </div>
                    <div class="product-content">
                        <div class="product-title">Embroidered Kurti Dress</div>
                        <div class="product-price">₹1,299</div>
                        <div style="color:var(--text-secondary);">Fine threadwork with a comfortable fit.</div>
                        <div class="product-actions">
                            <button class="action-btn cart-btn" onclick="addToCart(event, 101,'Embroidered Kurti Dress',1299)">Add to Cart</button>
                            <button class="action-btn wishlist-btn" onclick="addToWishlist(event, 101)">Wishlist</button>
                        </div>
                    </div>
                </div>
                <div class="product-card">
                    <div class="product-image">
                        <img src="${pageContext.request.contextPath}/product_img/kurti_2.jpeg" alt="Designer Kurti Dress">
                    </div>
                    <div class="product-content">
                        <div class="product-title">Designer Kurti Dress</div>
                        <div class="product-price">₹1,599</div>
                        <div style="color:var(--text-secondary);">Modern silhouettes crafted for everyday elegance.</div>
                        <div class="product-actions">
                            <button class="action-btn cart-btn" onclick="addToCart(event, 102,'Designer Kurti Dress',1599)">Add to Cart</button>
                            <button class="action-btn wishlist-btn" onclick="addToWishlist(event, 102)">Wishlist</button>
                        </div>
                    </div>
                </div>
                <div class="product-card">
                    <div class="product-image">
                        <img src="${pageContext.request.contextPath}/product_img/indo_western.jpeg" alt="Indo-Western Dress">
                    </div>
                    <div class="product-content">
                        <div class="product-title">Indo-Western Dress</div>
                        <div class="product-price">₹2,199</div>
                        <div style="color:var(--text-secondary);">A fusion dress for festive evenings and special occasions.</div>
                        <div class="product-actions">
                            <button class="action-btn cart-btn" onclick="addToCart(event, 103,'Indo-Western Dress',2199)">Add to Cart</button>
                            <button class="action-btn wishlist-btn" onclick="addToWishlist(event, 103)">Wishlist</button>
                        </div>
                    </div>
                </div>
                <div class="product-card">
                    <div class="product-image">
                        <img src="${pageContext.request.contextPath}/product_img/indowestern_2.jpeg" alt="Fusion Dress">
                    </div>
                    <div class="product-content">
                        <div class="product-title">Fusion Dress</div>
                        <div class="product-price">₹1,899</div>
                        <div style="color:var(--text-secondary);">Versatile styling for day-to-night celebrations.</div>
                        <div class="product-actions">
                            <button class="action-btn cart-btn" onclick="addToCart(event, 104,'Fusion Dress',1899)">Add to Cart</button>
                            <button class="action-btn wishlist-btn" onclick="addToWishlist(event, 104)">Wishlist</button>
                        </div>
                    </div>
                </div>
            </div>
        </section>

    <!-- QUICK ACCESS ACTIONS -->
    <div class="quick-access" style="max-width:var(--max-w);margin:var(--section-spacing) auto;padding:16px var(--content-padding);display:flex;gap:16px;align-items:center;justify-content:center;flex-wrap:wrap">
        <% if (session.getAttribute("user") == null) { %>
            <a href="${pageContext.request.contextPath}/auth.jsp" class="quick-link" style="display:flex;align-items:center;gap:12px;padding:14px 24px;border-radius:8px;background:var(--accent-orange-box);border:2px solid rgba(0,0,0,0.1);text-decoration:none;color:#ffffff;font-weight:600;font-size:1rem;box-shadow:var(--shadow-glass)"> <i class="fas fa-user"></i> Sign in</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/profile.jsp" class="quick-link" style="display:flex;align-items:center;gap:12px;padding:14px 24px;border-radius:8px;background:var(--accent-orange-box);border:2px solid rgba(0,0,0,0.1);text-decoration:none;color:#ffffff;font-weight:600;font-size:1rem;box-shadow:var(--shadow-glass)"> <i class="fas fa-user-circle"></i> My Profile</a>
            <a id="signOutLink" href="${pageContext.request.contextPath}/LogoutServlet" class="quick-link" style="display:flex;align-items:center;gap:12px;padding:14px 24px;border-radius:8px;background:var(--accent-orange-box);border:2px solid rgba(0,0,0,0.1);text-decoration:none;color:#ffffff;font-weight:600;font-size:1rem;box-shadow:var(--shadow-glass)"> <i class="fas fa-sign-out-alt"></i> Sign out</a>
        <% } %>

        <a href="${pageContext.request.contextPath}/cart.jsp" class="quick-link" style="display:flex;align-items:center;gap:12px;padding:14px 24px;border-radius:8px;background:#ffffff;color:var(--accent-orange-box);text-decoration:none;box-shadow:var(--shadow-glass);font-weight:600;font-size:1rem"> <i class="fas fa-shopping-cart"></i> Cart</a>
        <a href="${pageContext.request.contextPath}/wishlist.jsp" class="quick-link" style="display:flex;align-items:center;gap:12px;padding:14px 24px;border-radius:8px;background:var(--accent-orange-box);border:2px solid rgba(0,0,0,0.1);text-decoration:none;color:#ffffff;font-weight:600;font-size:1rem;box-shadow:var(--shadow-glass)"> <i class="fas fa-heart"></i> Wishlist</a>
        <a href="${pageContext.request.contextPath}/OrdersServlet" class="quick-link" style="display:flex;align-items:center;gap:12px;padding:14px 24px;border-radius:8px;background:var(--accent-orange-box);border:2px solid rgba(0,0,0,0.1);text-decoration:none;color:#ffffff;font-weight:600;font-size:1rem;box-shadow:var(--shadow-glass)"> <i class="fas fa-box"></i> Orders</a>
    </div>

    <!-- Our Promise Section -->
    <div style="max-width:var(--max-w);margin:var(--section-spacing) auto;padding:32px var(--content-padding);border-radius:12px;background:var(--accent-orange-box);border:2px solid rgba(0,0,0,0.1);box-shadow:var(--shadow-glass);text-align:center;">
        <h3 style="color:#ffffff;margin:0 0 16px 0;font-size:1.8rem;font-weight:700">Our Promise</h3>
        <p style="color:rgba(255,255,255,0.9);margin:0;font-size:1.15rem;line-height:1.7">Handpicked premium pieces, careful craftsmanship, and a service experience built around you.</p>
    </div>

    <!-- FILTERS SECTION -->
    <div class="filters-section">
        <div class="filters-container">
            <div class="search-box">
                <form style="display: flex; align-items: center; width: 100%;" method="get" action="${pageContext.request.contextPath}/index.jsp">
                    <input type="text" name="search" placeholder="Search premium ethnic wear..." value="<%= escapedSearch %>">
                    <button type="submit"><i class="fas fa-search"></i></button>
                </form>
            </div>

            <div class="category-filter">
                <form method="get" action="${pageContext.request.contextPath}/index.jsp" style="display: flex; gap: 10px;">
                    <select name="category" onchange="this.form.submit()">
                        <option value="">All Categories</option>
                        <option value="Saree" <%= "Saree".equals(categoryParam) ? "selected" : "" %>>Sarees</option>
                        <option value="Kurti" <%= "Kurti".equals(categoryParam) ? "selected" : "" %>>Kurtis</option>
                        <option value="Lehenga" <%= "Lehenga".equals(categoryParam) ? "selected" : "" %>>Lehengas</option>
                        <option value="Suit" <%= "Suit".equals(categoryParam) ? "selected" : "" %>>Suits</option>
                        <option value="Churidar" <%= "Churidar".equals(categoryParam) ? "selected" : "" %>>Churidars</option>
                    </select>
                </form>
            </div>
        </div>
    </div>

    <!-- LOGIN REQUIRED MODAL -->
    <div id="loginModal" class="login-modal">
        <div class="modal-content">
            <h2><i class="fas fa-user-circle"></i> Login Required</h2>
            <p>Please sign in to add items to your cart or wishlist and enjoy our premium shopping experience</p>
            <div class="modal-buttons">
                <a href="${pageContext.request.contextPath}/auth.jsp" class="login-link">
                    <i class="fas fa-sign-in-alt"></i> Sign In / Register
                </a>
                <a href="#" class="close-link" onclick="closeLoginModal(); return false;">
                    <i class="fas fa-times"></i> Continue Shopping
                </a>
            </div>
        </div>
    </div>
    
    <!-- Store login status for JavaScript -->
    <div id="pageState" data-logged-in="<%= isLoggedIn %>" style="display:none;"></div>

    <%@ include file="common/footer.jsp" %>

    <script>
        // Get login status from data attribute
        const isUserLoggedIn = document.getElementById('pageState').dataset.loggedIn === 'true';

        function addToCart(evt, productId, productName, price) {
            if (!isUserLoggedIn) {
                showLoginModal();
            } else {
                // Add loading state
                const btn = evt.target.closest('.cart-btn');
                if (btn) {
                    const originalText = btn.innerHTML;
                    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
                    btn.disabled = true;
                }

                // Simulate API call
                setTimeout(() => {
                    window.location.href = "${pageContext.request.contextPath}/AddCartServlet?p_id=" + productId;
                }, 500);
            }
        }

        function addToWishlist(evt, productId) {
            if (!isUserLoggedIn) {
                showLoginModal();
            } else {
                const btn = evt.target.closest('.wishlist-btn');
                if (btn) {
                    const originalText = btn.innerHTML;
                    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
                    btn.disabled = true;
                }

                setTimeout(() => {
                    window.location.href = "${pageContext.request.contextPath}/WishlistServlet?p_id=" + productId + "&action=add";
                }, 500);
            }
        }

        function filterCategory(category) {
            window.location.href = "${pageContext.request.contextPath}/index.jsp?category=" + category;
        }

        function showLoginModal() {
            document.getElementById('loginModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeLoginModal() {
            document.getElementById('loginModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            var modal = document.getElementById('loginModal');
            if (event.target === modal) {
                closeLoginModal();
            }
        }

        // Add smooth scrolling
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Add loading animation to category cards
        document.querySelectorAll('.category-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-8px) scale(1.02)';
            });

            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });

        // Add intersection observer for animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // Observe product cards for animation
        document.querySelectorAll('.product-card, .category-card').forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(card);
        });

        // Browse widget behavior
        (function() {
            const toggle = document.getElementById('browseToggle');
            const dropdown = document.getElementById('browseDropdown');
            const featuresPanel = document.getElementById('browse-features');
            const titleEl = document.getElementById('browse-title');
            const contentEl = document.getElementById('browse-content');

            if (toggle) {
                toggle.addEventListener('click', function(e) {
                    e.stopPropagation();
                    if (dropdown.style.display === 'block') {
                        dropdown.style.display = 'none';
                        dropdown.setAttribute('aria-hidden', 'true');
                    } else {
                        dropdown.style.display = 'block';
                        dropdown.setAttribute('aria-hidden', 'false');
                    }
                });
            }

            // Close dropdown when clicking outside
            document.addEventListener('click', function(e) {
                if (dropdown && !dropdown.contains(e.target) && !toggle.contains(e.target)) {
                    dropdown.style.display = 'none';
                    dropdown.setAttribute('aria-hidden', 'true');
                }
            });

            window.showBrowse = function(feature) {
                dropdown.style.display = 'none';
                dropdown.setAttribute('aria-hidden', 'true');

                let heading = '';
                let items = [];
                if (feature === 'bestsellers') {
                    heading = 'Bestsellers';
                    items = [
                        {img: 'product_img/kurti_1.jpeg', title: 'Embroidered Kurti', price: '₹1,299'},
                        {img: 'product_img/saree_1.jpeg', title: 'Silk Saree', price: '₹3,499'},
                        {img: 'product_img/lehenga_1.jpeg', title: 'Lehenga Set', price: '₹4,999'}
                    ];
                } else if (feature === 'new-releases') {
                    heading = 'New Releases';
                    items = [
                        {img: 'product_img/indo_western.jpeg', title: 'Indo-Western', price: '₹2,199'},
                        {img: 'product_img/indowestern_2.jpeg', title: 'Fusion Dress', price: '₹1,899'},
                        {img: 'product_img/kurti_2.jpeg', title: 'Designer Kurti', price: '₹1,599'}
                    ];
                } else if (feature === 'movers-shakers') {
                    heading = 'Movers & Shakers';
                    items = [
                        {img: 'product_img/saree_3.jpeg', title: 'Trending Saree', price: '₹2,799'},
                        {img: 'product_img/lehenga_3.jpeg', title: 'Party Lehenga', price: '₹5,299'},
                        {img: 'product_img/orange.jpeg', title: 'Statement Piece', price: '₹2,099'}
                    ];
                }

                titleEl.textContent = heading;
                contentEl.innerHTML = '';
                items.forEach(it => {
                    const card = document.createElement('div');
                    card.className = 'browse-card';
                    card.innerHTML = `<img src="${it.img}" alt="${it.title}" onerror="this.src='https://via.placeholder.com/300x180?text=Product'"/>` +
                                     `<div class=\"browse-title\" style=\"font-weight:700;color:#3d1729;margin-bottom:6px\">${it.title}</div>` +
                                     `<div style=\"color:#b13665;font-weight:700\">${it.price}</div>`;
                    contentEl.appendChild(card);
                });

                featuresPanel.style.display = 'block';
                featuresPanel.scrollIntoView({behavior: 'smooth', block: 'start'});
            };
        })();

        // Moodboard Selection Function
        function selectMood(element, mood) {
            // Remove active class from all mood tags
            document.querySelectorAll('.mood-tag').forEach(tag => {
                tag.classList.remove('active');
            });
            
            // Add active class to clicked tag
            element.classList.add('active');
            
            // Filter products based on mood (for future implementation)
            console.log('Selected mood:', mood);
            
            // Smooth scroll to collections section
            const collectionsSection = document.querySelector('.collections-gallery');
            if (collectionsSection) {
                collectionsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }

        function analyzeStylePhoto() {
            const fileInput = document.getElementById('styleUpload');
            const resultPanel = document.getElementById('aiResults');
            const file = fileInput.files[0];

            if (!file) {
                resultPanel.innerHTML = '<strong>Please choose a photo first.</strong><p>Select an image to see the premium styling recommendation.</p>';
                return;
            }

            const reader = new FileReader();
            resultPanel.innerHTML = '<strong>Analyzing your look...</strong><p>Please wait while our AI style assistant evaluates the image.</p>';

            reader.onload = function() {
                const options = [
                    {
                        title: 'Elegant Anarkali Match',
                        note: 'This image suggests a soft, graceful silhouette. A flowing anarkali with rich embroidery will accentuate your poise.',
                        badges: ['Best for formal events', 'Flattering waistline', 'Soft jewel tones']
                    },
                    {
                        title: 'Chic Fusion Fit',
                        note: 'A contemporary indo-western dress will complement your structure and create a polished, confidence-boosting look.',
                        badges: ['Ideal for evening parties', 'Textured fabrics', 'Modern drape']
                    },
                    {
                        title: 'Luxury Saree Styling',
                        note: 'A premium silk saree with contrast blouse will highlight your silhouette and add a premium finish to your look.',
                        badges: ['Perfect for celebrations', 'Elegant drape', 'High-fashion statement']
                    }
                ];

                const outcome = options[Math.floor(Math.random() * options.length)];
                resultPanel.innerHTML = `
                    <strong>${outcome.title}</strong>
                    <p>${outcome.note}</p>
                    <div class="result-chip"><i class="fas fa-check-circle"></i> ${outcome.badges[0]}</div>
                    <div class="result-chip"><i class="fas fa-check-circle"></i> ${outcome.badges[1]}</div>
                    <div class="result-chip"><i class="fas fa-check-circle"></i> ${outcome.badges[2]}</div>
                `;
            };
            reader.readAsDataURL(file);
        }
    </script>
    <script>
        // Clear reward-related localStorage keys on sign out
        (function attachSignOutHandler(){
            const signOut = document.getElementById('signOutLink');
            if (!signOut) return;
            signOut.addEventListener('click', function(e){
                try {
                    localStorage.removeItem('gildedStitchRewardPoints');
                    localStorage.removeItem('gildedStitchScratchCoupon');
                    localStorage.removeItem('gildedStitchLastSpin');
                } catch(err) { console.error('Error clearing reward storage on sign-out', err); }
                // allow link to continue to LogoutServlet
            });
        })();
    </script>
    <script>
        (function(){
            try{
                const slides = document.querySelectorAll('.banner-slider .slide');
                if(!slides || slides.length===0) return;
                slides.forEach(s=>{ s.style.transition='opacity 0.6s ease'; s.style.opacity=0; s.style.display='none'; });
                let i=0; slides[0].style.display='block'; slides[0].style.opacity=1;
                setInterval(()=>{
                    slides[i].style.opacity=0;
                    setTimeout(()=>{ slides[i].style.display='none'; i=(i+1)%slides.length; slides[i].style.display='block'; setTimeout(()=>slides[i].style.opacity=1,50); }, 650);
                }, 4500);
            }catch(e){console.error(e)}
        })();
        
        // Product carousel scrolling
        function scrollProducts(dir){
            const list = document.getElementById('productList');
            if(!list) return;
            const card = list.querySelector('.product-card');
            const step = (card? card.offsetWidth+16 : 260) * 2;
            list.scrollBy({ left: dir * step, behavior: 'smooth' });
        }
    </script>
</body>
</html>