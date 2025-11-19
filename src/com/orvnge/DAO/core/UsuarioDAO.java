package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Usuario;

import java.sql.*;
import java.util.*;

public class UsuarioDAO {

    public void inserir(Usuario u) {
        String sql = "INSERT INTO usuario (cpf, nome, tel, email, senha) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, u.getCpf());
            ps.setString(2, u.getNome());
            ps.setString(3, u.getTel());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getSenha());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
// Todos os metodos de atualizar serão ajustados para alteração individual
    public void atualizar(Usuario u) {
        String sql = "UPDATE usuario SET nome = ?, tel = ?, email = ?, senha = ? WHERE cpf = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, u.getNome());
            ps.setString(2, u.getTel());
            ps.setString(3, u.getEmail());
            ps.setString(4, u.getSenha());
            ps.setString(5, u.getCpf());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void deletar(String cpf, int idCliente) {
        String sql = "DELETE FROM usuario WHERE cpf = ? and idcliente = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cpf);
            ps.setInt(2, idCliente);

            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Usuario buscarPorCpf(String cpf, int idCliente) {
        String sql = "SELECT * FROM usuario WHERE cpf = ? and idCliente = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cpf);
            ps.setInt(2, idCliente);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return montarUsuario(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return new Usuario();
    }

    public boolean autenticar(String usr, String pass) {
        String sql = "SELECT * FROM USUARIO WHERE email = ? and senha = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usr);
            stmt.setString(2, pass);

            ResultSet rs = stmt.executeQuery();
            if(rs.next()) {
                return true;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return false;
    }

    public Usuario montarUsuario(ResultSet rs) throws SQLException {
        Usuario usr = new Usuario();
        usr.setIdCli(rs.getInt("idCli"));
        usr.setCpf(rs.getString("cpf"));
        usr.setNome(rs.getString("nome"));
        usr.setTel(rs.getString("tel"));
        usr.setEmail(rs.getString("email"));
        usr.setSenha(rs.getString("senha"));
        return usr;
    }
}
