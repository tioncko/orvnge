package com.orvnge.service.interfaces;

import org.json.JSONObject;

public interface IUsuario {
    void cadastrarUsuario(String nome, String cpf, String tel, String email, String senha);
    void alterarUsuario(int idCli, String nome, String cpf, String tel, String email);
    void excluirUsuario(String cpf);
    JSONObject buscarUsuario(String usr, int typeProcess);
    boolean autenticarUsuario(String usr, String senha);
    void atualizarSenha(int id, String senha);
}
