package com.orvnge.service.implementation;

import com.orvnge.DAO.core.UsuarioDAO;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.service.interfaces.IUsuario;
import org.json.JSONObject;

public class UsuarioService implements IUsuario {
    @Override
    public void cadastrarUsuario(String nome, String cpf, String tel, String email, String senha) {
        UsuarioDAO dao = new UsuarioDAO();
        Usuario user = new Usuario(nome, cpf, tel, email, senha);
        dao.inserir(user);
    }

    @Override
    public void alterarUsuario(int idCli, String nome, String cpf, String email, String tel) {
        UsuarioDAO dao = new UsuarioDAO();
        Usuario user = new Usuario(idCli, nome, cpf, tel, email);
        dao.atualizar(user);
    }

    @Override
    public void excluirUsuario(String cpf) {
        UsuarioDAO dao = new UsuarioDAO();
        dao.deletar(cpf);
    }

    @Override
    public JSONObject buscarUsuario(String usr, int typeProcess) {
        UsuarioDAO dao = new UsuarioDAO();
        //0 - Busca por id
        //1 - Busca por email
        Usuario user;
        if (typeProcess == 1) {
            user = dao.buscarPorEmail(usr);
        } else {
            user = dao.buscarPorId(Integer.parseInt(usr));
        };

        JSONObject json = new JSONObject();
        json.put("idCli", user.getIdCli());
        json.put("nome", user.getNome());
        json.put("cpf", user.getCpf());
        json.put("tel", user.getTel());
        json.put("email", user.getEmail());
        json.put("senha", user.getSenha());
        return json;
    }

    @Override
    public boolean autenticarUsuario(String usr, String senha) {
        UsuarioDAO dao = new UsuarioDAO();
        return dao.autenticar(usr, senha);
    }

    public void atualizarSenha(int id, String senha) {
        UsuarioDAO dao = new UsuarioDAO();
        dao.atualizarSenha(id, senha);
    }
}
