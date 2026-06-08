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
    <title>Scratch &amp; Win - THE GILDED STITCH</title>
    <style>
        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background: radial-gradient(circle at top left, #ffe4f0 0%, #f5d5f2 30%, #8f2267 100%);
            color: #250a2d;
            min-height: 100vh;
        }
        .scratcher-page {
            max-width: 1080px;
            margin: 0 auto;
            padding: 20px 22px 40px;
        }
        .scratcher-card {
            background: rgba(255,255,255,0.95);
            border-radius: 28px;
            box-shadow: 0 24px 70px rgba(129, 14, 80, 0.18);
            overflow: hidden;
            border: 1px solid rgba(255,255,255,0.8);
        }
        .scratcher-header {
            padding: 38px 32px 24px;
            background: linear-gradient(135deg, #ff8eb2 0%, #8f2d7f 100%);
            color: #fff;
            text-align: center;
        }
        .scratcher-header h1 {
            margin: 0;
            font-size: 2.85rem;
            letter-spacing: 0.02em;
            line-height: 1.05;
        }
        .scratcher-header p {
            margin: 16px auto 0;
            max-width: 700px;
            font-size: 1rem;
            color: rgba(255,255,255,0.92);
            line-height: 1.75;
        }
        .scratcher-main {
            padding: 28px 32px 38px;
            display: grid;
            grid-template-columns: 1fr 0.9fr;
            gap: 30px;
            align-items: start;
        }
        .scratch-block {
            background: linear-gradient(145deg, rgba(255,255,255,0.95), rgba(255,255,255,0.85));
            border-radius: 24px;
            padding: 24px;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.6);
            text-align: center;
        }
        .scratch-block h2 {
            margin: 0 0 18px;
            font-size: 1.5rem;
            color: #5f1f4f;
        }
        .scratch-area {
            position: relative;
            margin: 0 auto 20px;
            width: min(100%, 340px);
            aspect-ratio: 4 / 3;
            border-radius: 24px;
            overflow: hidden;
            background: radial-gradient(circle at top, #ffeaff 0%, #f5d1ea 50%, #ed8fd6 100%);
            display: grid;
            place-items: center;
            border: 2px solid #f7d0e5;
        }
        .scratch-reveal {
            position: absolute;
            inset: 0;
            display: grid;
            place-items: center;
            padding: 16px;
            text-align: center;
            z-index: 1;
            pointer-events: none;
        }
        .scratch-reveal h3 {
            margin: 0 0 10px;
            font-size: 2rem;
            color: #5a0e44;
        }
        .scratch-reveal p {
            margin: 0;
            color: #44224c;
            font-size: 0.95rem;
        }
        #scratchCanvas {
            width: 100%;
            height: 100%;
            display: block;
            cursor: pointer;
        }
        .scratch-info {
            margin-top: 12px;
            color: #562a4e;
            font-size: 0.95rem;
        }
        .scratch-details {
            background: #fff;
            border-radius: 20px;
            padding: 22px;
            box-shadow: 0 18px 40px rgba(0,0,0,0.08);
        }
        .scratch-details h2 {
            margin: 0 0 18px;
            font-size: 1.6rem;
            color: #5b0f52;
        }
        .scratch-details strong {
            display: block;
            margin-bottom: 14px;
            font-size: 1.4rem;
            color: #8b1d74;
        }
        .scratch-details .coupon {
            padding: 14px 18px;
            border-radius: 16px;
            background: #fff0f9;
            border: 1px dashed #d86ba7;
            font-weight: 700;
            color: #64124c;
            letter-spacing: 0.05em;
        }
        .scratch-details button {
            margin-top: 18px;
            width: 100%;
            padding: 14px 18px;
            border-radius: 16px;
            border: none;
            background: linear-gradient(135deg, #ff5eb8, #d11f76);
            color: #fff;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s ease;
        }
        .scratch-details button:hover { transform: translateY(-2px); }
        .coupon-copy-row {
            margin-top: 14px;
            display: flex;
            gap: 12px;
            align-items: center;
        }
        .coupon-copy-input {
            flex: 1;
            padding: 12px 14px;
            border-radius: 14px;
            border: 1px solid #f0bfd6;
            background: #fff;
            color: #5c1450;
            font-weight: 700;
            letter-spacing: 0.08em;
        }
        .scratch-status {
            margin-top: 12px;
            color: #6f2f62;
            font-size: 0.96rem;
        }
        @media (max-width: 980px) {
            .scratcher-main { grid-template-columns: 1fr; }
            .scratch-block { padding: 18px; }
            .scratch-details { padding: 20px; }
        }
    </style>
</head>
<body>
    <jsp:include page="/common/header.jsp" />
    <div class="scratcher-page">
        <div class="scratcher-card">
            <div class="scratcher-header">
                <h1>Scratch &amp; Win</h1>
                <p>Reveal a surprise discount coupon and bonus points that can be used for your next order. Scratch the card until the hidden offer appears.</p>
            </div>
            <div class="scratcher-main">
                <div class="scratch-block">
                    <h2>Scratch Here</h2>
                    <div class="scratch-area">
                        <div class="scratch-reveal">
                            <h3>Secret Offer</h3>
                            <p>Swipe over the silver surface to reveal your reward.</p>
                        </div>
                        <canvas id="scratchCanvas"></canvas>
                    </div>
                    <div class="scratch-info">Use your mouse or touch to scratch. When enough area is cleared, the full coupon is revealed.</div>
                </div>
                <div class="scratch-details">
                    <h2>Your reward</h2>
                    <strong id="scratchRewardPoints">+0 points</strong>
                    <div class="coupon" id="scratchCouponCode">Reveal the code by scratching</div>
                    <button id="claimRewardBtn" disabled>Claim reward</button>
                    <button id="copyCouponBtn" type="button" disabled>Copy coupon</button>
                    <div class="coupon-copy-row">
                        <input id="scratcherCouponInput" class="coupon-copy-input" type="text" readonly placeholder="Coupon code will appear here" />
                    </div>
                    <div class="scratch-status" id="scratchStatus">Scratch the card to uncover a coupon code and bonus points.</div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/common/footer.jsp" />
    <script>
        const rewardStorageKey = 'gildedStitchRewardPoints';
        const couponCodes = ['GILD10', 'FLASH15', 'SAVE20', 'LUXE25', 'STYLE30'];
        const rewardPoints = Math.floor(Math.random() * 16) + 15;
        const couponCode = couponCodes[Math.floor(Math.random() * couponCodes.length)];
        const revealThreshold = 0.45;
        const scratchCanvas = document.getElementById('scratchCanvas');
        const claimBtn = document.getElementById('claimRewardBtn');
        const copyBtn = document.getElementById('copyCouponBtn');
        const statusText = document.getElementById('scratchStatus');
        const pointsLabel = document.getElementById('scratchRewardPoints');
        const couponLabel = document.getElementById('scratchCouponCode');
        const couponField = document.getElementById('scratcherCouponInput');
        let isDrawing = false;
        let scratched = false;
        let scratchUsed = false;

        async function fetchScratchUsage() {
            try {
                const response = await fetch('${pageContext.request.contextPath}/RewardUsageServlet');
                const data = await response.json();
                if (data.valid && data.scratchUsed) {
                    scratchUsed = true;
                    claimBtn.disabled = true;
                    copyBtn.disabled = true;
                    claimBtn.textContent = 'Already Claimed';
                    statusText.textContent = 'You have already used your scratch chance.';
                    couponLabel.textContent = 'Scratch chance already used';
                    couponField.value = 'N/A';
                }
            } catch (e) {
                console.error('Unable to load scratch usage status', e);
            }
        }

        pointsLabel.textContent = `+${rewardPoints} points`;
        couponLabel.textContent = 'Reveal the code by scratching';

        fetchScratchUsage();

        function getRewardPoints() {
            return parseInt(localStorage.getItem(rewardStorageKey) || '0', 10);
        }
        function setRewardPoints(points) {
            localStorage.setItem(rewardStorageKey, String(points));
        }

        function resizeScratchCanvas() {
            const rect = scratchCanvas.getBoundingClientRect();
            scratchCanvas.width = rect.width * window.devicePixelRatio;
            scratchCanvas.height = rect.height * window.devicePixelRatio;
            scratchCanvas.style.width = rect.width + 'px';
            scratchCanvas.style.height = rect.height + 'px';
            const ctx = scratchCanvas.getContext('2d');
            ctx.clearRect(0, 0, scratchCanvas.width, scratchCanvas.height);
            ctx.fillStyle = '#b3b3b3';
            ctx.fillRect(0, 0, scratchCanvas.width, scratchCanvas.height);
            ctx.globalCompositeOperation = 'destination-out';
        }

        function getScratchPercentage() {
            const ctx = scratchCanvas.getContext('2d');
            const imageData = ctx.getImageData(0, 0, scratchCanvas.width, scratchCanvas.height);
            const pixels = imageData.data;
            let cleared = 0;
            for (let i = 3; i < pixels.length; i += 4) {
                if (pixels[i] === 0) cleared += 1;
            }
            return cleared / (pixels.length / 4);
        }

        function drawScratch(x, y) {
            const ctx = scratchCanvas.getContext('2d');
            ctx.beginPath();
            ctx.arc(x * window.devicePixelRatio, y * window.devicePixelRatio, 24 * window.devicePixelRatio, 0, Math.PI * 2);
            ctx.fill();
        }

        scratchCanvas.addEventListener('pointerdown', (event) => {
            isDrawing = true;
            scratched = false;
            scratchCanvas.setPointerCapture(event.pointerId);
            drawScratch(event.offsetX, event.offsetY);
        });

        scratchCanvas.addEventListener('pointermove', (event) => {
            if (!isDrawing) return;
            drawScratch(event.offsetX, event.offsetY);
            const percent = getScratchPercentage();
            if (percent >= revealThreshold && !scratched) {
                scratched = true;
                claimBtn.disabled = false;
                couponField.value = couponCode;
                couponLabel.textContent = couponCode;
                statusText.textContent = `You uncovered a coupon and ${rewardPoints} extra points! Claim to add it to your wallet.`;
            }
        });

        scratchCanvas.addEventListener('pointerup', (event) => {
            isDrawing = false;
            scratchCanvas.releasePointerCapture(event.pointerId);
        });

        scratchCanvas.addEventListener('pointerleave', () => {
            isDrawing = false;
        });

        window.addEventListener('resize', resizeScratchCanvas);
        resizeScratchCanvas();

        claimBtn.addEventListener('click', () => {
            if (claimBtn.disabled || scratchUsed) return;
            statusText.textContent = 'Saving your coupon to the account...';
            fetch('${pageContext.request.contextPath}/RegisterScratchCouponServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'coupon_code=' + encodeURIComponent(couponCode)
            })
            .then(response => response.json())
            .then(data => {
                if (data && data.valid) {
                    const total = getRewardPoints() + rewardPoints;
                    setRewardPoints(total);
                    scratchUsed = true;
                    claimBtn.disabled = true;
                    copyBtn.disabled = false;
                    couponField.value = couponCode;
                    localStorage.setItem('gildedStitchScratchCoupon', couponCode);
                    claimBtn.textContent = 'Claimed';
                    statusText.textContent = `Success! ${rewardPoints} points added. Use code ${couponCode} at checkout for extra savings.`;
                } else {
                    statusText.textContent = data.message || 'Failed to register coupon. Please try again.';
                }
            }).catch(() => {
                statusText.textContent = 'Unable to save coupon right now. Please refresh and try again.';
            });
        });

        copyBtn.addEventListener('click', () => {
            if (!couponCode || scratchUsed === false && couponField.value !== couponCode) {
                couponField.value = couponCode;
            }
            navigator.clipboard.writeText(couponCode).then(() => {
                statusText.textContent = 'Coupon code copied! Paste it in checkout coupon field.';
            }).catch(() => {
                statusText.textContent = 'Unable to copy automatically. Please select and copy the code manually.';
            });
        });
    </script>
</body>
</html>
