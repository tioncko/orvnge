--[] Total por tipo de movimentação
CREATE OR REPLACE FUNCTION fc_total_movimentacao(
    conta INT, mes TEXT, tipoMov INT
)
RETURNS TABLE (
	valor NUMERIC(15,2)
)
AS $$
BEGIN
    RETURN QUERY
    select sum(m.valor) totalMov from Movimentacao m 
    inner join grupomov g on g.idgrupomov = m.idgrupomov
    where g.idtipomov = tipoMov
        and idconta = conta
        and to_char(data, 'MM') = mes; 
END;
$$ LANGUAGE plpgsql;
select * from fc_total_movimentacao(1, '11', 1); --despesa
select * from fc_total_movimentacao(1, '11', 2); --receita

-- Total das movimentaçõe por mês (grafico de linha)
CREATE OR REPLACE FUNCTION fc_movimentacao_mes(
    conta INT, mes TEXT,tipoMov INT
)
RETURNS TABLE (
    mesAno TEXT, totalMes NUMERIC(15,2)
)
AS $$
BEGIN
    RETURN QUERY
    select to_char(data, 'MM/YYYY') mes, sum(m.valor) totalData from Movimentacao m
    inner join grupomov g on g.idgrupomov = m.idgrupomov
    where g.idtipomov = tipoMov
        and idconta = conta
        and to_char(data, 'MM') = mes
    group by to_char(data, 'MM/YYYY')
    order by to_char(data, 'MM/YYYY');
END;
$$ LANGUAGE plpgsql;
select * from fc_movimentacao_mes(1, '11', 1); --despesa
select * from fc_movimentacao_mes(1, '11', 2); --receita

-- combobox despesa/receita | combobox mes | combobox grupo
--[] Tela de cadastro
CREATE OR REPLACE FUNCTION fc_movimentacao_tipo(
    conta INT, mes TEXT, tipoMov INT
)
RETURNS TABLE (
    mesAno TEXT, nomeGrupo VARCHAR(50), infoDesc TEXT, valor NUMERIC(15,2)
)
AS $$
BEGIN
    RETURN QUERY
    select to_char(data, 'dd-') || getMonth(to_char(data, 'MM')) mesAno, g.nomegrupomov, descricao, m.valor totalData 
    from Movimentacao m
    inner join grupomov g on g.idgrupomov = m.idgrupomov
    where g.idtipomov = tipoMov
        and idconta = conta
        and to_char(data, 'MM') = mes
    order by to_char(data, 'dd-') || getMonth(to_char(data, 'MM'));
END;
$$ LANGUAGE plpgsql;
select * from fc_movimentacao_tipo(1, '11', 1);

-- [] Total por grupo de movimentação (usado no grafico de barras)
-- Ficar atento a possibilidade do cliente ter mais de uma conta e ser necessário criar um combobox com as contas
CREATE OR REPLACE FUNCTION fc_movimentacao_grupo(
    conta INT, mes TEXT, tipoMov INT
)
RETURNS TABLE (
    nomeGrupo VARCHAR(50), totalGrupo NUMERIC(15,2)
)
AS $$
BEGIN
    IF mes = '00' then
    begin
        RETURN QUERY
        WITH cte AS (
            SELECT g.idgrupomov, g.nomegrupomov, SUM(m.valor) AS totalGrupo
            FROM Movimentacao m 
            RIGHT JOIN grupomov g ON g.idgrupomov = m.idgrupomov 
            WHERE idconta = conta
            GROUP BY g.idgrupomov, g.nomegrupomov
        )
        SELECT 
            g.nomegrupomov, COALESCE(c.totalGrupo, 0.00) AS totalGrupo
        FROM grupomov g
        LEFT JOIN cte c ON c.idgrupomov = g.idgrupomov
        WHERE g.idtipomov = tipoMov;
    end
    else
        RETURN QUERY
        WITH cte AS (
            SELECT g.idgrupomov, g.nomegrupomov, SUM(m.valor) AS totalGrupo
            FROM Movimentacao m 
            RIGHT JOIN grupomov g ON g.idgrupomov = m.idgrupomov 
            WHERE idconta = conta
              AND TO_CHAR(data, 'MM') = mes
            GROUP BY g.idgrupomov, g.nomegrupomov
        )
        SELECT 
            g.nomegrupomov, COALESCE(c.totalGrupo, 0.00) AS totalGrupo
        FROM grupomov g
        LEFT JOIN cte c ON c.idgrupomov = g.idgrupomov
        WHERE g.idtipomov = tipoMov;
    end if
END;
$$ LANGUAGE plpgsql;
select * from fc_movimentacao_grupo(1, '11', 1)

