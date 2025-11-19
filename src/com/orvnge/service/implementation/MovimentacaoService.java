package com.orvnge.service.implementation;

import com.orvnge.DAO.core.*;
import com.orvnge.model.entities.core.*;
import com.orvnge.service.interfaces.IMovimentacao;
import org.json.JSONArray;
import org.json.JSONObject;

import java.time.LocalDate;

public class MovimentacaoService implements IMovimentacao {
    private final MovimentacaoDAO dao_mv = new MovimentacaoDAO();
    private final ContaDAO dao_ct = new ContaDAO();
    private final GrupoMovDAO dao_gm = new GrupoMovDAO();

    @Override
    public void cadastrarMovimentacao(int idMov, LocalDate dataMov, String descricao, double valor, int idConta, int idGrupoMov) {
        Conta conta = dao_ct.buscarPorId(idConta);
        GrupoMov grupoMov = dao_gm.buscarPorId(idGrupoMov);

        Movimentacao mov = new Movimentacao(idMov, dataMov, descricao, valor, conta, grupoMov);
        dao_mv.inserir(mov);
    }

    @Override
    public void alterarMovimentacao(int idMov, LocalDate dataMov, String descricao, double valor, int idConta, int idGrupoMov) {
        Conta conta = dao_ct.buscarPorId(idConta);
        GrupoMov grupoMov = dao_gm.buscarPorId(idGrupoMov);

        Movimentacao mov = new Movimentacao(idMov, dataMov, descricao, valor, conta, grupoMov);
        dao_mv.atualizar(mov);
    }

    @Override
    public void excluirMovimentacao(int idMov) {
        dao_mv.deletar(idMov);
    }

    @Override
    public JSONObject buscarMovimentacao(int idMov) {
        Movimentacao mov = dao_mv.buscarPorId(idMov);

        JSONObject json = new JSONObject();
        json.put("idMov", mov.getIdMov());
        json.put("dataMov", mov.getDataMov());
        json.put("descricao", mov.getDescricao());
        json.put("valor", mov.getValor());
        json.put("conta", mov.getConta());
        json.put("grupoMov", mov.getGrupoMov());
        return json;
    }
}
