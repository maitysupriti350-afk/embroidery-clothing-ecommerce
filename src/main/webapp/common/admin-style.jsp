<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f0f2f5; display: flex; min-height: 100vh; }

    .admin-sidebar { width: 260px; background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%); color: #fff; position: fixed; top: 0; left: 0; height: 100vh; overflow-y: auto; z-index: 100; }
    .sidebar-brand { padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.08); display: flex; align-items: center; gap: 12px; }
    .sidebar-brand i { font-size: 24px; color: #ff3f6c; }
    .sidebar-brand span { font-size: 18px; font-weight: 700; }
    .sidebar-section { padding: 16px 0; }
    .sidebar-section-title { font-size: 10px; text-transform: uppercase; color: #64748b; padding: 0 20px; margin-bottom: 8px; letter-spacing: 1.5px; }
    .sidebar-link { display: flex; align-items: center; gap: 12px; padding: 12px 20px; color: #94a3b8; text-decoration: none; font-size: 14px; transition: all 0.2s; border-left: 3px solid transparent; }
    .sidebar-link:hover { background: rgba(255,255,255,0.05); color: #e2e8f0; }
    .sidebar-link.active { background: rgba(255,63,108,0.1); color: #ff3f6c; border-left-color: #ff3f6c; }
    .sidebar-link i { width: 20px; text-align: center; }
    .sidebar-link .badge { margin-left: auto; background: #ff3f6c; color: white; font-size: 11px; padding: 2px 8px; border-radius: 10px; font-weight: 600; }

    .admin-main { margin-left: 260px; flex: 1; min-height: 100vh; }
    .admin-topbar { background: white; padding: 16px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e5e7eb; position: sticky; top: 0; z-index: 50; }
    .admin-topbar h1 { font-size: 22px; color: #1e293b; }
    .admin-topbar .user-info { display: flex; align-items: center; gap: 10px; color: #64748b; font-size: 14px; }
    .admin-topbar .user-info i { color: #ff3f6c; }

    .admin-content { padding: 30px; }

    .sidebar-toggle { display: none; background: #1e293b; color: white; border: none; padding: 10px 14px; border-radius: 6px; cursor: pointer; font-size: 18px; }
    @media (max-width: 768px) {
        .admin-sidebar { transform: translateX(-100%); position: absolute; }
        .admin-sidebar.open { transform: translateX(0); }
        .admin-main { margin-left: 0; }
        .sidebar-toggle { display: inline-block; }
    }

    /* Shared admin components */
    .section-card { background: white; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); margin-bottom: 24px; overflow: hidden; }
    .section-header { padding: 20px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; flex-wrap: wrap; gap: 12px; }
    .section-header h2 { font-size: 16px; color: #1e293b; }
    .section-header a { font-size: 13px; color: #ff3f6c; text-decoration: none; font-weight: 600; }
    .section-header a:hover { text-decoration: underline; }

    table { width: 100%; border-collapse: collapse; }
    th { background: #f8fafc; padding: 12px 16px; text-align: left; font-size: 12px; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #e5e7eb; }
    td { padding: 12px 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155; }
    tr:hover td { background: #f8fafc; }

    .status-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
    .status-pending { background: #fef3c7; color: #92400e; }
    .status-confirmed { background: #dbeafe; color: #1e40af; }
    .status-shipped { background: #d1fae5; color: #065f46; }
    .status-delivered { background: #ede9fe; color: #5b21b6; }
    .status-cancelled { background: #fee2e2; color: #991b1b; }

    .role-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
    .role-admin { background: #fef3c7; color: #92400e; }
    .role-user { background: #dbeafe; color: #1e40af; }

    .action-links a { margin-right: 8px; text-decoration: none; color: #3b82f6; font-size: 13px; }
    .action-links a:hover { text-decoration: underline; }
    .action-links a.delete { color: #ef4444; }

    .msg-bar { margin-bottom: 20px; padding: 14px 20px; border-radius: 8px; display: flex; align-items: center; gap: 10px; }
    .msg-success { background: #d1fae5; color: #065f46; }
    .msg-error { background: #fee2e2; color: #991b1b; }

    /* Admin form styles */
    .admin-form-card { background: white; max-width: 600px; border-radius: 12px; padding: 30px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
    .admin-form-card h2 { color: #1e293b; margin-bottom: 24px; font-size: 20px; }
    .form-group { margin-bottom: 18px; }
    .form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #374151; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
    .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 10px 14px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 14px; color: #1e293b; outline: none; transition: border-color 0.2s; font-family: inherit; }
    .form-group input:focus, .form-group textarea:focus, .form-group select:focus { border-color: #ff3f6c; box-shadow: 0 0 0 3px rgba(255,63,108,0.1); }
    .form-group textarea { resize: vertical; min-height: 80px; }
    .btn-primary { background: #ff3f6c; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
    .btn-primary:hover { background: #e63961; }
    .btn-secondary { background: #64748b; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; }
    .btn-secondary:hover { background: #475569; }
    .btn-danger { background: #ef4444; color: white; border: none; padding: 6px 14px; border-radius: 6px; font-size: 12px; cursor: pointer; }
    .btn-danger:hover { background: #dc2626; }
</style>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
