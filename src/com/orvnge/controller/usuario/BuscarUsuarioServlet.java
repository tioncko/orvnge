package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.UsuarioService;
import org.json.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/buscar-usuario")
public class BuscarUsuarioServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idUsuario = req.getParameter("idUsuario");
        String cpf = req.getParameter("cpf");

        UsuarioService service = new UsuarioService();
        JSONObject obj = service.buscarUsuario(cpf, Integer.parseInt(idUsuario));

        resp.setContentType("application/json");
        resp.getWriter().write(obj.toString());
    }
}
