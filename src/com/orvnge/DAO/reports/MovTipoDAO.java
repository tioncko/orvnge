package com.orvnge.DAO.reports;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.model.entities.reports.*;

import java.sql.*;
import java.util.*;

public class MovTipoDAO {
    public List<MovTipo> listarTodos(Usuario usr, String mes, int tipoMov) {
        String sql = "select * from fc_movimentacao_tipo(?, ?, ?)";
        List<MovTipo> lista = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, usr.getIdCli());
            stmt.setString(2, mes);
            stmt.setInt(3, tipoMov);

            ResultSet rs = stmt.executeQuery();

            while(rs.next()) {
                lista.add(montarMovTipo(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar movimentações por tipo: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    private MovTipo montarMovTipo(ResultSet rs) throws SQLException {
        MovTipo movTipo = new MovTipo();
        movTipo.setId(rs.getInt("id"));
        movTipo.setMesAno(rs.getString("mesano"));
        movTipo.setNomeGrupo(rs.getString("nomegrupo"));
        movTipo.setInfoDesc(rs.getString("infodesc"));
        movTipo.setValor(rs.getString("valor"));
        return movTipo;
    }
}
