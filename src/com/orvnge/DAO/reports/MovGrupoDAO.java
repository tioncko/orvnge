package com.orvnge.DAO.reports;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.model.entities.reports.*;

import java.sql.*;
import java.util.*;

public class MovGrupoDAO {
    public List<MovGrupo> listarTodos(Usuario usr, String mes, int tipoMov) {
        String sql = "select * from fc_movimentacao_grupo(?, ?, ?)";
        List<MovGrupo> lista = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, usr.getIdCli());
            stmt.setString(2, mes);
            stmt.setInt(3, tipoMov);

            ResultSet rs = stmt.executeQuery();

            while(rs.next()) {
                lista.add(montarMovGrupo(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar movimentações por grupo: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    private MovGrupo montarMovGrupo(ResultSet rs) throws SQLException {
        MovGrupo movGrupo = new MovGrupo();
        movGrupo.setNomeGrupo(rs.getString("nomegrupo"));
        movGrupo.setTotalGrupo(rs.getString("totalgrupo"));
        return movGrupo;
    }
}
