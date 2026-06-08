package com.servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminSalesReportServlet")
public class AdminSalesReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Calls the Python sales_report.py script and captures its output line by line.
     */
    public List<String> getPythonAnalytics() {
        List<String> reportLines = new ArrayList<>();
        try {
            // 1. Tell Java exactly where your Python script is located
            String scriptPath = "C:\\Users\\supri\\eclipse-workspace\\ClothingStore_Final\\scripts\\sales_report.py";

            // 2. Set up the command execution line
            ProcessBuilder pb = new ProcessBuilder("python", scriptPath);
            // Merge stderr into stdout so we don't deadlock on full buffers
            pb.redirectErrorStream(true);
            // Force Python to use UTF-8 encoding for emoji support
            pb.environment().put("PYTHONIOENCODING", "UTF-8");

            // 3. Start the background execution
            Process process = pb.start();

            // 4. Read the text that Python prints out line by line (use UTF-8 to match Python output)
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), "UTF-8"));
            String line;
            while ((line = reader.readLine()) != null) {
                reportLines.add(line);
            }

            // 5. Wait for the script to finish safely
            process.waitFor();

        } catch (Exception e) {
            e.printStackTrace();
            reportLines.add("Error generating report from Java backend: " + e.getMessage());
        }
        return reportLines;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Security: verify admin session
        if (session == null || session.getAttribute("user") == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            response.sendRedirect("adminAuth.jsp");
            return;
        }

        // Call the method to fetch your Python report output
        List<String> analyticsData = getPythonAnalytics();

        // Send this list over to your JSP file
        request.setAttribute("analyticsData", analyticsData);

        // Forward the user to the admin dashboard page
        request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
