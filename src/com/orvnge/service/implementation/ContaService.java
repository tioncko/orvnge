package com.orvnge.service.implementation;

import com.orvnge.DAO.core.*;
import com.orvnge.model.entities.core.*;
import com.orvnge.service.interfaces.IConta;
import org.json.JSONObject;

public class ContaService implements IConta {
    private final ContaDAO dao_ct = new ContaDAO();
    private final BancoDAO dao_bc = new BancoDAO();
    private final TipoContaDAO dao_tc = new TipoContaDAO();
    private final UsuarioDAO dao_us = new UsuarioDAO();

    @Override
    public void cadastrarConta(int idConta, String numConta, double saldo, int idBanco, int idTipoConta, int idCli, String cpf) {
        Banco banco = dao_bc.buscarPorId(idBanco);
        TipoConta tipoConta = dao_tc.buscarPorId(idTipoConta);
        Usuario usr = dao_us.buscarPorCpf(cpf, idCli);

        Conta ct = new Conta(idConta, numConta, saldo, banco, tipoConta, usr);
        dao_ct.inserir(ct);
    }

    @Override
    public void alterarConta(int idConta, String numConta, double saldo, int idBanco, int idTipoConta, int idCli, String cpf) {
        Banco banco = dao_bc.buscarPorId(idBanco);
        TipoConta tipoConta = dao_tc.buscarPorId(idTipoConta);
        Usuario usr = dao_us.buscarPorCpf(cpf, idCli);

        Conta ct = new Conta(idConta, numConta, saldo, banco, tipoConta, usr);
        dao_ct.atualizar(ct);
    }

    @Override
    public void excluirConta(int idConta) {
        dao_ct.deletar(idConta);
    }

    @Override
    public JSONObject buscarConta(int idConta) {
        Conta ct = dao_ct.buscarPorId(idConta);

        JSONObject json = new JSONObject();
        json.put("idConta", ct.getIdConta());
        json.put("numConta", ct.getNumConta());
        json.put("saldo", ct.getSaldo());
        json.put("banco", ct.getBanco());
        json.put("tipoConta", ct.getTipoConta());
        json.put("usuario", ct.getUsuario());
        return json;
    }
}
