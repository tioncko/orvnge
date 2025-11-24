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
        String idMovStr = req.getParameter("idMov");
        String dataMovStr = req.getParameter("dataMov");
        String descricao = req.getParameter("descricao");
        String valor = req.getParameter("valor");
        String idContaStr = req.getParameter("idConta");
        String idGrupoMovStr = req.getParameter("idGrupoMov");

        if (idMovStr == null || idMovStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Campo obrigatório idMovStr está vazio.");
            return;
        }
        if (dataMovStr == null || dataMovStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Campo obrigatório dataMovStr está vazio.");
            return;
        }
        if (valor == null || valor.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Campo obrigatório valorStr está vazio.");
            return;
        }
        if (idContaStr == null || idContaStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Campo obrigatório idContaStr está vazio.");
            return;
        }
        if (idGrupoMovStr == null || idGrupoMovStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Campo obrigatório idGrupoMovStr está vazio.");
            return;
        }

        try {
            MovimentacaoService service = new MovimentacaoService();
            service.alterarMovimentacao(
                    Integer.parseInt(idMovStr.trim()),
                    LocalDate.parse(dataMovStr.trim()),
                    descricao,
                    Double.parseDouble(valor.trim().replace(',', '.')),
                    Integer.parseInt(idContaStr.trim()),
                    Integer.parseInt(idGrupoMovStr.trim())
            );

            resp.sendRedirect(req.getContextPath() + "/pages/cadastroMovimentacao.jsp");
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Erro no AtualizarMovServlet: " + e.getMessage());
        }
    }
}