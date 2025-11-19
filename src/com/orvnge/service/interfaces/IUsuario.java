package com.orvnge.service.interfaces;

import org.json.JSONObject;

public interface IUsuario {
    void cadastrarUsuario(int idCli, String nome, String cpf, String tel, String email, String senha);
    void alterarUsuario(int idCli, String nome, String cpf, String tel, String email, String senha);
    void excluirUsuario(String cpf, int idCli);
    JSONObject buscarUsuario(String cpf, int idCli);
    boolean autenticarUsuario(String usr, String senha);
}
