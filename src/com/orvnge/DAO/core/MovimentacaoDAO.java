package com.orvnge.DAO.core;

import com.orvnge.database.service.DBConnection;
import com.orvnge.model.entities.core.Conta;
import com.orvnge.model.entities.core.GrupoMov;
import com.orvnge.model.entities.core.Movimentacao;

import java.sql.*;
import java.sql.Date;
import java.sql.Types;
import java.time.LocalDate;
import java.util.*;

public class MovimentacaoDAO {
    public void inserir(Movimentacao mov) {
        String sql = "INSERT INTO movimentacao (data, Descricao, Valor, IdConta, IdGrupoMov) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            if (mov.getDataMov() != null) {
                LocalDate dataMov = mov.getDataMov();
                stmt.setDate(1, Date.valueOf(dataMov));
            } else {
                stmt.setNull(1, Types.DATE);
            }
            stmt.setString(2, mov.getDescricao());
            stmt.setDouble(3, mov.getValor());

            stmt.setInt(4, mov.getConta().getIdConta());
            stmt.setInt(5, mov.getGrupoMov().getIdGrupoMov());

            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao inserir movimentação: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void atualizar(Movimentacao mov) {
        String sql = "UPDATE movimentacao SET valor = ?, data = ?, idConta = ?, IdGrupoMov = ? " +
                "WHERE idMov = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setDouble(1, mov.getValor());

            if (mov.getDataMov() != null) {
                stmt.setDate(2, Date.valueOf(mov.getDataMov()));
            } else {
                stmt.setNull(2, Types.DATE);
            }

            stmt.setInt(3, mov.getConta().getIdConta());
            stmt.setInt(4, mov.getGrupoMov().getIdGrupoMov());
            stmt.setInt(5, mov.getIdMov());

            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao atualizar movimentação: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void deletar(int idMov) {
        String sql = "DELETE FROM movimentacao WHERE idMov = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idMov);
            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao deletar movimentação: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public Movimentacao buscarPorId(int idMov) {
        String sql = "SELECT * FROM movimentacao WHERE idMov = ?";

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setInt(1, idMov);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return montarMovimentacao(rs);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao buscar movimentação por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return new Movimentacao();
    }

    /*
    public List<Movimentacao> listarTodos() {
        String sql = "SELECT * FROM movimentacao";
        List<Movimentacao> movimentacoes = new ArrayList<>();

        try (Connection conexao = DBConnection.getConnection();
             PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                movimentacoes.add(montarMovimentacao(rs));
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar movimentações: " + e.getMessage());
            e.printStackTrace();
        }

        return movimentacoes;
    }*/

    private Movimentacao montarMovimentacao(ResultSet rs) throws SQLException {
        Movimentacao mov = new Movimentacao();
        mov.setIdMov(rs.getInt("idMov"));
        mov.setValor(rs.getDouble("valor"));
        mov.setDescricao(rs.getString("descricao"));

        Date data = rs.getDate("data");
        if (data != null) {
            mov.setDataMov(data.toLocalDate());
        } else {
            mov.setDataMov(null);
        }

        ContaDAO dao_ct = new ContaDAO();
        Conta conta = dao_ct.buscarPorId(rs.getInt("idConta"));
        mov.setConta(conta);

        GrupoMovDAO dao_gp = new GrupoMovDAO();
        GrupoMov grupoMov = dao_gp.buscarPorId(rs.getInt("IdGrupoMov"));
        mov.setGrupoMov(grupoMov);

        return mov;
    }
}
