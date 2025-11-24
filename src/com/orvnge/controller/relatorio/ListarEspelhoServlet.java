package com.orvnge.controller.relatorio;

import com.orvnge.service.implementation.RelatoriosService;
import org.json.JSONArray;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/listar-espelho")
public class ListarEspelhoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String app = "application/json; charset=UTF-8";
        resp.setContentType(app);

        String cpf = req.getParameter("cpf");

        RelatoriosService service = new RelatoriosService();
        JSONArray arr = service.ListarEspelho(cpf);

        resp.getWriter().write(arr.toString());
    }
}
