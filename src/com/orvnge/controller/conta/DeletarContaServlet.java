package com.orvnge.controller.conta;

import com.orvnge.service.implementation.ContaService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/deletar-conta")
public class DeletarContaServlet extends HttpServlet {
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idConta = req.getParameter("idConta");

        ContaService service = new ContaService();
        service.excluirConta(Integer.parseInt(idConta));

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.sendRedirect("/orvnge/conta/listar-contas");
    }
}
