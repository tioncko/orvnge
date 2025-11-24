package com.orvnge.controller.main;

import com.orvnge.model.entities.core.Usuario;
import com.orvnge.service.implementation.UsuarioService;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String user = request.getParameter("user");
        String pass = request.getParameter("senha");

        UsuarioService service = new UsuarioService();
        boolean valid = service.autenticarUsuario(user, pass);

        if (valid) {
            HttpSession session = request.getSession();
            //1 - Busca por email
            JSONObject obj = service.buscarUsuario(user, 1);
            Usuario usr = new Usuario();
            usr.setIdCli(obj.getInt("idCli"));
            usr.setCpf(obj.getString("cpf"));
            usr.setNome(obj.getString("nome"));
            usr.setTel(obj.getString("tel"));
            usr.setEmail(obj.getString("email"));
            session.setAttribute("usr", usr);
            //session.setAttribute("idCli", obj.getInt("idCli"));
            //session.setAttribute("cpf", obj.getString("cpf"));

            request.getRequestDispatcher("pages/orvnge-navigation.jsp").forward(request, response);
        } else if (user.isEmpty() && !pass.isEmpty()) {// || (!user.isEmpty() && pass.isEmpty())) {
            request.setAttribute("empty", "Preencha usuário!");
            request.getRequestDispatcher("pages/login.jsp").forward(request, response);
        } else if (pass.isEmpty() && !user.isEmpty()) {
            request.setAttribute("null", "Preencha senha!");
            request.getRequestDispatcher("pages/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Usuário ou senha inválidos!");
            request.getRequestDispatcher("pages/login.jsp").forward(request, response);
        }
    }
}
