<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
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

      <form id="recForm" action="<%= request.getContextPath() %>/buscar-usuario?" method="post">
        <div class="field">
          <label for="email">E-mail</label>
          <input id="email" type="email" name="user" required />
          <small id="emailErr" class="err"></small>
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
