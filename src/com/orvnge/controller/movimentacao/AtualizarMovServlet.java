package com.orvnge.controller.movimentacao;

import com.orvnge.service.implementation.MovimentacaoService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDate;

@WebServlet("/atualizar-mov")
public class AtualizarMovServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idMov = req.getParameter("idMov");
        String dataMov = req.getParameter("dataMov");
        String descricao = req.getParameter("descricao");
        String valor = req.getParameter("valor");
        String idConta = req.getParameter("idConta");
        String idGrupoMov = req.getParameter("idGrupoMov");

        MovimentacaoService service = new MovimentacaoService();
        service.alterarMovimentacao(
                Integer.parseInt(idMov),
                LocalDate.parse(dataMov),
                descricao,
                Double.parseDouble(valor),
                Integer.parseInt(idConta),
                Integer.parseInt(idGrupoMov)
        );

        resp.sendRedirect("/orvnge/movimentacao/listar-movimentacoes");
    }
}
