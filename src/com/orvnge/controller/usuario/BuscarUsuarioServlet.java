package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.UsuarioService;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/buscar-usuario")
public class BuscarUsuarioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String user = req.getParameter("user");

        if(user == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Usuário não informado");
            return;
        }

        UsuarioService service = new UsuarioService();
        JSONObject obj = service.buscarUsuario(user, 1);
        if(obj == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Usuário não encontrado");
            resp.sendRedirect(req.getContextPath() + "/pages/recuperarUsuario.jsp");
        } else {
            req.getRequestDispatcher("/pages/alterarSenha.jsp?id=" + obj.getInt("idCli")).forward(req, resp);
        }
    }
}
