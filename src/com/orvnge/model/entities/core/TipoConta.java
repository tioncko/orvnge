package com.orvnge.model.entities.core;

public class TipoConta {
    private int idTipoConta;
    private String nomeTipoConta;

    public TipoConta() {
    }

    public TipoConta(int idTipoConta, String nomeTipoConta) {
        this.idTipoConta = idTipoConta;
        this.nomeTipoConta = nomeTipoConta;
    }

    public int getIdTipoConta() {
        return idTipoConta;
    }

    public void setIdTipoConta(int idTipoConta) {
        this.idTipoConta = idTipoConta;
    }

    public String getNomeTipoConta() {
        return nomeTipoConta;
    }

    public void setNomeTipoConta(String nomeTipoConta) {
        this.nomeTipoConta = nomeTipoConta;
    }

    @Override
    public String toString() {
        return "TipoConta [idTipoConta=" + idTipoConta + ", nomeTipoConta=" + nomeTipoConta + "]";
    }
}
