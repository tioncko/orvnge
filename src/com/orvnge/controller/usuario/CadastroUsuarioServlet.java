package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.MovimentacaoService;
import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/cadastrar-usuario")
public class CadastroUsuarioServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String nome = request.getParameter("nome");
        String cpf = request.getParameter("cpf");
        String senha = request.getParameter("senha");
        String confSenha = request.getParameter("confSenha");
        String email = request.getParameter("email");
        String telefone = request.getParameter("telefone");

        try {
            if(!senha.isEmpty() && !confSenha.isEmpty()) {
                if (senha.equals(confSenha)) {
                    UsuarioService service = new UsuarioService();
                    service.cadastrarUsuario(nome, cpf, telefone, email, senha);
                    response.sendRedirect(request.getContextPath() + "/pages/login.jsp");
                } else {
                    request.setAttribute("error", "Senhas não coincidem!");
                    request.getRequestDispatcher("pages/cadastroUsuario.jsp").forward(request, response);
                }
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Erro no CadastroUsuarioServlet: " + e.getMessage());
            request.getRequestDispatcher("pages/cadastroUsuario.jsp").forward(request, response);
        }
    }
}

