<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>Spin &amp; Earn Rewards - THE GILDED STITCH</title>
    <style>
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background: radial-gradient(circle at top, #ffe4f0 0%, #f8c2e5 30%, #c7347a 100%);
            color: #271023;
            min-height: 100vh;
        }
        .spinner-page {
            max-width: 1180px;
            margin: 0 auto;
            padding: 20px 24px 40px;
        }
        .spinner-card {
            background: rgba(255,255,255,0.95);
            border-radius: 32px;
            box-shadow: 0 24px 60px rgba(190, 45, 130, 0.18);
            border: 1px solid rgba(255,255,255,0.7);
            overflow: hidden;
        }
        .spinner-hero {
            padding: 42px 38px 28px;
            background: linear-gradient(135deg, #ff8fc4 0%, #d7409f 100%);
            color: #fff;
            text-align: center;
        }
        .spinner-hero h1 {
            margin: 0;
            font-size: 3rem;
            letter-spacing: 0.04em;
            text-shadow: 0 16px 40px rgba(0,0,0,0.16);
        }
        .spinner-hero p {
            margin: 16px auto 0;
            max-width: 720px;
            color: rgba(255,255,255,0.94);
            font-size: 1.05rem;
            line-height: 1.7;
        }
        .spinner-main {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            align-items: center;
            gap: 32px;
            padding: 38px;
        }
        .wheel-container {
            position: relative;
            width: min(420px, 100%);
            margin: 0 auto;
        }
        .wheel {
            width: 100%;
            aspect-ratio: 1 / 1;
            border-radius: 50%;
            position: relative;
            overflow: hidden;
            box-shadow: inset 0 0 0 2px rgba(255,255,255,0.3), 0 30px 60px rgba(0,0,0,0.16);
            transform: rotate(0deg);
            transition: transform 4s cubic-bezier(0.25, 0.1, 0.25, 1);
        }
        .segment {
            position: absolute;
            width: 50%;
            height: 50%;
            top: 0;
            left: 50%;
            transform-origin: 0% 100%;
            display: flex;
            align-items: flex-end;
            justify-content: center;
            padding-bottom: 16px;
            font-weight: 800;
            color: #3f003f;
            font-size: 1.05rem;
            letter-spacing: 0.02em;
            text-shadow: 0 2px 6px rgba(255,255,255,0.18);
        }
        .segment:nth-child(1) { transform: rotate(0deg) skewY(-30deg); background: #fff0f8; }
        .segment:nth-child(2) { transform: rotate(45deg) skewY(-30deg); background: #ffd4ed; }
        .segment:nth-child(3) { transform: rotate(90deg) skewY(-30deg); background: #ffc0e8; }
        .segment:nth-child(4) { transform: rotate(135deg) skewY(-30deg); background: #ff96d1; }
        .segment:nth-child(5) { transform: rotate(180deg) skewY(-30deg); background: #ff76c1; }
        .segment:nth-child(6) { transform: rotate(225deg) skewY(-30deg); background: #f254a3; color: #fff; }
        .segment:nth-child(7) { transform: rotate(270deg) skewY(-30deg); background: #d3237c; color: #fff; }
        .segment:nth-child(8) { transform: rotate(315deg) skewY(-30deg); background: #b70863; color: #fff; }
        .wheel::after {
            content: '';
            position: absolute;
            inset: 50%;
            transform: translate(-50%, -50%);
            width: 24%;
            height: 24%;
            border-radius: 50%;
            background: rgba(255,255,255,0.95);
            box-shadow: inset 0 0 0 4px rgba(255,255,255,0.8);
        }
        .pointer {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-left: 18px solid transparent;
            border-right: 18px solid transparent;
            border-bottom: 48px solid #fff;
            transform: translate(-50%, -110%);
            z-index: 2;
            filter: drop-shadow(0 10px 15px rgba(0,0,0,0.15));
        }
        .spin-panel {
            display: grid;
            gap: 18px;
        }
        .spin-panel h2 {
            margin: 0;
            font-size: 2rem;
            color: #560f4b;
        }
        .reward-badge {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 18px;
            border-radius: 18px;
            background: rgba(255,255,255,0.88);
            border: 1px solid rgba(255,255,255,0.9);
            font-weight: 700;
            color: #56194a;
        }
        .spin-actions {
            display: grid;
            gap: 14px;
        }
        .spin-button {
            border: none;
            border-radius: 18px;
            padding: 16px 22px;
            font-size: 1rem;
            font-weight: 800;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            background: linear-gradient(135deg, #ff5eb8, #d11f76);
            color: #fff;
            box-shadow: 0 18px 32px rgba(208, 34, 120, 0.28);
        }
        .spin-button:hover { transform: translateY(-2px); }
        .spin-button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            box-shadow: none;
        }
        .spin-message {
            padding: 18px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.88);
            border: 1px solid rgba(255,255,255,0.95);
            color: #621064;
            min-height: 96px;
            display: flex;
            align-items: center;
        }
        .spinner-note {
            padding: 28px 38px 38px;
            background: #fff0f9;
            border-top: 1px solid rgba(255,255,255,0.8);
        }
        .spinner-note h3 {
            margin: 0 0 16px;
            font-size: 1.55rem;
            color: #4b0f4a;
        }
        .spinner-note p {
            margin: 10px 0 0;
            line-height: 1.75;
            color: #5a2246;
        }
        @media (max-width: 960px) {
            .spinner-main { grid-template-columns: 1fr; text-align: center; }
            .spinner-main .spin-panel { justify-items: center; }
        }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />
<div class="spinner-page">
    <div class="spinner-card">
        <div class="spinner-hero">
            <h1>Spin &amp; Earn Discount Points</h1>
            <p>Login-only spinner game: spin the wheel, win points, and grow your discount on clothes. The more you spin, the stronger your savings become.</p>
        </div>

        <div class="spinner-main">
            <div class="wheel-container">
                <div class="pointer"></div>
                <div class="wheel" id="spinWheel">
                    <div class="segment">10</div>
                    <div class="segment">14</div>
                    <div class="segment">18</div>
                    <div class="segment">22</div>
                    <div class="segment">26</div>
                    <div class="segment">30</div>
                    <div class="segment">34</div>
                    <div class="segment">40</div>
                </div>
            </div>
            <div class="spin-panel">
                <h2>Ready to spin?</h2>
                <div class="reward-badge">Current points: <span id="toastPoints">0</span></div>
                <div class="spin-actions">
                    <button id="spinButton" class="spin-button">Spin the Wheel</button>
                    <button id="resetSpinnerBtn" class="spin-button" style="background: #ffd1e8; color: #7a1954;">Reset points</button>
                </div>
                <div class="spin-message" id="spinMessage">Press the button to start the spinner and earn points for discounts.</div>
            </div>
        </div>

        <div class="spinner-note">
            <h3>How it works</h3>
            <p>Each spin awards 10–40 points. Points are stored in your browser so the discount counter on the homepage and checkout keeps improving. Redeem your points for extra savings at checkout once you have 20 or more.</p>
        </div>
    </div>
</div>
<jsp:include page="/common/footer.jsp" />
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const rewardStorageKey = 'gildedStitchRewardPoints';
        const rewardResetKey = 'gildedStitchLastSpin';
        const spinWheel = document.getElementById('spinWheel');
        const spinButton = document.getElementById('spinButton');
        const resetButton = document.getElementById('resetSpinnerBtn');
        const toastPoints = document.getElementById('toastPoints');
        const spinMessage = document.getElementById('spinMessage');
        const segmentCount = 8;
        const segmentAngle = 360 / segmentCount;
        const prizes = [10, 14, 18, 22, 26, 30, 34, 40];
        let currentRotation = 0;
        let isSpinning = false;

        function getPoints() {
            return parseInt(localStorage.getItem(rewardStorageKey) || '0', 10);
        }

        function setPoints(points) {
            localStorage.setItem(rewardStorageKey, String(points));
            toastPoints.textContent = points;
        }

        function updateDisplay() {
            toastPoints.textContent = getPoints();
        }

        function canSpin() {
            const lastSpin = parseInt(localStorage.getItem(rewardResetKey) || '0', 10);
            const now = Date.now();
            if (now - lastSpin < 1000 * 20) {
                spinMessage.textContent = 'Please wait 20 seconds before spinning again.';
                return false;
            }
            return true;
        }

        function spin() {
            if (isSpinning) return;
            if (!canSpin()) return;

            isSpinning = true;
            spinButton.disabled = true;
            resetButton.disabled = true;
            spinMessage.textContent = 'Spinning the wheel... good luck!';

            const prizeIndex = Math.floor(Math.random() * prizes.length);
            const prizePoints = prizes[prizeIndex];
            const fullRounds = 6;
            const targetRotation = fullRounds * 360 + prizeIndex * segmentAngle + segmentAngle / 2;
            currentRotation = (currentRotation % 360) + targetRotation;

            spinWheel.style.transition = 'transform 4s cubic-bezier(0.25, 0.1, 0.25, 1)';
            spinWheel.style.transform = 'rotate(' + currentRotation + 'deg)';
            localStorage.setItem(rewardResetKey, String(Date.now()));

            spinWheel.addEventListener('transitionend', function handleEnd() {
                spinWheel.removeEventListener('transitionend', handleEnd);
                const newPoints = getPoints() + prizePoints;
                setPoints(newPoints);
                spinMessage.textContent = 'You won ' + prizePoints + ' points! Your total is now ' + newPoints + ' points.';
                isSpinning = false;
                spinButton.disabled = false;
                resetButton.disabled = false;
            });
        }

        function resetPoints() {
            localStorage.removeItem(rewardStorageKey);
            localStorage.removeItem(rewardResetKey);
            updateDisplay();
            spinMessage.textContent = 'Your points have been reset. Spin again to start earning.';
        }

        spinButton.addEventListener('click', spin);
        resetButton.addEventListener('click', resetPoints);

        updateDisplay();
    });
</script>
</body>
</html>
