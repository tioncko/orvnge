package com.orvnge.controller.movimentacao;

import com.orvnge.service.implementation.MovimentacaoService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDate;

@WebServlet("/cadastrar-mov")
public class CadastrarMovServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String dataMov = request.getParameter("dataMov");
        String descricao = request.getParameter("descricao");
        String valor = request.getParameter("valor");
        String idConta = request.getParameter("idConta");
        String idGrupoMov = request.getParameter("idGrupoMov");

        MovimentacaoService service = new MovimentacaoService();
        service.cadastrarMovimentacao(
                LocalDate.parse(dataMov),
                descricao,
                Double.parseDouble(valor.trim().replace(',', '.')),
                Integer.parseInt(idConta),
                Integer.parseInt(idGrupoMov)
        );

        response.sendRedirect(request.getContextPath() + "/pages/cadastroMovimentacao.jsp");
    }
}
