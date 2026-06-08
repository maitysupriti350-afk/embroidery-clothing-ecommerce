package com.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.JsonObject;

@WebServlet("/envCheck")
public class EnvCheckServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        String hfToken = System.getenv("HF_API_TOKEN");
        String hfModel = System.getenv("HF_MODEL");

        JsonObject obj = new JsonObject();
        obj.addProperty("HF_API_TOKEN_set", hfToken != null && !hfToken.isEmpty());
        obj.addProperty("HF_MODEL_set", hfModel != null && !hfModel.isEmpty());

        // Check product_img folder presence
        String productImgPath = getServletContext().getRealPath("") + java.io.File.separator + "product_img";
        boolean productImgExists = Files.exists(Paths.get(productImgPath));
        obj.addProperty("product_img_folder_exists", productImgExists);
        obj.addProperty("product_img_path_checked", productImgPath);

        // For safety do NOT echo the full token back in the response
        if (hfToken != null && hfToken.length() > 6) {
            obj.addProperty("HF_API_TOKEN_preview", hfToken.substring(0, 6) + "...");
        } else if (hfToken != null) {
            obj.addProperty("HF_API_TOKEN_preview", hfToken);
        } else {
            obj.addProperty("HF_API_TOKEN_preview", "(not set)");
        }

        out.println(obj.toString());
        out.flush();
    }
}
