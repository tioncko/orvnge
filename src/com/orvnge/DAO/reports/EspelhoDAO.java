package com.orvnge.DAO.reports;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Usuario;
import com.orvnge.model.entities.reports.*;

import java.sql.*;
import java.util.*;

public class EspelhoDAO {
    public List<Espelho> listarTodos(Usuario usr) {
        String sql = "select * from fc_espelho(?)";
        List<Espelho> lista = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, usr.getIdCli());

            ResultSet rs = stmt.executeQuery();

            while(rs.next()) {
                lista.add(montarEspelho(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar espelho: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    public Espelho montarEspelho(ResultSet rs) throws SQLException {
        Espelho espelho = new Espelho();
        espelho.setMesAno(rs.getString("mesAno"));
        espelho.setReceita(rs.getString("receita"));
        espelho.setDespesa(rs.getString("despesa"));
        espelho.setSaldo_meio(rs.getString("saldo_meio"));
        espelho.setSaldo_fim(rs.getString("saldo_fim"));
        return espelho;
    }
}
