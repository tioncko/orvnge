package com.orvnge.model.entities.core;

public class Conta {
    private int idConta;
    private String numConta;
    private double saldoInicial;
    private Usuario usuario;
    private Banco banco;
    private TipoConta tipoConta;

    public Conta() {
    }

    public Conta(int idConta, String numConta, double saldo, Banco banco, TipoConta tipoConta, Usuario usuario) {
        this.idConta = idConta;
        this.numConta = numConta;
        this.saldoInicial = saldo;
        this.banco = banco;
        this.tipoConta = tipoConta;
        this.usuario = usuario;
    }

    public int getIdConta() {
        return idConta;
    }

    public void setIdConta(int idConta) {
        this.idConta = idConta;
    }

    public String getNumConta() {
        return numConta;
    }

    public void setNumConta(String numConta) {
        this.numConta = numConta;
    }

    public double getSaldo() {
        return saldoInicial;
    }

    public void setSaldo(double saldo) {
        this.saldoInicial = saldo;
    }

    public Banco getBanco() {
        return banco;
    }

    public void setBanco(Banco banco) {
        this.banco = banco;
    }

    public TipoConta getTipoConta() {
        return tipoConta;
    }

    public void setTipoConta(TipoConta tipoConta) {
        this.tipoConta = tipoConta;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    @Override
    public String toString() {
        return "Conta [idConta=" + idConta + ", numConta=" + numConta + ", saldoInicial=" + saldoInicial +
               ", banco=" + banco + ", tipoConta=" + tipoConta + ", usuario=" + usuario + "]";
    }
}
