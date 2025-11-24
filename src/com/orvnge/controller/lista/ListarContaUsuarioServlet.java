package com.orvnge.controller.lista;

import com.orvnge.service.implementation.ListaService;
import org.json.JSONArray;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/listar-conta-usuario")
public class ListarContaUsuarioServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String app = "application/json; charset=UTF-8";
        resp.setContentType(app);

        String idCli = req.getParameter("idCli");

        ListaService service = new ListaService();
        JSONArray arr = service.ListarContaUsuario(Integer.parseInt(idCli));

        resp.getWriter().write(arr.toString());
    }
}
