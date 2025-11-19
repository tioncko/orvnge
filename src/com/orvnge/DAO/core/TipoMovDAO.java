package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.TipoMov;

import java.sql.*;
import java.util.*;

public class TipoMovDAO {
    public TipoMov buscarPorId(int idTipoMov) {
        String sql = "SELECT * FROM TipoMov WHERE idTipoMov = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idTipoMov);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return montarTipoMov(rs);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao buscar tipo de movimentação por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return new TipoMov();
    }

    public List<TipoMov> listarTodos() {
        String sql = "SELECT * FROM TipoMov";
        List<TipoMov> tiposMov = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                tiposMov.add(montarTipoMov(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar tipos de movimentação: " + e.getMessage());
            e.printStackTrace();
        }

        return tiposMov;
    }

    private TipoMov montarTipoMov(ResultSet rs) throws SQLException {
        TipoMov tipoMov = new TipoMov();
        tipoMov.setIdTipoMov(rs.getInt("idTipoMov"));
        tipoMov.setNomeTipoMov(rs.getString("nomeTipoMov"));
        return tipoMov;
    }
}
