package com.orvnge.model.entities.reports;

public class Espelho {
    private String mesAno;
    private String despesa;
    private String receita;
    private String saldo_meio;
    private String saldo_fim;

    public Espelho() {}

    public Espelho(String mesAno, String despesa, String receita, String saldo_meio, String saldo_fim) {
        this.mesAno = mesAno;
        this.despesa = despesa;
        this.receita = receita;
        this.saldo_meio = saldo_meio;
        this.saldo_fim = saldo_fim;
    }

    public String getMesAno() {
        return mesAno;
    }

    public void setMesAno(String mesAno) {
        this.mesAno = mesAno;
    }

    public String getDespesa() {
        return despesa;
    }

    public void setDespesa(String despesa) {
        this.despesa = despesa;
    }

    public String getReceita() {
        return receita;
    }

    public void setReceita(String receita) {
        this.receita = receita;
    }

    public String getSaldo_meio() {
        return saldo_meio;
    }

    public void setSaldo_meio(String saldo_meio) {
        this.saldo_meio = saldo_meio;
    }

    public String getSaldo_fim() {
        return saldo_fim;
    }

    public void setSaldo_fim(String saldo_fim) {
        this.saldo_fim = saldo_fim;
    }
}
