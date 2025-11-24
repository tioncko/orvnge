package com.orvnge.DAO.core;

import java.sql.*;
import java.util.*;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Banco;
import com.orvnge.model.entities.core.Movimentacao;

public class BancoDAO {
    public Banco buscarPorId(int idBanco) {
        String sql = "SELECT * FROM banco WHERE idBanco = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idBanco);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
               return montarBanco(rs);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao buscar banco por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return new Banco();
    }


    public List<Banco> listarTodos() {
        String sql = "SELECT * FROM banco";
        List<Banco> bancos = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                bancos.add(montarBanco(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar bancos: " + e.getMessage());
            e.printStackTrace();
        }

        return bancos;
    }

    private Banco montarBanco(ResultSet rs) throws SQLException {
        Banco banco = new Banco();
        banco.setIdBanco(rs.getInt("idBanco"));
        banco.setSglBanco(rs.getString("sglBanco"));
        banco.setNome(rs.getString("nome"));
        return banco;
    }

}
