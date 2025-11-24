package com.orvnge.controller.usuario;

import com.orvnge.DAO.core.UsuarioDAO;
import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/deletar-usuario")
public class DeletarUsuarioServlet extends HttpServlet {
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) {

        String cpf = req.getParameter("cpf");

        UsuarioService service = new UsuarioService();
        service.excluirUsuario(cpf);

        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
