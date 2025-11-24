package com.orvnge.controller.movimentacao;

import com.orvnge.service.implementation.MovimentacaoService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/deletar-mov")
public class DeleterMovServlet extends HttpServlet {
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idMov = req.getParameter("idMov");

        MovimentacaoService service = new MovimentacaoService();
        service.excluirMovimentacao(Integer.parseInt(idMov));

        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
