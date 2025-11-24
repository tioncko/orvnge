package com.orvnge.model.entities.core;

public class ContaUsuario {
    private int idConta;
    private String conta;
    private String saldoInicial;
    private int idCli;
    private int idTipoConta;

    public ContaUsuario() {}

    public ContaUsuario(int idConta, String conta, String saldoInicial, int idCli, int idTipoConta) {
        this.idConta = idConta;
        this.conta = conta;
        this.saldoInicial = saldoInicial;
        this.idCli = idCli;
        this.idTipoConta = idTipoConta;
    }

    public int getIdConta() {
        return idConta;
    }

    public void setIdConta(int idConta) {
        this.idConta = idConta;
    }

    public String getConta() {
        return conta;
    }

    public void setConta(String conta) {
        this.conta = conta;
    }

    public String getSaldoInicial() {
        return saldoInicial;
    }

    public void setSaldoInicial(String saldoInicial) {
        this.saldoInicial = saldoInicial;
    }

    public int getIdCli() {
        return idCli;
    }

    public void setIdCli(int idCli) {
        this.idCli = idCli;
    }

    public int getIdTipoConta() {
        return idTipoConta;
    }

    public void setIdTipoConta(int idTipoConta) {
        this.idTipoConta = idTipoConta;
    }
}
