package com.orvnge.service.implementation;

import com.orvnge.DAO.core.*;
import com.orvnge.DAO.reports.*;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.model.entities.reports.*;
import com.orvnge.service.interfaces.IRelatorio;
import org.json.*;

import java.util.List;

public class RelatoriosService implements IRelatorio {
    private final UsuarioDAO dao_us = new UsuarioDAO();

    @Override
    public JSONArray ListarEspelho(String cpf) {
        EspelhoDAO dao_es = new EspelhoDAO();
        Usuario usr = dao_us.buscarPorCpf(cpf);
        List<Espelho> espelho = dao_es.listarTodos(usr);

        JSONArray arr = new JSONArray();

        for (Espelho e : espelho) {
            JSONObject obj = new JSONObject();
            obj.put("mesAno", e.getMesAno());
            obj.put("despesa", e.getDespesa());
            obj.put("receita", e.getReceita());
            obj.put("saldo_meio", e.getSaldo_meio());
            obj.put("saldo_fim", e.getSaldo_fim());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarMovGrupo(String cpf, String mes, int tipoMov) {
        MovGrupoDAO dao = new MovGrupoDAO();
        Usuario usr = dao_us.buscarPorCpf(cpf);
        List<MovGrupo> movGrupo = dao.listarTodos(usr, mes, tipoMov);

        JSONArray arr = new JSONArray();

        for (MovGrupo m : movGrupo) {
            JSONObject obj = new JSONObject();
            obj.put("nomeGrupo", m.getNomeGrupo());
            obj.put("totalGrupo", m.getTotalGrupo());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarMovMes(String cpf, String mes, int tipoMov) {
        MovMesDAO dao = new MovMesDAO();
        Usuario usr = dao_us.buscarPorCpf(cpf);
        List<MovMes> movMes = dao.listarTodos(usr, mes, tipoMov);

        JSONArray arr = new JSONArray();

        for (MovMes m : movMes) {
            JSONObject obj = new JSONObject();
            obj.put("mesAno", m.getMesAno());
            obj.put("totalMes", m.getTotalMes());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarMovTipo(String cpf, String mes, int tipoMov) {
        MovTipoDAO dao = new MovTipoDAO();
        Usuario usr = dao_us.buscarPorCpf(cpf);
        List<MovTipo> movTipo = dao.listarTodos(usr, mes, tipoMov);

        JSONArray arr = new JSONArray();

        for (MovTipo m : movTipo) {
            JSONObject obj = new JSONObject();
            obj.put("id", m.getId());
            obj.put("mesAno", m.getMesAno());
            obj.put("nomeGrupo", m.getNomeGrupo());
            obj.put("infoDesc", m.getInfoDesc());
            obj.put("valor", m.getValor());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarTotalMov(String cpf, String mes, int tipoMov) {
        TotalMovDAO dao = new TotalMovDAO();
        Usuario usr = dao_us.buscarPorCpf(cpf);
        List<TotalMov> totalMov = dao.listarTodos(usr, mes, tipoMov);

        JSONArray arr = new JSONArray();

        for (TotalMov t : totalMov) {
            JSONObject obj = new JSONObject();
            obj.put("totalMes", t.getTotalMes());
            arr.put(obj);
        }
        return arr;
    }
}
