package com.orvnge.controller.conta;

import com.orvnge.service.implementation.ContaService;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/cadastrar-conta")
public class CadastrarContaServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idConta = request.getParameter("idConta");
        String numConta = request.getParameter("numConta");
        String saldo = request.getParameter("saldoInicial");
        String idBanco = request.getParameter("idBanco");
        String idTipoConta = request.getParameter("idTipoConta");
        String cpf = request.getParameter("cpf");

        ContaService service = new ContaService();
        service.cadastrarConta(
                Integer.parseInt(idConta),
                numConta,
                Double.parseDouble(saldo),
                Integer.parseInt(idBanco),
                Integer.parseInt(idTipoConta),
                cpf
        );

        response.sendRedirect("/orvnge/conta/listar-contas");
    }
}
