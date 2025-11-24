package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/atualizar-usuario")
public class AtualizarUsuarioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse resp) throws IOException {
        String idUsuario = request.getParameter("idUsuario");
        String nome = request.getParameter("nome");
        String cpf = request.getParameter("cpf");
        String email = request.getParameter("email");
        String telefone = request.getParameter("telefone");

        UsuarioService service = new UsuarioService();
        service.alterarUsuario(
                Integer.parseInt(idUsuario),
                nome,
                cpf,
                email,
                telefone
        );

        resp.sendRedirect(request.getContextPath() + "/pages/dashboard.jsp");
    }
}
