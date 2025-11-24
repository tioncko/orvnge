<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>OrangePay</title>
  <link href="<%= request.getContextPath() %>/css/navigation.css" rel="stylesheet"/>

</head>
<body class="layout">
  
  <!-- Sidebar fixa -->
  <aside class="sidebar">
    <div class="brand-block">
      <div class="logo-circle">
        OP
      </div>
      <h1 class="brand-name">OrangePay</h1>
    </div>

    <nav class="menu">
      <ul class="submenu-list">
        <li><button class="menu-btn active" data-target="dashboard" onclick="loadPage('<%= request.getContextPath()%>/pages/dashboard.jsp')">Dashboard</button></li>
        <li><button class="menu-btn" data-target="cadastroMovimentacao" onclick="loadPage('<%= request.getContextPath()%>/pages/cadastroMovimentacao.jsp')">Cadastro</button></li>
        <li><button class="menu-btn" data-target="perfil" onclick="loadPage('<%= request.getContextPath()%>/pages/perfil.jsp')">Perfil</button></li>
        <li><button class="menu-btn" data-target="config" onclick="loadPage('<%= request.getContextPath()%>/pages/config.jsp')">Configurações</button></li>
      </ul>
    </nav>

    <div class="logout-area">
      <form action="<%= request.getContextPath() %>/logout" method="post">
        <button type="submit" class="menu-btn">Logout</button>
      </form>
    </div>
  </aside>

  <!-- Área principal -->
  <main class="main-area">
    <iframe id="contentFrame" src="<%= request.getContextPath() %>/pages/dashboard.jsp" name="main-frame" class="main-frame" frameborder="0"></iframe>
  </main>
  <script src="<%=request.getContextPath()%>/js/scripts.js"></script>
</body>
</html>
