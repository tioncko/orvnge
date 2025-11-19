package com.orvnge.controller.conta;

import com.orvnge.service.implementation.ContaService;
import org.json.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/buscar-conta")
public class BuscarContaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idConta = req.getParameter("idConta");

        ContaService service = new ContaService();
        JSONObject obj = service.buscarConta(Integer.parseInt(idConta));

        resp.setContentType("application/json");
        resp.getWriter().write(obj.toString());
    }
}
