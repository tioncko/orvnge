package com.orvnge.controller.main;

import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String user = request.getParameter("user");
        String pass = request.getParameter("pass");

        UsuarioService service = new UsuarioService();
        boolean valid = service.autenticarUsuario(user, pass);

        if (valid) {
            request.getRequestDispatcher("pages/teste_forms.jsp").forward(request, response);
        } else if (user.isEmpty() && !pass.isEmpty()) {// || (!user.isEmpty() && pass.isEmpty())) {
            request.setAttribute("empty", "Preencha usuário!");
            request.getRequestDispatcher("pages/index.jsp").forward(request, response);
        } else if (pass.isEmpty() && !user.isEmpty()) {
            request.setAttribute("null", "Preencha senha!");
            request.getRequestDispatcher("pages/index.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Usuário ou senha inválidos!");
            request.getRequestDispatcher("pages/index.jsp").forward(request, response);
        }
    }
}
