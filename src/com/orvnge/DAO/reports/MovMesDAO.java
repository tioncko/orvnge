package com.orvnge.DAO.reports;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.model.entities.reports.*;

import java.sql.*;
import java.util.*;

public class MovMesDAO {
    public List<MovMes> listarTodos(Usuario usr, String mes, int tipoMov) {
        String sql = "select * from fc_movimentacao_mes(?, ?, ?)";
        List<MovMes> lista = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, usr.getIdCli());
            stmt.setString(2, mes);
            stmt.setInt(3, tipoMov);

            ResultSet rs = stmt.executeQuery();

            while(rs.next()) {
                lista.add(montarMovMes(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar movimentações por mês: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    private MovMes montarMovMes(ResultSet rs) throws SQLException {
        MovMes movMes = new MovMes();
        movMes.setMesAno(rs.getString("mesano"));
        movMes.setTotalMes(rs.getString("totalmes"));
        return movMes;
    }
}
