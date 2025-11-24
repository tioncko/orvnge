<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | OrangePay</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">

</head>
<body class="page-body">

  <!-- Cards de resumo -->
  <section class="top-cards">
    <div class="stat-card">
      <span class="label">Saldo atual</span>
      <strong class="value" id="saldoAtual">R$ 0,00</strong>
      <span class="sub">Base mês anterior</span>
    </div>

    <div class="stat-card">
      <span class="label">Receita do mês</span>
      <strong class="value" id="receitaMes">R$ 0,00</strong>
      <span class="sub">Total de entradas</span>
    </div>

    <div class="stat-card">
      <span class="label">Saldo projetado</span>
      <strong class="value" id="saldoProjetado">R$ 0,00</strong>
      <span class="sub">Estimativa até fim do mês</span>
    </div>
  </section>

  <!-- Grid com gráfico, tabela e formulário -->
  <section class="panel-grid">

    <!-- Bloco Gráfico -->
    <div class="panel-box">
      <div class="panel-head">
        <h2 class="panel-title">Evolução mensal</h2>
        <h2 class="panel-title" id="mesAtual" style="color: #514438">Carregando dados...</h2>
      </div>

      <div class="field-container">
        <div class="field">
          <label for="filtroMes"></label>
          <select id="filtroMes" onchange="atualizarContextPath()">
            <option value="">- Selecione o mês (visão anual carregado) -</option>
            <option value="JAN">JAN</option>
            <option value="FEV">FEV</option>
            <option value="MAR">MAR</option>
            <option value="ABR">ABR</option>
            <option value="MAI">MAI</option>
            <option value="JUN">JUN</option>
            <option value="JUL">JUL</option>
            <option value="AGO">AGO</option>
            <option value="SET">SET</option>
            <option value="OUT">OUT</option>
            <option value="NOV">NOV</option>
            <option value="DEZ">DEZ</option>
          </select>
          <small class="err" data-for="filtroMes"></small>
        </div>
        <div class="field">
          <label for="filtroTipo"></label>
          <select id="filtroTipo" onchange="atualizarContextPath()">
            <option value="">- Selecione o tipo de movimentação -</option>
          </select>
          <small class="err" data-for="filtroTipo"></small>
        </div>
      </div>

      <div class="chart-container">
        <canvas id="graficoBarras">Selecione um mês</canvas>
      </div>
    </div>

    <!-- Bloco Tabela + Form -->
    <div class="panel-box">
      <div class="panel-head">
        <h2 class="panel-title">Resumo por mês</h2>
        <a class="ver-mais" href="<%= request.getContextPath() %>/pages/orvnge-navigation.jsp" target="_parent">Detalhamento mensal →</a>
      </div>
      <div class="field">
        <label for="filtroAno"></label>
        <select id="filtroAno" onchange="carregarEspelho()">
          <option value="">- Selecione o ano -</option>
        </select>
        <small class="err" data-for="filtroAno"></small>
      </div>
      <!-- Tabela -->
      <div class="table-wrap">
        <table id="tabelaFinanceira" class="table-fin">
          <thead>
            <tr>
              <th>MÊS</th>
              <th>DESPESA</th>
              <th>RECEITA</th>
              <th>SALDO (20/mês)</th>
              <th>SALDO (05/mês)</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
    </div>
  </section>

  <script>
    const id = ${sessionScope.usr.idCli};
    const cpf = ${sessionScope.usr.cpf};

    function atualizarContextPath() {
      const select = document.getElementById("filtroMes");
      let mesSelecionado = getMonth(select.value); // JAN -> 01

      const selectTipo = document.getElementById("filtroTipo");
      let tipoSelecionado = selectTipo.value;

      const params = new URLSearchParams();
      params.append('cpf', cpf);
      const geral = "00";

      if(mesSelecionado === "") {
        params.append("mes", geral);
      } else {
        params.append("mes", mesSelecionado);
      }
      //params.append("mes", mesSelecionado);
      params.append("idtipoMov", tipoSelecionado);

      // Atualiza variável global usada no scripts.js
      window.contextPathGrafico = "<%= request.getContextPath() %>/listar-mov-grupo?" + params.toString();

      // Agora SIM o gráfico pode ser recarregado
      if (typeof carregarGrafico === 'function') {
        carregarGrafico();
      }
    }

    // Evento no SELECT
    document.getElementById("filtroMes").addEventListener("change", atualizarContextPath);
    document.getElementById("filtroTipo").addEventListener("change", atualizarContextPath);

    window.getMonth = function (mes) {
      switch (mes) {
        case "JAN": return "01";
        case "FEV": return "02";
        case "MAR": return "03";
        case "ABR": return "04";
        case "MAI": return "05";
        case "JUN": return "06";
        case "JUL": return "07";
        case "AGO": return "08";
        case "SET": return "09";
        case "OUT": return "10";
        case "NOV": return "11";
        case "DEZ": return "12";
        default: return "";
      }
    }

    window.getMonthExtension = function (mes) {
      switch (mes) {
        case "01": return "Janeiro";
        case "02": return "Fevereiro";
        case "03": return "Março";
        case "04": return "Abril";
        case "05": return "Maio";
        case "06": return "Junho";
        case "07": return "Julho";
        case "08": return "Agosto";
        case "09": return "Setembro";
        case "10": return "Outubro";
        case "11": return "Novembro";
        case "12": return "Dezembro";
        default: return "";
      }
    }

    window.getMonthByDate = function () {
      const data = new Date();
      return ('0'+ (data.getMonth() + 1)).slice(-2);
    }

    window.getFormatMoney = function(value) {
      const money = new Intl.NumberFormat('pt-BR', {style: 'currency', currency: 'BRL'});
      return money.format(value);
    }

    async function getInformation() {
      const params = new URLSearchParams();
      params.append('cpf', cpf);

      const resposta = await fetch("<%= request.getContextPath() %>/listar-espelho?" + params.toString());
      const json = await resposta.json();
      console.log(json);

      //
      let saldoAtual;
      let newJson = [];
      if (json.length > 1) {
        saldoAtual = json[json.length - 2].saldo_fim;
      } else {
        const genJson = json[0];
        const col = Object.keys(genJson);
        const val = Object.values(genJson);

        let list = {};
        for(let key of col) {
          if(key === col[0]) list[key] = val[0];
          else list[key] = "0.00";
        }
        newJson.push(list);
        newJson.push(json[0]);
        saldoAtual = newJson[newJson.length - 1].despesa;
      }
      //
      const receitaMes = json[json.length - 1].receita;
      const saldoProjetado = json[json.length - 1].saldo_fim;

      const atual = document.querySelector("#saldoAtual");
      const receita = document.querySelector("#receitaMes");
      const projetado = document.querySelector("#saldoProjetado");

      if (atual && receita && projetado) {
        atual.textContent = getFormatMoney(saldoAtual);
        receita.textContent = getFormatMoney(receitaMes);
        projetado.textContent = getFormatMoney(saldoProjetado);
      }

      const mesAtual = document.querySelector("#mesAtual");
      if (mesAtual) {
        mesAtual.textContent = "Mês atual: " + getMonthExtension(getMonthByDate()).toUpperCase();
      }
    }
    //window.onload = getInformation;
  </script>

  <script>
    async function carregarEspelho() {
      // Criando os parâmetros
      const params = new URLSearchParams();
      params.append('cpf', cpf);

      const resposta = await fetch("<%= request.getContextPath() %>/listar-espelho?" + params.toString());
      const json = await resposta.json();

      //
      const selectAno = document.getElementById("filtroAno");
      let anoSelecionado = selectAno.value;

      const newJson = [];
      json.map(x => {
        //for(var i = 0; i < Array.from(newSet).length; i++) {
        if (x.mesAno.split("/")[1] === anoSelecionado) {
          return newJson.push(x);
        }
        //}
      })

      const tbody = document.querySelector("#tabelaFinanceira tbody");
      tbody.innerHTML = "";

      newJson.forEach(c => {
        const linha =
                "<tr>" +
                "<td>" + c.mesAno + "</td>" +
                "<td>" + getFormatMoney(c.despesa) + "</td>" +
                "<td>" + getFormatMoney(c.receita) + "</td>" +
                "<td>" + getFormatMoney(c.saldo_meio) + "</td>" +
                "<td>" + getFormatMoney(c.saldo_fim) + "</td>" +
                "</tr>";
        tbody.innerHTML += linha;
      });
    }
    document.getElementById("filtroAno").addEventListener("change", carregarEspelho);

    async function carregarTipo() {
      const resposta = await fetch("<%= request.getContextPath() %>/listar-tipo-mov?");
      const json = await resposta.json();

      const obj = document.querySelector("#filtroTipo");
      obj.innerHTML = "";

      json.forEach(c => {
        const linha = "<option value='" + c.idTipoMov + "'>" + c.nomeTipoMov + "</option>";
        obj.innerHTML += linha;
      });
    }

    async function carregarAno() {
      const params = new URLSearchParams();
      //params.append('idCli', id);
      params.append('cpf', cpf);

      const resposta = await fetch("<%= request.getContextPath() %>/listar-espelho?" + params.toString());
      const json = await resposta.json();
      const slice = json.map(p => p.mesAno.split("/")[1]);
      const set = new Set(slice);
      const unique = Array.from(set);

      const obj = document.querySelector("#filtroAno");
      obj.innerHTML = "";

      unique.forEach(c => {
        const linha = "<option value='" + c + "'>" + c + "</option>";
        obj.innerHTML += linha;
      });
    }

    //window.onload = carregarEspelho;
    window.onload = async function () {

      await carregarTipo();
      await carregarAno();
      // Carga inicial do gráfico
      atualizarContextPath();
      // Carga dos cards
      await getInformation();
      // Carga da tabela
      await carregarEspelho();
    };
  </script>

  <!-- script no fim -->
  <script src="${pageContext.request.contextPath}/js/scripts.js"></script>


</body>
</html>
