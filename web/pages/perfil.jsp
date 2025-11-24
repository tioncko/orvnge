<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Perfil | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfil.css">
</head>
<body class="op-perfil page-body">

  <main id="page-fragment" class="op-perfil-fragment">
    <div class="op-wrap">
      <section class="op-card perfil-card">
        <h2 class="title">Seu perfil</h2>
        <p class="subtitle">Dados básicos</p>

        <!-- FORM -->
        <form id="formPerfil" autocomplete="off" class="form-grid" action="<%= request.getContextPath() %>/atualizar-usuario?" method="post">
          <input id="id" type="hidden" name="idUsuario">
          <div class="field">
            <label for="nome">Nome</label>
            <input id="nome" type="text" name="nome" placeholder="Ex: Yuri Oliveira">
          </div>

          <div class="field">
            <label for="cpf">CPF</label>
            <input id="cpf" type="text" name="cpf" placeholder="111.111.111-11">
          </div>

          <div class="field">
            <label for="telefone">Telefone</label>
            <input id="telefone" type="text" name="telefone" placeholder="11 99999-9999">
          </div>

          <div class="field">
            <label for="email">E-mail</label>
            <input id="email" type="email" name="email" placeholder="seu@email.com">
          </div>

          <div class="actions">
            <button id="btnSalvar" type="submit" class="btn btn-accent">Salvar</button>
            <button id="btnCancelar" type="button" class="btn btn-outline"
                    onclick="window.location.href = '<%= request.getContextPath() %>/pages/dashboard.jsp'">Cancelar</button>
            <button id="btnExcluir" type="button" class="btn text-danger"
                    onclick="window.location.href = '<%= request.getContextPath() %>/pages/deletarUsuario.jsp'">Excluir</button>
            <a href="<%= request.getContextPath() %>/pages/alterarSenha.jsp" class="link-inline">Alterar senha →</a>
          </div>
        </form>

        <div id="mensagem" class="msg" role="status"></div>
      </section>
    </div>
  </main>
  <script>
    const id = ${sessionScope.usr.idCli};
    const cpf = ${sessionScope.usr.cpf};

    async function carregarUsuario(){
      const params = new URLSearchParams();
      params.append("user", id);
      console.log(params.toString());
      const resp = await fetch("<%=request.getContextPath()%>/rastrear-usuario?" + params.toString());
      const json = await resp.json();

      document.querySelector("#id").value = json.idCli;
      document.querySelector("#nome").value = json.nome;
      document.querySelector("#cpf").value = json.cpf;
      document.querySelector("#telefone").value = json.tel;
      document.querySelector("#email").value = json.email;
    }
    window.onload = carregarUsuario;
  </script>

</body>
</html>
