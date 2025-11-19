package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.TipoConta;

import java.sql.*;
import java.util.*;

public class TipoContaDAO {
    public TipoConta buscarPorId(int idTipoConta) {
        String sql = "SELECT * FROM TipoConta WHERE idTipoConta = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idTipoConta);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return montarTipoConta(rs);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao buscar tipo de conta por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return new TipoConta();
    }

    public List<TipoConta> listarTodos() {
        String sql = "SELECT * FROM TipoConta";
        List<TipoConta> tiposConta = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                tiposConta.add(montarTipoConta(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar tipos de conta: " + e.getMessage());
            e.printStackTrace();
        }

        return tiposConta;
    }

    private TipoConta montarTipoConta(ResultSet rs) throws SQLException {
        TipoConta tipoConta = new TipoConta();
        tipoConta.setIdTipoConta(rs.getInt("idTipoConta"));
        tipoConta.setNomeTipoConta(rs.getString("nomeTipoConta"));
        return tipoConta;
    }
}
