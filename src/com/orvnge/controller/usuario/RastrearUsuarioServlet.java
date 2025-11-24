package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.UsuarioService;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/rastrear-usuario")
public class RastrearUsuarioServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String user = req.getParameter("user");

        if(user == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Usuário não informado");
            return;
        }

        UsuarioService service = new UsuarioService();
        JSONObject obj = service.buscarUsuario(user, 0);

        resp.setContentType("application/json");
        resp.getWriter().write(obj.toString());
    }
}
