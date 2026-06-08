<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="global-footer" style="background:#f8f6f4;padding:18px 20px;border-top:1px solid #eee;margin-top:40px;">
    <div style="max-width:1100px;margin:0 auto;display:flex;gap:30px;flex-wrap:wrap;align-items:flex-start;justify-content:space-between;">
        <div style="min-width:220px;">
            <h4 style="margin-bottom:6px;color:#5d4037">Customer Care</h4>
            <div>Helpline: <strong style="color:#c0395a">1800-123-4567 (9am-9pm)</strong></div>
            <div style="margin-top:8px;font-size:13px;color:#6b3a53">Email: support@thegildedstitch.example</div>
        </div>

        <div style="display:flex;gap:24px;flex:1;max-width:640px;">
            <div>
                <h4 style="margin-bottom:6px;color:#5d4037">Company</h4>
                <div><a href="about.jsp">About</a></div>
                <div><a href="terms-conditions.jsp">Terms & Conditions</a></div>
                <div><a href="privacy-policy.jsp">Privacy Policy</a></div>
                <div><a href="returns-refund.jsp">Returns & Refunds</a></div>
            </div>
            <div>
                <h4 style="margin-bottom:6px;color:#5d4037">Help</h4>
                <div><a href="helpcenter.jsp">Help Center</a></div>
                <div><a href="faq.jsp">FAQ</a></div>
                <div><a href="contact.jsp">Contact Us</a></div>
            </div>
        </div>

        <div style="min-width:180px;text-align:right;color:#6b3a53">
            <div>© <%= java.time.Year.now() %> THE GILDED STITCH</div>
            <div style="font-size:12px;margin-top:6px;">Designed for elegant traditional style.</div>
        </div>
    </div>
</div>
