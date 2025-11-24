package com.orvnge.service.interfaces;

import org.json.JSONObject;
import java.time.LocalDate;

public interface IMovimentacao {
    void cadastrarMovimentacao(LocalDate dataMov, String descricao, double valor, int idConta, int idGrupoMov);
    void alterarMovimentacao(int idMov, LocalDate dataMov, String descricao, double valor, int idConta, int idGrupoMov);
    void excluirMovimentacao(int idMov);
    JSONObject buscarMovimentacao(int idMov);
}
