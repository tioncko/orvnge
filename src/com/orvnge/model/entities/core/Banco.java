package com.orvnge.model.entities.core;

public class Banco {
    private int idBanco;
    private String sglBanco;
    private String nome;

    public Banco() {
    }

    public Banco(int idBanco, String sglBanco, String nome) {
        this.idBanco = idBanco;
        this.sglBanco = sglBanco;
        this.nome = nome;
    }

    public int getIdBanco() {
        return idBanco;
    }

    public void setIdBanco(int idBanco) {
        this.idBanco = idBanco;
    }

    public String getSglBanco() {
        return sglBanco;
    }

    public void setSglBanco(String sglBanco) {
        this.sglBanco = sglBanco;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    @Override
    public String toString() {
        return "Banco [idBanco=" + idBanco + ", sglBanco=" + sglBanco + ", nome=" + nome + "]";
    }
}
