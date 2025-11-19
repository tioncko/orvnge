package com.orvnge.model.entities.core;

public class Usuario {
    private int idCli;
    private String nome;
    private String cpf;
    private String tel;
    private String email;
    private String senha;

    public Usuario() {
    }

    public Usuario(int id, String nome, String cpf, String tel, String email, String senha) {
        this.idCli = id;
        this.nome = nome;
        this.cpf = cpf;
        this.tel = tel;
        this.email = email;
        this.senha = senha;
    }

    public int getIdCli() {
        return idCli;
    }

    public void setIdCli(int id) {
        this.idCli = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getTel() {
        return tel;
    }

    public void setTel(String tel) {
        this.tel = tel;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    @Override
    public String toString() {
        return "Usuario [id=" + idCli + ", nome=" + nome + ", cpf=" + cpf + ", tel=" + tel + ", email=" + email + "]";
    }
}
