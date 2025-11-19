package com.orvnge.controller.conta;

import com.orvnge.service.implementation.ContaService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/atualizar-conta")
public class AtualizarContaServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idConta = request.getParameter("idConta");
        String numConta = request.getParameter("numConta");
        String saldo = request.getParameter("saldo");
        String idTipoConta = request.getParameter("idTipoConta");
        String idBanco = request.getParameter("idBanco");
        String idUsuario = request.getParameter("idUsuario");
        String cpf = request.getParameter("cpf");

        ContaService service = new ContaService();
        service.alterarConta(
                Integer.parseInt(idConta),
                numConta,
                Double.parseDouble(saldo),
                Integer.parseInt(idBanco),
                Integer.parseInt(idTipoConta),
                Integer.parseInt(idUsuario),
                cpf
        );

        response.sendRedirect("/orvnge/conta/listar-contas");
    }
}
