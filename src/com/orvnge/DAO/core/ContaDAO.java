package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Banco;
import com.orvnge.model.entities.core.Conta;
import com.orvnge.model.entities.core.TipoConta;
import com.orvnge.model.entities.core.Usuario;

import java.sql.*;
import java.util.*;

public class ContaDAO {
    public void inserir(Conta conta) {
        String sql = "INSERT INTO conta (idConta, NConta, SaldoInicial, IdCliente, idBanco, idTipoConta) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, conta.getIdConta());
            stmt.setString(2, conta.getNumConta());
            stmt.setDouble(3, conta.getSaldo());
            stmt.setInt(6, conta.getUsuario().getIdCli());
            stmt.setInt(4, conta.getBanco().getIdBanco());
            stmt.setInt(5, conta.getTipoConta().getIdTipoConta());

            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao inserir conta: " + e.getMessage());
            e.printStackTrace();
        }
    }


    public void atualizar(Conta conta) {
        String sql = "UPDATE conta SET NConta = ?, SaldoInicial = ?, idBanco = ?, idTipoConta = ? " +
                "WHERE idConta = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setString(1, conta.getNumConta());
            stmt.setDouble(2, conta.getSaldo());
            stmt.setInt(3, conta.getBanco().getIdBanco());
            stmt.setInt(4, conta.getTipoConta().getIdTipoConta());
            stmt.setInt(5, conta.getUsuario().getIdCli());
            stmt.setInt(6, conta.getIdConta());

            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao atualizar conta: " + e.getMessage());
            e.printStackTrace();
        }
    }


    public void deletar(int idConta) {
        String sql = "DELETE FROM conta WHERE idConta = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idConta);
            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao deletar conta: " + e.getMessage());
            e.printStackTrace();
        }
    }


    public Conta buscarPorId(int idConta) {
        String sql = "SELECT * FROM conta WHERE idConta = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idConta);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return montarConta(rs);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao buscar conta por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }


    public List<Conta> listarTodos() {
        String sql = "SELECT * FROM conta";
        List<Conta> contas = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                contas.add(montarConta(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar contas: " + e.getMessage());
            e.printStackTrace();
        }

        return contas;
    }


    private Conta montarConta(ResultSet rs) throws SQLException {
        Conta conta = new Conta();
        conta.setIdConta(rs.getInt("idConta"));
        conta.setNumConta(rs.getString("NConta"));
        conta.setSaldo(rs.getDouble("SaldoInicial"));

        BancoDAO dao_bc = new BancoDAO();
        Banco banco = dao_bc.buscarPorId(rs.getInt("idBanco"));
        conta.setBanco(banco);

        TipoContaDAO dao_tc = new TipoContaDAO();
        TipoConta tipoConta = dao_tc.buscarPorId(rs.getInt("idTipoConta"));
        conta.setTipoConta(tipoConta);

        UsuarioDAO dao_us = new UsuarioDAO();
        Usuario usuario =
                dao_us.buscarPorCpf(
                        rs.getString("cpf"),
                        rs.getInt("IdCliente"));
        conta.setUsuario(usuario);

        return conta;
    }
}
