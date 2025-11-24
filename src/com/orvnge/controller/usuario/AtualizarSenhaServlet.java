package com.orvnge.controller.usuario;

import com.orvnge.service.implementation.UsuarioService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/atualizar-senha")
public class AtualizarSenhaServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("idCli"));
        String senha = req.getParameter("novaSenha");
        String confSenha = req.getParameter("confirmaSenha");

        try {
            UsuarioService service = new UsuarioService();
            if (!senha.isEmpty() && !confSenha.isEmpty()) {
                if (senha.equals(confSenha)) {
                    service.atualizarSenha(id, senha);
                    req.setAttribute("success", "Senha atualizada com sucesso!");
                    req.getRequestDispatcher("pages/login.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "Senhas não coincidem!");
                    req.getRequestDispatcher("pages/recuperarUsuario.jsp").forward(req, resp);
                }
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Erro no AtualizarSenhaServlet: " + e.getMessage());
            req.getRequestDispatcher("pages/login.jsp").forward(req, resp);
        }
    }
}
