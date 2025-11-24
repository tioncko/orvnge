<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Recuperar senha | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cadastroUsuario.css">
</head>
<body class="page-body">
  <main class="wrap">
    <section class="card">
      <h2>Recuperar senha</h2>
      <p class="subtitle">Informe o e-mail cadastrado para redefinir sua senha.</p>

      <form id="recForm" action="<%= request.getContextPath() %>/atualizar-senha?" method="post">
        <input type="hidden" id="idCli" name="idCli" value="<%= request.getParameter("id") %>">
        <div id="newPassArea">
          <div class="field">
            <label for="novaSenha">Nova senha</label>
            <input id="novaSenha" type="password" name="novaSenha"/>
          </div>
          <div class="field">
            <label for="confirmaSenha">Confirme a senha</label>
            <input id="confirmaSenha" type="password" name="confirmaSenha"/>
          </div>
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-accent">Continuar</button>
          <a class="btn btn-outline" href="<%= request.getContextPath()%>/pages/login.jsp">Voltar ao login</a>
        </div>
      </form>
    </section>
  </main>
</body>
</html>