-- custo-mes é tudo que foi gasto no mes
-- saldo é a subtração do que entrou de receita menos o custo-mes
/*
CREATE OR REPLACE FUNCTION fc_saldo_mensal(
    conta INT, mes TEXT
)
RETURNS TABLE (
    data DATE, saldoAtual NUMERIC(15,2), idconta INT
)
as $$
BEGIN
    RETURN QUERY
    with cte as (
        select m.idmov, m.data, m.descricao, c.saldoinicial, 
        case when g.idtipomov = 1 then valor else 0.00 end despesa,
        case when g.idtipomov = 2 then valor else 0.00 end receita,
        m.idconta,
        row_number() over (partition by m.idconta order by m.data asc) seq
        from Movimentacao m 
        inner join grupomov g on g.idgrupomov = m.idgrupomov
        inner join conta c on c.idconta = m.idconta
        where c.idconta = conta
        order by data
    ),
    releaseValue as (
    	select
    	seq, data, descricao, idconta, saldoinicial + 
    	sum(receita - despesa) over (partition by idconta order by seq asc) saldoAtual
    	from cte
    )
    select data, sum(saldoatual), idconta from releaseValue 
    where to_char(data, 'MM') = mes
    GROUP BY data, idconta;
END;
$$ LANGUAGE plpgsql;
select * from fc_saldo_mensal(1, '01')
*/

CREATE OR REPLACE FUNCTION fc_espelho (
    conta int
)
returns TABLE (
    mesAno TEXT, despesa NUMERIC(15,2), receita NUMERIC(15,2), saldo_meio NUMERIC(15,2), saldo_fim NUMERIC(15,2)
)
as $$
BEGIN
    --despesa
	drop table if exists mov_despesa;
    CREATE TABLE mov_despesa (mesAno TEXT, valor NUMERIC(15,2));

    insert into mov_despesa (mesAno, valor)
    select to_char(data, 'MM/YYYY') mes, sum(m.valor) totalData from Movimentacao m
    inner join grupomov g on g.idgrupomov = m.idgrupomov
    where g.idtipomov = 1 and idconta = 1
    group by to_char(data, 'MM/YYYY')
    order by to_char(data, 'MM/YYYY');

    --receita
	drop table if exists mov_receita;
    CREATE TABLE mov_receita (mesAno TEXT, valor NUMERIC(15,2));

    insert into mov_receita (mesAno, valor)
    select to_char(data, 'MM/YYYY') mes, sum(m.valor) totalData from Movimentacao m
    inner join grupomov g on g.idgrupomov = m.idgrupomov
    where g.idtipomov = 2 and idconta = conta
    group by to_char(data, 'MM/YYYY')
    order by to_char(data, 'MM/YYYY');

    RETURN QUERY
    select d.mesAno, d.valor despesa, r.valor receita, ed.saldoMeio middle, ed.saldoFim fim
    from mov_despesa d
    left join mov_receita r on d.mesAno = r.mesAno
    left join fc_espelho_controle(conta) ed on ed.mesRef = d.mesAno;
END;
$$ LANGUAGE plpgsql;
--select * from fc_espelho(1);

CREATE OR REPLACE FUNCTION fc_espelho_controle(
    conta INT
)
RETURNS TABLE (
    mesRef TEXT, saldoMeio NUMERIC(15,2), saldoFim NUMERIC(15,2)
)
as $$
BEGIN
	drop table if exists resultado;
    create temp table resultado (mesAno TEXT, saldo_meio NUMERIC(15,2), saldo_fim NUMERIC(15,2));

    declare
    	cur cursor for 
    	select d.mesAno, d.valor despesa, r.valor receita
    	from mov_despesa d
    	left join mov_receita r on d.mesAno = r.mesAno;
    	cont int;
    	rec record;
    	resul record;
    
    begin
    	cont := 1;
    	open cur;
    	loop
    		fetch cur into rec;
    		exit when not found;
    
    		select * 
    		into resul
    		from fc_saldo_mes(conta, LPAD(cont::text, 2, '0')) 
    		where mesano = rec.mesano;

    		cont := cont + 1;
            
            insert into resultado (mesAno, saldo_meio, saldo_fim)
            values (rec.mesano, resul.saldo_meio, resul.saldo_fim);
    	end loop;
    	close cur;
    end;

	RETURN QUERY
    select * from resultado;
END;
$$ LANGUAGE plpgsql;
--select * from fc_espelho_controle(1);

CREATE OR REPLACE FUNCTION fc_saldo_mes(
    conta int, mes text
)
RETURNS TABLE (
    mesAno text,
    saldo_meio numeric(10,2),
	saldo_fim numeric(10,2)
) 
AS $$
DECLARE
    "start" date;
    mid_1 date;
	mid_2 date;
    "end" date;

BEGIN
	select inicio, meio_1, meio_2, fim
	into "start", mid_1, mid_2, "end"
	from getDate(mes);
	
    RETURN QUERY
        with cte as (
			select to_char(datasaldo, 'MM/YYYY') mesAno, saldoperiodo, datasaldo
        	from fc_levantamento_mensal(conta, mes)		
		)		
		select pt1.mesAno, pt1.saldoperiodo mid1, pt2.saldoperiodo mid2 
        from cte pt1
		inner join (
        	select to_char(datasaldo, 'MM/YYYY') mesAno, saldoperiodo
        	from fc_levantamento_mensal(conta, mes)
        	where datasaldo between mid_2 and "end"
        	order by dataSaldo desc
		) pt2 on pt1.mesAno = pt2.mesAno
        where datasaldo between "start" and mid_1
        order by dataSaldo desc
        limit 1;	
END;
$$ LANGUAGE plpgsql;
--select * from fc_saldo_mes(1, '02')

