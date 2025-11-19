package com.orvnge.model.entities.core;

import java.time.LocalDate;

public class Movimentacao {
    private int idMov;
    private LocalDate dataMov;
    private String descricao;
    private double valor;
    private Conta conta;
    private GrupoMov grupoMov;

    public Movimentacao() {
    }

    public Movimentacao(int idMov, LocalDate dataMov, String descricao, double valor, Conta conta, GrupoMov grupoMov) {
        this.idMov = idMov;
        this.dataMov = dataMov;
        this.descricao = descricao;
        this.valor = valor;
        this.conta = conta;
        this.grupoMov = grupoMov;
    }

    public int getIdMov() {
        return idMov;
    }

    public void setIdMov(int idMov) {
        this.idMov = idMov;
    }

    public double getValor() {
        return valor;
    }

    public void setValor(double valor) {
        this.valor = valor;
    }

    public LocalDate getDataMov() {
        return dataMov;
    }

    public void setDataMov(LocalDate dataMov) {
        this.dataMov = dataMov;
    }

    public Conta getConta() {
        return conta;
    }

    public void setConta(Conta conta) {
        this.conta = conta;
    }

    public GrupoMov getGrupoMov() {
        return grupoMov;
    }

    public void setGrupoMov(GrupoMov tipoMov) {
        this.grupoMov = tipoMov;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    @Override
    public String toString() {
        return "Movimentacao [idMov=" + idMov + ", valor=" + valor + ", dataMov=" + dataMov +
               ", conta=" + conta + ", grupoMov=" + grupoMov + "]";
    }
}
