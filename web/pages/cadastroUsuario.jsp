<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Criar conta | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cadastroUsuario.css">
</head>
<body class="page-body">
  <main class="wrap">
    <section class="card">
      <h2>Criar conta</h2>
      <p class="subtitle">Crie um usuário para acessar o dashboard.</p>

      <form id="cadForm" method="post" action="<%= request.getContextPath() %>/cadastrar-usuario?">
        <div class="field">
          <label for="nome">Nome</label>
          <input id="nome" type="text" name="nome" required />
        </div>

        <div class="field">
          <label for="cpf">CPF</label>
          <input id="cpf" type="text" name="cpf" required />
        </div>

        <div class="field">
          <label for="email">E-mail</label>
          <input id="email" type="email" name="email" required />
        </div>

        <div class="field">
          <label for="telefone">Telefone</label>
          <input id="telefone" type="tel" name="telefone" required />
        </div>


        <div class="field">
          <label for="senha">Senha</label>
          <input id="senha" type="password" name="senha" required />
        </div>

        <div class="field">
          <label for="confSenha">Confirmar Senha</label>
          <input id="confSenha" type="password" name="confSenha" required />
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-accent">Criar conta</button>
          <a class="btn btn-outline" href="<%= request.getContextPath()%>/pages/login.jsp">Voltar ao login</a>
        </div>
      </form>
    </section>
  </main>
</body>
</html>