CREATE OR REPLACE FUNCTION fc_levantamento_mensal(
    conta INT, mes TEXT
)
RETURNS TABLE (
    dataSaldo DATE, saldoPeriodo NUMERIC(15,2), contaid INT
)
as $$
BEGIN
    RETURN QUERY
    with cte as (
        select m.idmov, m.data, m.descricao, c.saldoinicial, 
        case when g.idtipomov = 1 then valor else 0.00 end despesa,
        case when g.idtipomov = 2 then valor else 0.00 end receita,
        m.idconta,
        row_number() over (partition by m.idconta order by m.data asc) seq
        from Movimentacao m 
        inner join grupomov g on g.idgrupomov = m.idgrupomov
        inner join conta c on c.idconta = m.idconta
        where c.idconta = conta
        order by data
    ),
    releaseValue as (
    	select
    	seq, data, descricao, idconta, saldoinicial + 
    	sum(receita - despesa) over (partition by idconta order by seq asc) saldoAtual
    	from cte
    )
    SELECT data, saldoatual, idconta
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY data ORDER BY seq DESC) AS rn
        FROM releaseValue
    	where to_char(data, 'MM') = mes
    ) t
    WHERE rn = 1;
END;
$$ LANGUAGE plpgsql;
--select * from fc_levantamento_mensal(1, '01')


CREATE OR REPLACE FUNCTION getDate(mes TEXT)
RETURNS TABLE (inicio text, meio_1 text, meio_2 text, fim text)
AS $$
DECLARE
    dataBase DATE;
BEGIN
    -- Monta a data inicial do mês usando to_date (bem mais simples)
    dataBase := TO_DATE(to_char(current_date, 'YYYY') || mes || '01', 'YYYYMMDD');

    -- Retorna a tabela usando RETURN QUERY
    RETURN QUERY
    SELECT
        to_char(date_trunc('month', dataBase), 'YYYY-MM-DD') AS inicio,
        to_char(date_trunc('month', dataBase) + INTERVAL '14 days', 'YYYY-MM-DD') AS meio_1,
        to_char(date_trunc('month', dataBase) + INTERVAL '15 days', 'YYYY-MM-DD') AS meio_2,
        to_char((date_trunc('month', dataBase) + INTERVAL '1 month - 1 day'), 'YYYY-MM-DD') AS fim;

END;
$$ LANGUAGE plpgsql;
select * from getDate('01')

CREATE FUNCTION getMonth(mes text) RETURNS text
as $$
	select case 
		when mes = '1' then 'JAN'
		when mes = '2' then 'FEV'
		when mes = '3' then 'MAR'
		when mes = '4' then 'ABR'
		when mes = '5' then 'MAI'
		when mes = '6' then 'JUN'
		when mes = '7' then 'JUL'
		when mes = '8' then 'AGO'
		when mes = '9' then 'SET'
		when mes = '10' then 'OUT'
		when mes = '11' then 'NOV'
		when mes = '12' then 'DEZ'
	else null
	END;
$$ language sql immutable


CREATE TABLE Usuario (
    IdCliente SERIAL PRIMARY KEY,
    Email VARCHAR(100) NOT NULL UNIQUE,
    CPF CHAR(11) NOT NULL UNIQUE,
    Nome VARCHAR(100) NOT NULL,
    Tel VARCHAR(15),
    Senha VARCHAR(255) NOT NULL
);

CREATE TABLE Banco (
    IdBanco SERIAL PRIMARY KEY,
    SglBanco VARCHAR(10),
    Nome VARCHAR(100) NOT NULL
);

CREATE TABLE TipoConta (
    IdTipoConta SERIAL PRIMARY KEY,
    NomeTipoConta VARCHAR(50) NOT NULL
);

