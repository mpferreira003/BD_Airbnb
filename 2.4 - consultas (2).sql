-- QUESTÃO 06

-- Busca de 10 tuplas aleatorias na tabela Propriedade_new
SELECT * 
	FROM Propriedade_new
	ORDER BY RANDOM()
	LIMIT 10;


-- Contabiliza a quantidade de propriedades de cada classe
SELECT Classe, COUNT(Classe)
	FROM Propriedade_new
	GROUP BY Classe
	LIMIT 10;


-- Como o atributo Listings.neighbourhood_cleansed foi transcrito como o atributo "bairro"
-- contabilizamos a quantidade de bairros existentes na base
-- Nessa busca tambem esta sendo contabilizado o campo vazio (' '), por isso, contabiliza-se um a mais
SELECT COUNT(DISTINCT(Bairro)) AS QuantidadeLocalizacoes FROM Localizacao_new;



-- QUESTÃO 07

-- Sao procuradas na tabela Diarias_New as propriedades que tiveram disponibilidade em todo
-- ano de 2024, logo depois essas propriedade são ordenadas pela data e suas informações exibidas
DROP VIEW IF EXISTS Propriedades_Disponiveis;
CREATE VIEW Propriedades_Disponiveis  AS
SELECT P.*, D.Diaria_Id, D.Valor, D.Data
	FROM Propriedade_new P, Diarias_new D 
	WHERE D.Propriedade_Id = P.Propriedade_Id 
	AND D.Data BETWEEN '2024-01-01' AND '2024-12-31'
	ORDER BY D.Data;


-- É calculado o valor da media das diarias de cada propriedade disponivel em cada mes do ano de 2024
SELECT DATE_TRUNC('month', PD.Data) AS Mes, 
	AVG(PD.valor) AS Preco_Medio_Por_Noite
	FROM Propriedades_Disponiveis PD
	GROUP BY Mes
	ORDER BY Mes;



-- QUESTÃO 08

-- É exibido o nome, localizacao e quantidade de propriedades de um usuario que seja locador e possua tres ou mais propriedades
SELECT U.Nome, L.Cidade, COUNT(DISTINCT P.Propriedade_Id) AS Quantidade_Imoveis
	FROM Usuario_new U
	JOIN Propriedade_New P ON U.Usuario_Id = P.Locador_Id
	JOIN Localizacao_New L ON U.Localizacao_Id = L.Localizacao_Id
	GROUP BY U.Nome, L.Cidade
	HAVING COUNT(DISTINCT P.Propriedade_Id) >= 3
	LIMIT 10;


-- Foi escolhido o index para o id_usuario da tabela Usuario_new a fim de otimizar o máximo possível a busca.
DROP INDEX IF EXISTS idx_usuario_id;
CREATE INDEX idx_usuario_id ON Usuario_new (usuario_id);

