package com.orvnge.controller.movimentacao;

import com.orvnge.service.implementation.MovimentacaoService;
import org.json.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/buscar-mov")
public class BuscarMovServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idMov = req.getParameter("idMov");

        MovimentacaoService service = new MovimentacaoService();
        JSONObject obj = service.buscarMovimentacao(Integer.parseInt(idMov));

        resp.setContentType("application/json");
        resp.getWriter().write(obj.toString());
    }
}