CREATE TABLE Conta (
    IdConta SERIAL PRIMARY KEY,
    NConta VARCHAR(30) NOT NULL,
    SaldoInicial NUMERIC(15,2) DEFAULT 0,
    IdCliente INT NOT NULL,
    IdBanco INT NOT NULL,
    IdTipoConta INT NOT NULL,
    CONSTRAINT fk_conta_usuario FOREIGN KEY (IdCliente)
        REFERENCES Usuario (IdCliente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_conta_banco FOREIGN KEY (IdBanco)
        REFERENCES Banco (IdBanco) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_conta_tipoconta FOREIGN KEY (IdTipoConta)
        REFERENCES TipoConta (IdTipoConta)
);

CREATE TABLE TipoMov (
    IdTipoMov SERIAL PRIMARY KEY,
    NomeTipoMov VARCHAR(50) NOT NULL
);

CREATE TABLE GrupoMov (
    IdGrupoMov SERIAL PRIMARY KEY,
    NomeGrupoMov VARCHAR(50) NOT NULL,
    IdTipoMov INT NOT NULL,
    CONSTRAINT fk_mov_tipomov FOREIGN KEY (IdTipoMov)
        REFERENCES TipoMov (IdTipoMov) ON DELETE CASCADE ON UPDATE CASCADE,
);

CREATE TABLE Movimentacao (
    IdMov SERIAL PRIMARY KEY,
    Data DATE NOT NULL,
    Descricao TEXT,
    Valor NUMERIC(15,2) NOT NULL,
    IdConta INT NOT NULL,
    IdGrupoMov INT NOT NULL,
    CONSTRAINT fk_mov_conta FOREIGN KEY (IdConta)
        REFERENCES Conta (IdConta) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mov_grupomov FOREIGN KEY (IdGrupoMov)
        REFERENCES GrupoMov (IdGrupoMov)
);

drop table saldo
CREATE TABLE Saldo (
    IdSaldo SERIAL PRIMARY KEY,
    Data DATE NOT NULL,
    SaldoAtual NUMERIC(15,2) NOT NULL,
    IdConta INT NOT NULL,
    CONSTRAINT fk_saldomensal_conta FOREIGN KEY (IdConta)
        REFERENCES Conta (IdConta) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Usuario (Email, CPF, Nome, Tel, Senha)
VALUES
('joao.silva@email.com', '12345678901', 'João da Silva', '11988887777', '1234'),
('maria.souza@email.com', '98765432100', 'Maria Souza', '21999998888', 'abcd'),
('carlos.pereira@email.com', '11122233344', 'Carlos Pereira', '31987654321', 'senha123'),
('ana.lima@email.com', '55566677788', 'Ana Lima', '41999997777', '4321'),
('lucas.mendes@email.com', '22233344455', 'Lucas Mendes', '11955556666', 'lucas@123');

INSERT INTO Banco (SglBanco, Nome)
VALUES
('BB', 'Banco do Brasil'),
('ITAU', 'Banco Itaú'),
('NU', 'Nubank'),
('CAIXA', 'Caixa Econômica Federal'),
('SANT', 'Santander');

INSERT INTO TipoConta (NomeTipoConta)
VALUES
('Conta Corrente'),
('Conta Poupança'),
('Conta Salário'),
('Conta Digital');

INSERT INTO Conta (NConta, Saldo, IdCliente, IdBanco, IdTipoConta)
VALUES
('12345-6', 1500.00, 1, 1, 1),
('78910-2', 3000.00, 2, 2, 2),
('55555-5', 500.00, 1, 3, 1),
('88888-8', 4200.00, 3, 4, 1),
('99999-9', 2500.00, 4, 5, 4),
('10101-0', 800.00, 5, 3, 1);

INSERT INTO TipoMov (NomeTipoMov)
VALUES
('Despesa'),
('Receita')

INSERT INTO GrupoMov (NomeGrupoMov)
VALUES
('Salário', 2),
('Alimentação', 1),
('Lazer', 1),
('Transporte', 1),
('Educação', 1),
('Serviços', 1),
('Transferências a pagar', 1),
('Transferências a receber', 2),
('Saúde', 1);

INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov)
VALUES
-- João (BB)
('2025-11-01', 'Depósito de salário', 3000.00, 1, 1),
('2025-11-02', 'Supermercado', 350.00, 1, 2),
('2025-11-03', 'Cinema', 80.00, 1, 3),
('2025-11-04', 'Uber', 25.50, 1, 4),
-- João (Nubank)
('2025-11-05', 'Transferência recebida Itaú', 200.00, 3, 7),
('2025-11-06', 'Spotify Premium', 34.90, 3, 6),
-- Maria (Itaú)
('2025-11-02', 'Transferência recebida', 500.00, 2, 8),
('2025-11-05', 'Compra online', 120.00, 2, 3),
('2025-11-06', 'Escola dos filhos', 800.00, 2, 5),
-- Carlos (Caixa)
('2025-11-01', 'Salário mensal', 4000.00, 4, 1),
('2025-11-02', 'Padaria', 45.00, 4, 2),
('2025-11-03', 'Posto de combustível', 250.00, 4, 4),
-- Ana (Santander)
('2025-11-04', 'Pix recebido - Lucas', 150.00, 5, 7),
('2025-11-04', 'Netflix', 39.90, 5, 3),
('2025-11-05', 'Pagamento de conta de luz', 220.00, 5, 6),
-- Lucas (Nubank)
('2025-11-02', 'Freelance recebido', 900.00, 6, 1),
('2025-11-03', 'Transferência para Ana', 150.00, 6, 7),
('2025-11-04', 'Restaurante', 95.00, 6, 2);


INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-05', 'Serviços', 457.92, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-21', 'Transferência enviada', 321.36, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-25', 'Mensalidade', 183.26, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-08', 'Pagamento a terceiros', 82.63, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-17', 'Parque', 389.75, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-22', 'Parque', 301.05, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-04', 'Ônibus', 522.15, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-08', 'Consulta médica', 402.22, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-22', 'Supermercado', 171.74, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-12', 'Supermercado', 18.08, 4, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-25', 'Salário', 1739.52, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-14', 'Boliche', 564.28, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-18', 'Salário', 4264.23, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-28', 'Padaria', 61.68, 1, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-28', 'Boliche', 258.55, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-17', 'Boliche', 242.04, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-07', 'Streaming', 348.6, 2, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-14', 'Mensalidade', 194.87, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-18', 'Curso', 455.31, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-19', 'Bônus', 1846.57, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-19', 'Freelance', 2605.45, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-15', 'Supermercado', 29.13, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-10', 'Padaria', 438.47, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-21', 'Consulta médica', 125.02, 2, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-17', 'Streaming', 170.62, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-31', 'Pagamento a terceiros', 175.98, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-12', 'Luz', 290.18, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-16', 'Parque', 321.75, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-07', 'Material escolar', 13.71, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-28', 'Ônibus', 472.56, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-11', 'Serviços', 463.12, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-18', 'Táxi', 382.14, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-26', 'Táxi', 187.29, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-04', 'Freelance', 4029.49, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-11', 'Mensalidade', 111.32, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-29', 'Curso', 318.71, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-17', 'Transferência enviada', 281.18, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-08', 'Curso', 403.66, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-06', 'Farmácia', 435.68, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-23', 'Show', 26.24, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-02', 'Loja de conveniência', 486.56, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-12', 'Rendimento', 3408.62, 4, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-28', 'Bônus', 1823.97, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-01', 'Farmácia', 298.36, 2, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-22', 'Pagamento a terceiros', 36.52, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-05', 'Transferência recebida', 1854.76, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-08', 'Transferência enviada', 583.76, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-23', 'Combustível', 535.14, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-22', 'Material escolar', 111.67, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-28', 'Pagamento a terceiros', 217.12, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-05', 'Streaming', 531.93, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-12', 'Curso', 227.72, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-02', 'Boliche', 565.85, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-23', 'Bônus', 2419.15, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-19', 'Uber', 352.57, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-20', 'Combustível', 372.98, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-14', 'Água', 267.19, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-17', 'Curso', 402.29, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-29', 'Padaria', 425.72, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-31', 'PIX recebido', 2552.85, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-02', 'Exames', 82.25, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-14', 'Internet', 156.03, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-10', 'Mensalidade', 42.09, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-08', 'Transferência enviada', 125.42, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-11', 'Rendimento', 3939.69, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-03', 'Streaming', 439.91, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-06', 'Supermercado', 276.94, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-14', 'PIX recebido', 557.28, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-22', 'Transferência recebida', 4638.78, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-26', 'Transferência enviada', 329.95, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-01', 'PIX recebido', 4597.72, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-10', 'Streaming', 112.83, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-07', 'Curso', 375.17, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-12', 'Ônibus', 398.72, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-11', 'Uber', 338.26, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-05', 'Padaria', 511.15, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-24', 'Show', 548.85, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-25', 'Curso', 294.43, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-03', 'Loja de conveniência', 550.16, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-03', 'Pagamento a terceiros', 223.39, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-01', 'Pagamento a terceiros', 597.94, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-27', 'Transferência recebida', 2915.49, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-17', 'Água', 216.84, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-11', 'Transferência enviada', 258.18, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-28', 'Mensalidade', 421.16, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-09', 'Serviços', 431.2, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-20', 'Transferência recebida', 4193.29, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-28', 'Transferência enviada', 321.05, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-07', 'Material escolar', 15.68, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-25', 'Show', 79.39, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-04', 'Táxi', 183.29, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-28', 'Exames', 335.17, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-14', 'Táxi', 144.65, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-18', 'Parque', 253.41, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-10', 'Transferência enviada', 570.35, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-13', 'PIX recebido', 3412.44, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-04', 'Consulta médica', 542.82, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-25', 'Padaria', 252.46, 5, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-18', 'Transferência enviada', 333.8, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-31', 'Consulta médica', 128.63, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-24', 'Farmácia', 313.34, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-24', 'Consulta médica', 430.13, 2, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-16', 'Streaming', 505.97, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-27', 'Transferência recebida', 1912.44, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-21', 'Exames', 589.83, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-15', 'Transferência enviada', 191.05, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-16', 'Ônibus', 19.42, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-29', 'Consulta médica', 367.07, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-26', 'Cinema', 31.67, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-12', 'Boliche', 130.56, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-10', 'PIX recebido', 2018.73, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-24', 'Serviços', 351.39, 2, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-01', 'Água', 471.01, 2, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-28', 'Uber', 94.99, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-01', 'PIX recebido', 3227.86, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-20', 'Internet', 221.44, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-17', 'Consulta médica', 481.63, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-07', 'Mensalidade', 178.78, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-12', 'Padaria', 517.29, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-22', 'Curso', 130.68, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-05', 'Supermercado', 411.62, 5, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-09', 'Material escolar', 517.68, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-08', 'PIX recebido', 2925.48, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-25', 'Padaria', 581.82, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-13', 'PIX recebido', 2989.5, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-09', 'Freelance', 2929.82, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-10', 'Internet', 41.69, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-18', 'PIX recebido', 3250.33, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-09', 'Pagamento a terceiros', 575.37, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-31', 'Salário', 3831.14, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-08', 'Mensalidade', 256.68, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-10', 'Transferência recebida', 3111.92, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-10', 'Curso', 454.11, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-21', 'Exames', 60.98, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-08', 'Rendimento', 1156.26, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-09', 'Pagamento a terceiros', 166.27, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-08', 'Mensalidade', 527.8, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-14', 'Exames', 475.32, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-24', 'Mensalidade', 354.15, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-13', 'Rendimento', 3651.67, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-16', 'Exames', 38.44, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-15', 'Táxi', 100.28, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-14', 'Farmácia', 338.02, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-09', 'Farmácia', 298.3, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-17', 'Padaria', 132.56, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-14', 'Loja de conveniência', 449.23, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-04', 'PIX recebido', 1780.58, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-19', 'Mensalidade', 186.52, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-23', 'Transferência enviada', 92.38, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-25', 'Show', 444.47, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-30', 'Uber', 77.5, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-13', 'Parque', 316.87, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-15', 'Luz', 586.74, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-07', 'Boliche', 275.16, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-26', 'Freelance', 2752.87, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-07', 'Consulta médica', 340.48, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-21', 'Curso', 507.44, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-31', 'Exames', 356.94, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-10', 'Parque', 466.81, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-22', 'Bônus', 3955.44, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-10', 'Transferência recebida', 4341.03, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-07', 'Boliche', 272.42, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-19', 'Freelance', 3890.82, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-06', 'Bônus', 1738.97, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-16', 'Uber', 509.0, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-10', 'Padaria', 94.62, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-12', 'Freelance', 1511.15, 4, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-21', 'Show', 180.42, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-31', 'Cinema', 548.87, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-19', 'Mensalidade', 474.53, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-12', 'Curso', 540.83, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-24', 'Mensalidade', 13.51, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-30', 'Padaria', 223.53, 1, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-15', 'Padaria', 309.2, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-23', 'Boliche', 320.19, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-17', 'Salário', 2672.34, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-26', 'Transferência enviada', 108.53, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-26', 'Material escolar', 65.17, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-08', 'Transferência recebida', 4175.36, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-12', 'Freelance', 4301.19, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-19', 'Farmácia', 282.92, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-20', 'Show', 15.62, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-04', 'Material escolar', 526.95, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-24', 'Pagamento a terceiros', 269.91, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-15', 'Material escolar', 160.18, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-19', 'Salário', 1728.1, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-26', 'Farmácia', 104.64, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-20', 'Material escolar', 473.05, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-25', 'Material escolar', 442.66, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-21', 'Show', 477.34, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-13', 'Exames', 325.02, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-05', 'Água', 466.85, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-05', 'Uber', 57.14, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-20', 'PIX recebido', 2470.49, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-31', 'Loja de conveniência', 204.4, 5, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-07', 'Mensalidade', 363.74, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-13', 'Cinema', 480.02, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-18', 'PIX recebido', 3450.66, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-21', 'Padaria', 592.09, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-16', 'Mensalidade', 76.37, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-11', 'Parque', 334.03, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-15', 'Táxi', 166.39, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-22', 'Mensalidade', 416.19, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-10', 'Exames', 526.49, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-17', 'Loja de conveniência', 161.26, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-21', 'Transferência recebida', 2416.16, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-22', 'Transferência recebida', 2799.43, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-20', 'Streaming', 239.1, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-12', 'Cinema', 575.89, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-11', 'PIX recebido', 2664.18, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-15', 'Freelance', 4118.5, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Internet', 484.04, 4, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-07', 'Material escolar', 228.9, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-10', 'Água', 375.8, 2, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-17', 'Padaria', 469.42, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-12', 'Show', 563.42, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-08', 'Internet', 107.72, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-26', 'Bônus', 3475.09, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-16', 'Boliche', 274.73, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-30', 'Boliche', 241.68, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-26', 'Uber', 193.22, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-30', 'Padaria', 434.19, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-10', 'Curso', 324.69, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-03', 'Exames', 434.41, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Farmácia', 515.83, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-06', 'Mensalidade', 528.45, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Boliche', 150.39, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-25', 'Serviços', 192.54, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-14', 'Freelance', 1410.02, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-29', 'Luz', 483.92, 4, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-14', 'Combustível', 457.12, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-12', 'PIX recebido', 1501.22, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-22', 'Transferência enviada', 17.94, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-28', 'Mensalidade', 308.17, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-09', 'Consulta médica', 517.94, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-08', 'Transferência enviada', 322.82, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-27', 'Transferência recebida', 3378.64, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-19', 'Luz', 508.29, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-01', 'Pagamento a terceiros', 406.77, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-24', 'Salário', 1042.69, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-17', 'PIX recebido', 371.16, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-04', 'Exames', 426.28, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-10', 'Transferência recebida', 3718.37, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-15', 'Rendimento', 3022.88, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-30', 'Táxi', 292.89, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-06', 'Exames', 415.95, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Serviços', 357.21, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-22', 'Exames', 545.88, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-09', 'Transferência recebida', 3393.5, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-01', 'Consulta médica', 529.69, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-07', 'Material escolar', 540.74, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-01', 'Uber', 355.39, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-30', 'Luz', 44.69, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-06', 'Táxi', 284.97, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-01', 'Boliche', 261.17, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-05', 'Streaming', 16.01, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-05', 'Rendimento', 1413.4, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-29', 'PIX recebido', 2756.19, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-12', 'Transferência enviada', 99.56, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-04', 'Bônus', 4199.47, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-19', 'Parque', 95.37, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-29', 'Mensalidade', 432.66, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-11', 'Mensalidade', 443.09, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-09', 'Curso', 269.94, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-19', 'Transferência enviada', 224.42, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-28', 'Consulta médica', 180.87, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-08', 'Curso', 511.47, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-16', 'Mensalidade', 384.94, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-21', 'Show', 332.35, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-22', 'Padaria', 87.06, 1, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-22', 'Transferência enviada', 450.51, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-08', 'Curso', 371.66, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-13', 'Streaming', 16.19, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-18', 'Uber', 325.29, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-26', 'Pagamento a terceiros', 543.12, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-02', 'Consulta médica', 407.17, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-16', 'Streaming', 240.97, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-29', 'Curso', 380.43, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-29', 'Parque', 214.56, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-13', 'Exames', 21.75, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-16', 'Ônibus', 93.6, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-08', 'Uber', 131.87, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-06', 'Show', 81.89, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-12', 'Streaming', 406.1, 4, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-18', 'Exames', 456.01, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-22', 'Show', 290.71, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Boliche', 320.9, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-05', 'Parque', 250.13, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-21', 'Material escolar', 127.59, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-29', 'PIX recebido', 2608.5, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-12', 'Exames', 230.76, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-25', 'Transferência enviada', 154.69, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-18', 'Serviços', 518.33, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-21', 'Transferência enviada', 556.49, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-12', 'Consulta médica', 527.68, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-13', 'Padaria', 379.05, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-22', 'Curso', 96.75, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-29', 'Bônus', 1046.92, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-06', 'Uber', 207.75, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-16', 'Boliche', 176.6, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-22', 'Bônus', 4080.9, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-14', 'Ônibus', 38.01, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-01', 'Combustível', 229.38, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-07', 'Farmácia', 536.76, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-29', 'Supermercado', 582.28, 1, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-15', 'Consulta médica', 395.24, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-10', 'Mensalidade', 62.01, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-10', 'Rendimento', 2533.68, 3, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-24', 'Salário', 3574.87, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-30', 'Combustível', 174.46, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-12', 'Curso', 76.58, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-16', 'Salário', 2500.15, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-03', 'Show', 512.4, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-09', 'Transferência enviada', 576.43, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-30', 'Show', 293.25, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-16', 'Curso', 279.53, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-20', 'Salário', 3080.35, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-11', 'Transferência enviada', 548.13, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-25', 'Curso', 346.56, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-10', 'Água', 43.17, 2, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-06', 'Loja de conveniência', 357.17, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-17', 'Uber', 149.44, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-24', 'Internet', 213.71, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-14', 'Luz', 258.59, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-05', 'Cinema', 284.73, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-16', 'Serviços', 204.33, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-06', 'Material escolar', 334.37, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-21', 'Transferência recebida', 862.77, 1, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-20', 'Exames', 490.26, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-16', 'Mensalidade', 512.43, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-10', 'Pagamento a terceiros', 255.86, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-24', 'Mensalidade', 337.17, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-05', 'Transferência enviada', 455.53, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-11', 'Show', 595.93, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-18', 'Loja de conveniência', 78.59, 5, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-13', 'Curso', 279.79, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-28', 'Padaria', 118.32, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-17', 'Loja de conveniência', 247.76, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-03', 'Táxi', 366.59, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-14', 'Mensalidade', 329.79, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-27', 'Loja de conveniência', 156.22, 3, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-04', 'Bônus', 3080.49, 6, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-18', 'Freelance', 940.77, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-18', 'Freelance', 4624.17, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-02', 'PIX recebido', 3162.64, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-09', 'Transferência recebida', 4905.58, 1, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-10', 'Loja de conveniência', 491.08, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-28', 'Streaming', 386.43, 4, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-14', 'Água', 584.59, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-31', 'Curso', 235.52, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-04', 'PIX recebido', 1206.84, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-15', 'Ônibus', 348.68, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-12', 'Pagamento a terceiros', 259.58, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-31', 'Pagamento a terceiros', 469.43, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-07', 'Farmácia', 333.29, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-20', 'Transferência recebida', 338.15, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-27', 'Transferência recebida', 4532.0, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-20', 'Consulta médica', 408.76, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-21', 'Transferência recebida', 2459.13, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-15', 'Transferência enviada', 61.6, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-06', 'Bônus', 3346.56, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-26', 'Streaming', 14.59, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-31', 'Pagamento a terceiros', 412.04, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-04', 'Bônus', 3972.26, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-28', 'Farmácia', 439.67, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-17', 'Transferência recebida', 1451.03, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-28', 'Pagamento a terceiros', 202.35, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-27', 'Loja de conveniência', 557.08, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-08', 'Exames', 315.52, 2, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-23', 'Água', 111.31, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-14', 'Serviços', 260.46, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-08', 'Internet', 28.48, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-22', 'Mensalidade', 234.4, 5, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-31', 'Internet', 266.23, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-21', 'Consulta médica', 280.1, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-24', 'Salário', 1938.33, 4, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-18', 'Padaria', 244.96, 4, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-09', 'PIX recebido', 3334.36, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-13', 'Pagamento a terceiros', 581.13, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-14', 'Bônus', 1786.2, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-08', 'Salário', 826.93, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-24', 'Pagamento a terceiros', 238.24, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-24', 'Consulta médica', 550.15, 2, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-09', 'Parque', 61.82, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-10', 'Supermercado', 540.07, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-10', 'Parque', 302.77, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-03', 'Material escolar', 597.75, 1, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-22', 'Consulta médica', 220.49, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-09', 'Material escolar', 47.64, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-19', 'Transferência enviada', 301.28, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-06', 'Mensalidade', 556.32, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-12', 'Pagamento a terceiros', 438.95, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-04', 'Combustível', 86.08, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-24', 'Consulta médica', 299.43, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-09', 'Farmácia', 402.57, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-26', 'Consulta médica', 141.92, 2, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-15', 'Streaming', 118.68, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-29', 'Uber', 137.58, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-20', 'Cinema', 531.31, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-14', 'Pagamento a terceiros', 227.43, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-29', 'Parque', 405.6, 3, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-08', 'Transferência enviada', 471.03, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-12', 'Pagamento a terceiros', 423.96, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-08', 'Luz', 98.19, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-17', 'Farmácia', 518.07, 4, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-25', 'Parque', 153.91, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-24', 'Show', 124.65, 1, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-04', 'Farmácia', 250.67, 3, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-02', 'Curso', 581.86, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-21', 'Combustível', 376.63, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-12', 'Rendimento', 4528.08, 4, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-02', 'Uber', 93.77, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-14', 'Transferência enviada', 351.67, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-24', 'PIX recebido', 3636.72, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-12', 'Freelance', 4940.86, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-29', 'Material escolar', 69.0, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-20', 'Transferência enviada', 275.15, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-12', 'Freelance', 4590.68, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-08', 'PIX recebido', 1753.72, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-20', 'Curso', 531.44, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-29', 'Curso', 344.3, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-14', 'Pagamento a terceiros', 123.82, 1, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-31', 'Farmácia', 315.75, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-21', 'Mensalidade', 54.97, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-01', 'Cinema', 132.18, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-20', 'Táxi', 463.09, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-29', 'Boliche', 514.06, 2, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-18', 'Consulta médica', 253.57, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-24', 'Loja de conveniência', 575.53, 5, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-14', 'Padaria', 458.09, 5, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-03', 'Rendimento', 3269.91, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-19', 'Transferência enviada', 489.11, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-30', 'Mensalidade', 128.61, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-31', 'Mensalidade', 104.27, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-30', 'Táxi', 216.05, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-02', 'Táxi', 458.62, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-16', 'Combustível', 385.86, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Freelance', 769.95, 1, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-14', 'Rendimento', 2346.83, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-15', 'Ônibus', 530.48, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-26', 'PIX recebido', 2721.48, 3, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-28', 'Táxi', 333.65, 2, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-28', 'Curso', 585.68, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-08', 'Pagamento a terceiros', 288.58, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-20', 'Pagamento a terceiros', 307.91, 3, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-30', 'Transferência enviada', 280.67, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-17', 'Internet', 382.24, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-10', 'Combustível', 111.66, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-15', 'Uber', 452.39, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-30', 'Streaming', 507.64, 1, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-17', 'Transferência recebida', 3622.94, 2, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-20', 'Exames', 144.64, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-21', 'Consulta médica', 268.43, 5, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-22', 'Mensalidade', 410.84, 6, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-26', 'Transferência recebida', 3191.93, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-20', 'Show', 21.08, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-11', 'Transferência enviada', 333.32, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-12', 'Padaria', 252.51, 6, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-09', 'Transferência recebida', 4270.29, 1, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-29', 'Serviços', 196.68, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-27', 'Material escolar', 184.08, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-27', 'Serviços', 337.07, 4, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-30', 'Parque', 475.92, 4, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-16', 'Uber', 62.5, 4, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-29', 'Internet', 410.89, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-07', 'Ônibus', 505.06, 3, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-29', 'Uber', 361.43, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-19', 'Boliche', 552.38, 5, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-14', 'Combustível', 153.1, 1, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-16', 'Curso', 153.26, 2, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-11', 'Transferência recebida', 368.17, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-01', 'Táxi', 227.67, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-15', 'Pagamento a terceiros', 337.88, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-23', 'Bônus', 2317.67, 5, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-22', 'Combustível', 481.28, 5, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-04-30', 'Exames', 210.18, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-22', 'Serviços', 162.5, 5, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-27', 'Internet', 266.27, 6, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-17', 'PIX recebido', 4289.57, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-12', 'Transferência enviada', 563.85, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-03', 'Pagamento a terceiros', 339.29, 5, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-02', 'Freelance', 1907.08, 2, 1);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-27', 'Luz', 418.94, 3, 6);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-24', 'Pagamento a terceiros', 586.78, 6, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-28', 'Pagamento a terceiros', 195.84, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-08-25', 'Supermercado', 438.39, 2, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-28', 'Pagamento a terceiros', 325.74, 2, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-07', 'PIX recebido', 4338.49, 5, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-02-15', 'PIX recebido', 1150.35, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-09-14', 'Táxi', 391.45, 6, 4);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-16', 'Exames', 364.1, 6, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-21', 'Consulta médica', 428.44, 1, 9);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-10-07', 'Material escolar', 286.28, 3, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-03-28', 'PIX recebido', 3873.72, 6, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-10', 'Parque', 559.17, 6, 3);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-11-19', 'Transferência recebida', 4299.7, 4, 8);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-07-12', 'Transferência enviada', 148.67, 4, 7);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-01-25', 'Loja de conveniência', 582.35, 4, 2);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-05-06', 'Material escolar', 313.39, 4, 5);
INSERT INTO Movimentacao (Data, Descricao, Valor, IdConta, IdGrupoMov) VALUES ('2025-06-03', 'Supermercado', 66.51, 2, 2);