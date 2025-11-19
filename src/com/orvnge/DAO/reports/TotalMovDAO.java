package com.orvnge.DAO.reports;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.model.entities.reports.*;

import java.sql.*;
import java.util.*;

public class TotalMovDAO {
    public List<TotalMov> listarTodos(Usuario usr, String mes, int tipoMov) {
        String sql = "select * from fc_total_movimentacao(?, ?, ?)";
        List<TotalMov> lista = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, usr.getIdCli());
            stmt.setString(2, mes);
            stmt.setInt(3, tipoMov);

            ResultSet rs = stmt.executeQuery();

            while(rs.next()) {
                lista.add(montarTotalMov(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar movimentações: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    public TotalMov montarTotalMov(ResultSet rs) throws SQLException {
        TotalMov totalMov = new TotalMov();
        totalMov.setTotalMes(rs.getString("totalmes"));
        return totalMov;
    }
}
