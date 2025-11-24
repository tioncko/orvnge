<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Cadastro | OrangePay</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cadastro.css">
</head>
<body class="page-body">

<!-- FRAGMENTO -->
<main id="page-fragment" class="op-cadastro-fragment">
  <div class="op-wrap cadastro-container">
    <section class="op-card">

      <header class="card-head">
        <div>
          <span class="op-chip">INSERIR DADO</span>
          <h1 class="op-title">Cadastro de Transação</h1>
          <p class="op-subtitle">Registre despesas ou receitas para alimentar seu dashboard.</p>
        </div>

        <nav class="head-actions">
          <a href="<%= request.getContextPath()%>/pages/cadastroMovimentacao.jsp"
             data-page="<%= request.getContextPath()%>/pages/cadastroMovimentacao.jsp"
             class="btn btn-outline" onclick="window.location.href='cadastroMovimentacao.jps'">Tabela
          </a>
        </nav>
      </header>

      <form id="formTransacao" class="op-form" autocomplete="off" novalidate method="post" action="<%= request.getContextPath()%>/atualizar-mov?">
        <input type="hidden" id="id" name="idMov">
        <div class="grid">

          <div class="field">
            <label for="data">Data</label>
            <input type="date" id="data" required name="dataMov">
            <small class="err" data-for="data"></small>
          </div>

          <div class="field">
            <label for="valor">Valor</label>
            <div class="money">
              <span>R$</span>
              <input type="text" id="valor" name="valor" required>
            </div>
            <small class="err" data-for="valor"></small>
          </div>

          <div class="grid">

            <div class="field">
              <label for="operacao">Conta</label>
              <select id="operacao" required name="idConta">
                <option value="">- Selecione -</option>
              </select>
              <small class="err" data-for="operacao"></small>
            </div>

            <div class="field" style="grid-column: span 2;">
              <label for="obs">Observação</label>
              <input id="obs" name="descricao" placeholder="Ex.: Cartão Nubank">
            </div>

            <div class="field" style="grid-column: span 2;">
              <label for="tipo">Centro de custo / Grupo</label>
              <select id="tipo" required name="idGrupoMov">
                <option value="">- Selecione -</option>
              </select>
              <small class="err" data-for="tipo"></small>
            </div>

          </div>
        </div>

        <div class="actions">
          <button type="submit" class="btn btn-accent" id="btnSalvar">Salvar</button>
          <button type="button" class="btn btn-danger" id="btnCancelarEdit" style="display:none;">Cancelar edição</button>
        </div>

        <div id="msg" class="msg" role="status"></div>
      </form>
    </section>
  </div>
</main>

<script>
  window.onload = async function() {
    await carregarMovimentacao();
    //await carregarTipo();
    //await carregarGrupoMov();
  };

  async function carregarMovimentacao() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("id");

    if(!id) {
      alert("Movimentação inexistente!");
      window.location.href = "<%= request.getContextPath() %>/pages/cadastroMovimentacao.jsp";
      return;
    }

    const resp = await fetch("<%= request.getContextPath() %>/buscar-mov?idMov=" + id);
    const json = await resp.json();

    document.querySelector("#id").value = json.idMov;
    document.querySelector("#data").value = json.dataMov;
    document.querySelector("#valor").value = json.valor;
    document.querySelector("#obs").value = json.descricao;

    const conta = json.conta;
    const matchConta = conta.match(/idConta=(\d+)/);
    console.log("1: " + conta);
    console.log(matchConta);

    let idTipoConta = null;
    if (matchConta && matchConta[1]) {
      idTipoConta = matchConta[1];
      console.log(idTipoConta);
      await carregarTipo();
      document.querySelector("#operacao").value = idTipoConta;
      console.log("last: " + idTipoConta);
    }

    const grupo = json.grupoMov;
    const matchGrupo = grupo.match(/idGrupoMov=(\d+)/);
    let idGrupoMov = null;
    if (matchGrupo && matchGrupo[1]) {
      idGrupoMov = matchGrupo[1];
      await carregarGrupoMov();
      document.querySelector("#tipo").value = idGrupoMov;
      console.log(idGrupoMov);
    }

    /*
    const conta = json.conta;
    const matchConta = conta.match(/nomeTipoConta=([^,\]]+)/);
    let nomeTipoConta = null;
    if (matchConta && matchConta.length > 1) {
      nomeTipoConta = matchConta[1].trim();
      await carregarTipo();
      document.querySelector("#operacao").value = nomeTipoConta;
      console.log(nomeTipoConta);
    }

    const grupo = json.grupoMov;
    const matchGrupo = grupo.match(/nome=([^,\]]+)/);
    let nomeGrupoMov = null;
    if (matchGrupo && matchGrupo.length > 1) {
      nomeGrupoMov = matchGrupo[1].trim();
      await carregarGrupoMov();
      document.querySelector("#tipo").value = nomeGrupoMov;
      console.log(nomeGrupoMov);
    }
    */
  }

  const id = ${sessionScope.usr.idCli};

  async function carregarTipo() {
    const params = new URLSearchParams();
    params.append("idCli", id);

    //const resposta = await fetch("<%= request.getContextPath() %>/listar-tipo-conta?");
    const resposta = await fetch("<%= request.getContextPath() %>/listar-conta-usuario?" + params.toString());
    const json = await resposta.json();
    console.log(json);

    const obj = document.querySelector("#operacao");
    obj.innerHTML = "";

    json.forEach(c => {
      const linha = "<option value='" + c.idConta + "'>" + c.conta + "</option>";
      //const linha = "<option value='" + c.idTipoConta + "'>" + c.nomeTipoConta + "</option>";
      obj.innerHTML += linha;
      console.log(obj.innerHTML);
    });
  }

    async function carregarGrupoMov() {
      const resposta = await fetch("<%= request.getContextPath() %>/listar-grupo-mov?");
      const json = await resposta.json();

      const obj = document.querySelector("#tipo");
      obj.innerHTML = "";

      json.forEach(c => {
        const linha = "<option value='" + c.idGrupoMov + "'>" + c.nomeGrupoMov + "</option>";
        obj.innerHTML += linha;
      });
  }
</script>


</body>
</html>
