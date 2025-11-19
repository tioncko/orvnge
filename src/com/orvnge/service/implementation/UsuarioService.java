package com.orvnge.service.implementation;

import com.orvnge.DAO.core.UsuarioDAO;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.service.interfaces.IUsuario;
import org.json.JSONObject;

public class UsuarioService implements IUsuario {
    @Override
    public void cadastrarUsuario(int idCli, String nome, String cpf, String tel, String email, String senha) {
        UsuarioDAO dao = new UsuarioDAO();
        Usuario user = new Usuario(idCli, nome, cpf, tel, email, senha);
        dao.inserir(user);
    }

    @Override
    public void alterarUsuario(int idCli, String nome, String cpf, String tel, String email, String senha) {
        UsuarioDAO dao = new UsuarioDAO();
        Usuario user = new Usuario(idCli, nome, cpf, tel, email, senha);
        dao.atualizar(user);
    }

    @Override
    public void excluirUsuario(String cpf, int idCli) {
        UsuarioDAO dao = new UsuarioDAO();
        dao.deletar(cpf, idCli);
    }

    @Override
    public JSONObject buscarUsuario(String cpf, int idCli) {
        UsuarioDAO dao = new UsuarioDAO();
        Usuario user = dao.buscarPorCpf(cpf, idCli);

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
}
