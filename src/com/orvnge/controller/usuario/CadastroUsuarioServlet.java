package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/cadastrar-usuario")
public class CadastroUsuarioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idUsuario = request.getParameter("idUsuario");
        String nome = request.getParameter("nome");
        String cpf = request.getParameter("cpf");
        String senha = request.getParameter("senha");
        String email = request.getParameter("email");
        String telefone = request.getParameter("telefone");

        UsuarioService service = new UsuarioService();
        service.cadastrarUsuario(
                Integer.parseInt(idUsuario),
                nome,
                cpf,
                senha,
                email,
                telefone
        );

        response.sendRedirect("/orvnge/usuario/listar-usuarios");
    }
}
