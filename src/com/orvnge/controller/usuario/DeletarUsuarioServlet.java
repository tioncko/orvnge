package com.orvnge.controller.usuario;

import com.orvnge.DAO.core.UsuarioDAO;
import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/deletar-usuario")
public class DeletarUsuarioServlet extends HttpServlet {
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idUsuario = req.getParameter("idUsuario");
        String cpf = req.getParameter("cpf");

        UsuarioService service = new UsuarioService();
        service.excluirUsuario(cpf, Integer.parseInt(idUsuario));

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.sendRedirect("/orvnge/usuario/listar-usuarios");
    }
}
