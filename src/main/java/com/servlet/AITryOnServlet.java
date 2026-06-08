package com.servlet;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import com.google.gson.JsonObject;

@WebServlet("/aiTryOn")
public class AITryOnServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "ai_tryon_temp";
    private static final String PYTHON_SCRIPT_DIR = "python_ai";
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            if (!ServletFileUpload.isMultipartContent(request)) {
                sendJsonError(out, "Invalid request format");
                return;
            }

            ServletFileUpload upload = new ServletFileUpload(new DiskFileItemFactory());
            upload.setFileSizeMax(MAX_FILE_SIZE);

            List<FileItem> items = upload.parseRequest(request);
            String productId = null;
            String userPhotoPath = null;

            // Process form fields and files
            for (FileItem item : items) {
                if (item.isFormField()) {
                    if (item.getFieldName().equals("productId")) {
                        productId = item.getString().trim();
                    }
                } else {
                    if (item.getFieldName().equals("userPhoto") && item.getSize() > 0) {
                        userPhotoPath = saveUploadedFile(item);
                    }
                }
            }

            // Validate inputs
            if (productId == null || productId.isEmpty() || userPhotoPath == null) {
                sendJsonError(out, "Product ID and user photo are required");
                return;
            }

            if (!isValidProductId(productId)) {
                sendJsonError(out, "Invalid product ID");
                return;
            }

            // Call Python AI script
            Map<String, Object> aiResults = callPythonAI(userPhotoPath, productId);

            if (aiResults.containsKey("error")) {
                sendJsonError(out, (String) aiResults.get("error"));
            } else {
                sendJsonSuccess(out, aiResults);
            }

        } catch (Exception e) {
            e.printStackTrace();
            sendJsonError(out, "Server error: " + e.getMessage());
        }
    }

    private String saveUploadedFile(FileItem item) throws Exception {
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fileName = System.currentTimeMillis() + "_" + new File(item.getName()).getName();
        String filePath = uploadPath + File.separator + fileName;

        // Validate file type
        String contentType = item.getContentType();
        if (!isValidImageType(contentType)) {
            throw new Exception("Invalid image format. Please upload JPG or PNG.");
        }

        File uploadedFile = new File(filePath);
        item.write(uploadedFile);

        return filePath;
    }

    private boolean isValidImageType(String contentType) {
        return contentType != null && 
               (contentType.startsWith("image/jpeg") || 
                contentType.startsWith("image/png") || 
                contentType.startsWith("image/jpg"));
    }

    private boolean isValidProductId(String productId) {
        try {
            Integer.parseInt(productId);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private Map<String, Object> callPythonAI(String userPhotoPath, String productId) {
        Map<String, Object> results = new HashMap<>();

        try {
            String pythonScriptPath = getServletContext().getRealPath("") + 
                                     File.separator + PYTHON_SCRIPT_DIR + 
                                     File.separator + "ai_tryon_engine.py";

            // Prefer hosted-model inference wrapper if a product image exists
            // Look for product image files in webapp/product_img
            String productImgDir = getServletContext().getRealPath("") + File.separator + "product_img";
            String[] candidateNames = new String[] {
                productImgDir + File.separator + productId + ".png",
                productImgDir + File.separator + productId + ".jpg",
                productImgDir + File.separator + productId + ".jpeg",
                productImgDir + File.separator + "product_" + productId + ".png",
                productImgDir + File.separator + "product_" + productId + ".jpg",
                productImgDir + File.separator + "product_" + productId + ".jpeg"
            };

            String productImagePath = null;
            for (String p : candidateNames) {
                if (Files.exists(Paths.get(p))) {
                    productImagePath = p;
                    break;
                }
            }

            if (productImagePath != null) {
                // Use the hosted inference wrapper which accepts two image paths
                pythonScriptPath = getServletContext().getRealPath("") + File.separator + PYTHON_SCRIPT_DIR + File.separator + "ai_tryon_inference.py";
            }

            // Check if Python script exists
            if (!Files.exists(Paths.get(pythonScriptPath))) {
                results.put("error", "AI processing not available. Python engine not found.");
                return results;
            }

            // Try multiple Python command variations for Windows/Linux compatibility
            String pythonCmd = findPythonExecutable();
            if (pythonCmd == null) {
                results.put("error", "Python is not installed or not found in system PATH. Please install Python 3.8+");
                return results;
            }

            // Execute Python script
            String secondArg = productImagePath != null ? productImagePath : productId;
            ProcessBuilder pb = new ProcessBuilder(
                pythonCmd,
                pythonScriptPath,
                userPhotoPath,
                secondArg
            );

            // Set working directory to the absolute script directory for relative imports
            String pythonScriptDirPath = new File(pythonScriptPath).getParent();
            pb.directory(new File(pythonScriptDirPath));
            // Keep stdout and stderr separate so Python debug logs (stderr) don't corrupt JSON on stdout
            pb.redirectErrorStream(false);
            Process process = pb.start();

            // Read stdout and stderr in separate threads to avoid blocking
            StringBuilder stdoutSb = new StringBuilder();
            StringBuilder stderrSb = new StringBuilder();

            Thread stdoutReader = new Thread(() -> {
                try (BufferedReader r = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    String l;
                    while ((l = r.readLine()) != null) {
                        stdoutSb.append(l);
                    }
                } catch (IOException ignored) {}
            });

            Thread stderrReader = new Thread(() -> {
                try (BufferedReader r = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
                    String l;
                    while ((l = r.readLine()) != null) {
                        stderrSb.append(l).append(System.lineSeparator());
                    }
                } catch (IOException ignored) {}
            });

            stdoutReader.start();
            stderrReader.start();

            long timeout = 60000; // 60 seconds timeout
            boolean finished = process.waitFor(timeout, java.util.concurrent.TimeUnit.MILLISECONDS);

            // Ensure readers finish
            stdoutReader.join(1000);
            stderrReader.join(1000);

            int exitCode = finished ? process.exitValue() : -1;

            if (exitCode == 0) {
                // Parse JSON response from Python script (stdout only)
                String jsonResponse = stdoutSb.toString().trim();
                if (!jsonResponse.isEmpty()) {
                    try {
                        // Parse JSON safely
                        com.google.gson.JsonElement element = com.google.gson.JsonParser.parseString(jsonResponse);
                        
                        if (element.isJsonObject()) {
                            com.google.gson.JsonObject json = element.getAsJsonObject();
                            
                            results.put("success", true);
                            if (json.has("output_image")) {
                                results.put("outputImage", json.get("output_image").getAsString());
                            }
                            if (json.has("body_analysis")) {
                                results.put("bodyAnalysis", json.get("body_analysis").getAsString());
                            }
                            if (json.has("style_recommendation")) {
                                results.put("styleRecommendation", json.get("style_recommendation").getAsString());
                            }
                            results.put("message", "AI analysis complete!");
                        }
                    } catch (Exception parseEx) {
                        // Fallback if JSON parsing fails — include stderr for diagnostics
                        String err = stderrSb.length() > 0 ? stderrSb.toString() : parseEx.getMessage();
                        results.put("error", "AI response parsing failed: " + err);
                    }
                } else {
                    results.put("error", "No response from AI engine");
                }
            } else {
                String errOut = stderrSb.length() > 0 ? stderrSb.toString() : "";
                results.put("error", "AI processing failed. Exit code: " + exitCode + 
                           ". Stderr: " + errOut + 
                           " Please ensure Python 3 is installed and added to PATH.");
            }

            // Clean up uploaded temp file
            cleanupFile(userPhotoPath);

        } catch (Exception e) {
            e.printStackTrace();
            results.put("error", "AI processing error: " + e.getMessage());
        }

        return results;
    }

    private String findPythonExecutable() {
        // Try different Python executable names
        String[] pythonCommands = {
            "python3",
            "python",
            "py",
            "py.exe",
            "python.exe",
            "python3.exe"
        };

        for (String cmd : pythonCommands) {
            try {
                ProcessBuilder pb = new ProcessBuilder(cmd, "--version");
                pb.redirectErrorStream(true);
                Process process = pb.start();
                int exitCode = process.waitFor();
                if (exitCode == 0) {
                    return cmd;
                }
            } catch (Exception ignored) {
                // Try next command
            }
        }
        return null;
    }


    private void cleanupFile(String filePath) {
        try {
            Files.delete(Paths.get(filePath));
        } catch (Exception e) {
            // Ignore cleanup errors
        }
    }

    private void sendJsonSuccess(PrintWriter out, Map<String, Object> data) {
        JsonObject response = new JsonObject();
        response.addProperty("status", "success");
        
        if (data.containsKey("outputImage")) {
            response.addProperty("outputImage", (String) data.get("outputImage"));
        }
        if (data.containsKey("bodyAnalysis")) {
            response.addProperty("bodyAnalysis", (String) data.get("bodyAnalysis"));
        }
        if (data.containsKey("styleRecommendation")) {
            response.addProperty("styleRecommendation", (String) data.get("styleRecommendation"));
        }

        out.println(response.toString());
        out.flush();
    }

    private void sendJsonError(PrintWriter out, String message) {
        JsonObject response = new JsonObject();
        response.addProperty("status", "error");
        response.addProperty("message", message);
        out.println(response.toString());
        out.flush();
    }
}
