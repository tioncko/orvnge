package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.ContaUsuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ContaUsuarioDAO {
    public ContaUsuario buscarPorId(int idCli) {
        String sql = "SELECT * FROM fc_contas_usuario WHERE clientId = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idCli);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return montarContaUsuario(rs);
            }

        } catch (SQLException e) {
            System.out.println("Erro ao buscar conta por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return new ContaUsuario();
    }

    public List<ContaUsuario> listarTodos(int idCli) {
        String sql = "SELECT * FROM fc_contas_usuario(?)";
        List<ContaUsuario> contasUsr = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idCli);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                contasUsr.add(montarContaUsuario(rs));
            }
            return contasUsr;

        } catch (SQLException e) {
            System.out.println("Erro ao listar contas: " + e.getMessage());
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

    private ContaUsuario montarContaUsuario(ResultSet rs) throws SQLException {
        ContaUsuario contaUsr = new ContaUsuario();
        contaUsr.setIdConta(rs.getInt("idConta"));
        contaUsr.setConta(rs.getString("conta"));
        contaUsr.setSaldoInicial(rs.getString("saldoInicial"));
        contaUsr.setIdCli(rs.getInt("clientId"));
        contaUsr.setIdTipoConta(rs.getInt("tipoContaId"));
        return contaUsr;
    }
}
