package com.orvnge.service.interfaces;

import org.json.JSONObject;

public interface IConta {
    void cadastrarConta(int idConta, String numConta, double saldo, int idBanco, int idTipoConta, int idCli, String cpf);
    void alterarConta(int idConta, String numConta, double saldo, int idBanco, int idTipoConta, int idCli, String cpf);
    void excluirConta(int idConta);
    JSONObject buscarConta(int idConta);
}
