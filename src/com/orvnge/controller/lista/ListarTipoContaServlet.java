package com.orvnge.controller.lista;

import com.orvnge.service.implementation.ListaService;
import org.json.JSONArray;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/listar-tipo-conta")
public class ListarTipoContaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String app = "application/json; charset=UTF-8";
        resp.setContentType(app);

        ListaService service = new ListaService();
        JSONArray arr = service.ListarTipoConta();

        resp.getWriter().write(arr.toString());
    }
}
