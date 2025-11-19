package com.orvnge.controller.relatorio;

import com.orvnge.service.implementation.RelatoriosService;
import org.json.JSONArray;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/listar-mov-grupo")
public class ListarMovGrupoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String app = "application/json; charset=UTF-8";
        resp.setContentType(app);

        String idCli = req.getParameter("idCli");
        String cpf = req.getParameter("cpf");
        String mes = req.getParameter("mes");
        int tipoMov = Integer.parseInt(req.getParameter("tipoMov"));

        RelatoriosService service = new RelatoriosService();
        JSONArray arr = service.ListarMovGrupo(cpf, Integer.parseInt(idCli), mes, tipoMov);

        resp.getWriter().write(arr.toString());
    }
}
