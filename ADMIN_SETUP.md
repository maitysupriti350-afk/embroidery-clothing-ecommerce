# 🔒 ADMIN PANEL SETUP GUIDE

## How Admin Access Works

The admin panel is now **completely restricted** and **admin-only**. Only authorized administrators can access it.

---

## ⚙️ Setting Up Admin Email

Admin is identified by a **specific email address**. You need to configure which email should have admin access:

### Option 1: Using Environment Variable (Recommended)
Set the environment variable `ADMIN_USER` before running the application:

**Windows (PowerShell):**
```powershell
$env:ADMIN_USER = "admin@example.com"
```

**Windows (Command Prompt):**
```cmd
set ADMIN_USER=admin@example.com
```

**Linux/Mac:**
```bash
export ADMIN_USER="admin@example.com"
```

### Option 2: Using System Property
Pass the system property when running Tomcat:

```
-Dadmin.email=admin@example.com
```

### Option 3: Hardcode in Code (Not Recommended)
Edit [LoginServlet.java](LoginServlet.java) and change the default:
```java
adminEmail = System.getProperty("admin.email", "YOUR_ADMIN_EMAIL@example.com");
```

---

## 🔑 Admin Login Steps

1. **Open the Login Page**: Go to `/auth.jsp`

2. **Enter Admin Email**: 
   - Use the email you configured as `ADMIN_USER`
   - Example: `admin@example.com`

3. **OTP Verification**:
   - You'll receive an OTP via email
   - Enter it on `/verifyOTP.jsp`

4. **Redirected to Admin Panel**:
   - You'll be taken to `/adminDashboard.jsp`
   - You'll see: 🔒 **ADMIN CONTROL PANEL** at the top
   - Only admin has access to this page

---

## 📊 What You See in Admin Panel

Once logged in as admin, you'll see:

### 1. **Header with ADMIN BRANDING**
```
🔒 ADMIN CONTROL PANEL
⚙️ RESTRICTED ACCESS - Only authorized administrators can access this panel
```

### 2. **Sidebar Navigation** (Admin-Only Options)
- 📊 Dashboard
- 📦 Products
- 🛍️ Orders ← **WITH PENDING COUNT BADGE**
- 👥 Users
- ➕ Add Product
- 👁️ View Store (to check frontend)
- 👤 User Dashboard (to verify non-admin view)
- 🚪 Admin Logout

### 3. **Statistics Cards**
- Total Products
- Total Orders
- **🔴 Pending Orders (RED ALERT)**
- Registered Users
- Total Revenue

### 4. **🔴 Pending Orders Section** (NEW & IMPORTANT)
- Shows orders waiting for admin approval
- Shows payment status and address verification
- Click "Review & Approve" button → goes to order approval page

### 5. **Products Management**
- All products with Edit/Delete buttons

### 6. **Recent Orders**
- Last 5 orders preview

---

## ✅ What Admin Can Do

### Approve Orders
1. Open Admin Panel
2. See "🔴 Pending Orders Awaiting Approval" section
3. Click "Review & Approve" on any order
4. You'll see order details with buttons:
   - ✓ **Verify Address** - Confirm shipping address
   - ✓ **Verify Payment** - Confirm payment received
   - ✓ **Approve Order** - Officially approve the order
   - ✗ **Reject Order** - Reject with reason
   - 📦 **Update Status** - Change to Shipped/Delivered/etc

### Manage Products
1. Go to Products section
2. Edit or Delete products

### Manage Users
1. Go to Users section
2. See all registered users

---

## 🚫 Security Features

✅ **Admin Dashboard is Protected**
   - Non-admin users are redirected to customer dashboard
   - Admin email must match configured `ADMIN_USER`
   - Session must have `isAdmin=true`

✅ **Admin-Only Pages**
   - `/adminDashboard.jsp` - Admin only
   - `/adminOrders.jsp` - Admin only
   - `/adminUsers.jsp` - Admin only
   - `/addproduct.jsp` - Admin only
   - `/editProduct.jsp` - Admin only

✅ **Clear Admin Identification**
   - "🔒 ADMIN MODE" badge in sidebar
   - Shows admin email
   - Shows "Restricted Admin Access"
   - "🔒 ADMIN CONTROL PANEL" header on dashboard

---

## 🔍 Troubleshooting

### Problem: Logging in but not seeing Admin Panel?
**Solution:** 
- Make sure you logged in with the correct admin email
- Check that `ADMIN_USER` environment variable is set correctly
- Restart the application after setting the environment variable
- Check the server console for logs: "LoginServlet: User X marked as ADMIN"

### Problem: Can't find Orders to approve?
**Solution:**
- Orders appear in "🔴 Pending Orders Awaiting Approval" section
- If no pending orders, check "View All Pending" link
- Go to Orders menu → Click filter "Pending"

### Problem: "You are not admin" error?
**Solution:**
- Your email doesn't match the configured `ADMIN_USER`
- Logout and login with the correct admin email
- Verify `ADMIN_USER` is set in environment variables

---

## 📋 Quick Reference

| What | Where |
|------|-------|
| **Login** | `/auth.jsp` |
| **Admin Dashboard** | `/adminDashboard.jsp` |
| **Approve Orders** | `/adminOrders.jsp` (or dashboard button) |
| **Manage Products** | `/adminDashboard.jsp#products` |
| **Manage Users** | `/adminUsers.jsp` |
| **Add Product** | `/addproduct.jsp` |

---

## Example Setup

**For Development:**
```
Admin Email: admin@clothingstore.com
Environment Variable: ADMIN_USER=admin@clothingstore.com
```

**For Production:**
```
Admin Email: super_admin@gilded-stitch.com
Environment Variable: ADMIN_USER=super_admin@gilded-stitch.com
```

---

✅ **Your admin panel is now fully set up and secure!**
