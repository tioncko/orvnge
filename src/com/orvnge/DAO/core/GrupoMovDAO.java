package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.GrupoMov;
import com.orvnge.model.entities.core.TipoMov;

import java.sql.*;
import java.util.*;

public class GrupoMovDAO {
    public GrupoMov buscarPorId(int idGrupoMov) {
        String sql = "SELECT * FROM GrupoMov where idGrupoMov = ?";

        try(Connection conexao = DBConnection.getConnection();
            PreparedStatement stmt = conexao.prepareStatement(sql)){

            stmt.setInt(1, idGrupoMov);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return montarGrupoMov(rs);
            }
        } catch (Exception e) {
            System.out.println("Erro ao buscar grupo de movimentação por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return new GrupoMov();
    }

    public List<GrupoMov> listarTodos() {
        String sql = "SELECT * FROM GrupoMov";
        List<GrupoMov> gruposMov = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                gruposMov.add(montarGrupoMov(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar grupos de movimentação: " + e.getMessage());
            e.printStackTrace();
        }

        return gruposMov;
    }

    public GrupoMov montarGrupoMov(ResultSet rs) throws SQLException {
        GrupoMov grupoMov = new GrupoMov();
        grupoMov.setIdGrupoMov(rs.getInt("idGrupoMov"));
        grupoMov.setNome(rs.getString("nomeGrupoMov"));

        TipoMovDAO dao = new TipoMovDAO();
        TipoMov tipoMov = dao.buscarPorId(rs.getInt("idTipoMov"));
        grupoMov.setTipoMov(tipoMov);

        return grupoMov;
    }
}
