package com.orvnge.service.implementation;

import com.orvnge.DAO.core.*;
import com.orvnge.model.entities.core.*;
import com.orvnge.service.interfaces.ILista;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;

public class ListaService implements ILista {
    @Override
    public JSONArray ListarBanco() {
        BancoDAO dao = new BancoDAO();
        List<Banco> bancos = dao.listarTodos();

        JSONArray arr = new JSONArray();

        for(Banco b : bancos) {
            JSONObject obj = new JSONObject();
            obj.put("idBanco", b.getIdBanco());
            obj.put("sglBanco", b.getSglBanco());
            obj.put("nome", b.getNome());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarTipoConta() {
        TipoContaDAO dao = new TipoContaDAO();
        List<TipoConta> tipoContas = dao.listarTodos();

        JSONArray arr = new JSONArray();

        for(TipoConta tc : tipoContas) {
            JSONObject obj = new JSONObject();
            obj.put("idTipoConta", tc.getIdTipoConta());
            obj.put("nomeTipoConta", tc.getNomeTipoConta());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarTipoMov() {
        TipoMovDAO dao = new TipoMovDAO();
        List<TipoMov> tipoMovs = dao.listarTodos();

        JSONArray arr = new JSONArray();

        for(TipoMov tm : tipoMovs) {
            JSONObject obj = new JSONObject();
            obj.put("idTipoMov", tm.getIdTipoMov());
            obj.put("nomeTipoMov", tm.getNomeTipoMov());
            arr.put(obj);
        }
        return arr;
    }

    @Override
    public JSONArray ListarGrupoMov() {
        GrupoMovDAO dao = new GrupoMovDAO();
        List<GrupoMov> grupoMovs = dao.listarTodos();

        JSONArray arr = new JSONArray();

        for(GrupoMov gm : grupoMovs) {
            JSONObject obj = new JSONObject();
            obj.put("idGrupoMov", gm.getIdGrupoMov());
            obj.put("nomeGrupoMov", gm.getNome());
            obj.put("tipoMov", gm.getTipoMov().getNomeTipoMov());
            arr.put(obj);
        }
        return arr;
    }
}
