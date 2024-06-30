/*
Arquivo feito para responder a Tarefa 3.4 (criar um arquivo .sql
com os comandas de carga das tabelas mapeadas)
*/

/* Criando as tabelas ajustadas
    - leia o pdf "BDT2 - Tarefa 3.1" com a explicação
*/
DROP TABLE IF EXISTS Localizacao_new CASCADE;
CREATE TABLE Localizacao_new (
    localizacao_id                  BIGSERIAL PRIMARY KEY,
    Pais                            VARCHAR(100) NOT NULL,
    Estado                          VARCHAR(100),
    Cidade                          VARCHAR(100) NOT NULL,
    Bairro                          VARCHAR(255)
);

DROP TABLE IF EXISTS Usuario_new CASCADE;
CREATE TABLE Usuario_new(
    usuario_id                      BIGINT,
    nome                            VARCHAR(255),
    localizacao_id                  BIGINT,
    locatarioSN                     BOOLEAN,
    PRIMARY KEY (usuario_id,locatarioSN),
    FOREIGN KEY (localizacao_id) REFERENCES Localizacao_new(localizacao_id)
);

DROP TABLE IF EXISTS Propriedade_new CASCADE;
CREATE TABLE Propriedade_new (
    propriedade_id              BIGINT PRIMARY KEY,
    nome                        VARCHAR(255) NOT NULL,
    classe                      VARCHAR(255),
    numQuartos                  INTEGER,
    numCamas                    INTEGER,
    numBanheiros                FLOAT,
    maxHospedes                 INTEGER,
    minNoites                   INTEGER,
    maxNoites                   INTEGER,
    localizacao_id              BIGINT,
    locador_id                  BIGINT,
    LocatarioSN                 BOOLEAN,
    FOREIGN KEY (localizacao_id) REFERENCES Localizacao_new(localizacao_id),
    FOREIGN KEY (locador_id,LocatarioSN) REFERENCES Usuario_new(usuario_id,locatarioSN)
);

DROP TABLE IF EXISTS Mensagem_new CASCADE;
CREATE TABLE Mensagem_new(
    mensagem_id                   BIGSERIAL,
    dataMensagem                  DATE NOT NULL,
    texto                         TEXT NOT NULL,
    locatario_id                  BIGINT NOT NULL,
    propriedade_id                BIGINT NOT NULL,
    LocatarioSN                   BOOLEAN,
    
    PRIMARY KEY (mensagem_id),
    FOREIGN KEY (locatario_id,LocatarioSN) REFERENCES Usuario_new(usuario_id,locatarioSN),
    FOREIGN KEY (propriedade_id) REFERENCES Propriedade_new(propriedade_id)
);

DROP TABLE IF EXISTS Diarias_new CASCADE;
CREATE TABLE Diarias_new(
    diaria_id                       BIGSERIAL,
    propriedade_id                  BIGINT,
    data                            DATE,
    valor                           FLOAT,
    PRIMARY KEY (diaria_id),
    UNIQUE (propriedade_id,data),
    FOREIGN KEY (propriedade_id) REFERENCES Propriedade_new(propriedade_id)
);





-- função pra sempre que precisar adicionar uma localização, ele adiciona e já retorna o id dela pra usar como fk
CREATE OR REPLACE FUNCTION add_localizacao(
    Pais                            VARCHAR(100),
    Estado                          VARCHAR(100),
    Cidade                          VARCHAR(100),
    Bairro                          VARCHAR(255)
)
    RETURNS BIGINT AS $$
        DECLARE
            new_id BIGINT;
        BEGIN
            INSERT INTO Localizacao_new (Pais,Estado,Cidade,Bairro)
                VALUES (Pais,Estado,Cidade,Bairro)
            RETURNING localizacao_id INTO new_id;
            
            RETURN new_id;
        END;
    $$ LANGUAGE plpgsql;



/* Colocando os usuários que são locadores e suas localizações */
INSERT 
    INTO Usuario_new (usuario_id,nome,localizacao_id,locatarioSN)
    SELECT 
        host_id,
        host_name,
        add_localizacao(
            COALESCE(SPLIT_PART(host_location,', ',2),''), 
            '',                             
            COALESCE(SPLIT_PART(host_location,', ',1),''),
            ''                              
        ),
        FALSE
    FROM Host_final;
    

/* Inserindo as propriedades e suas localizações */
INSERT
    INTO Propriedade_new (
        propriedade_id,
        nome,
        classe,
        numQuartos,
        numCamas,
        numBanheiros,
        maxHospedes,
        minNoites,
        maxNoites,
        localizacao_id,
        locador_id,
        locatarioSN
    )
    SELECT
        listing_id,
        nome,
        property_type,
        nquartos,
        ncamas,
        nbanheiros,
        accommodates,
        minimum_nights,
        maximum_nights,
        add_localizacao(
            'Brazil',
            'Rio de Janeiro',                             
            'Rio de Janeiro',
            COALESCE(neighbourhood_cleansed,'')
        ),
        host_id,
        FALSE
        FROM Listings_final;

/* Inserindo usuários locatários */
INSERT 
    INTO Usuario_new (usuario_id,nome,localizacao_id,locatarioSN)
    SELECT 
        reviewer_id,
        reviewer_name,
        NULL,
        TRUE
    FROM Reviewers_final;
    
/* Inserindo as mensagens */
INSERT INTO Mensagem_new (
        mensagem_id,
        dataMensagem,
        texto,
        locatario_id,
        propriedade_id,
        LocatarioSN
    )
    SELECT
        id_review,
        date,
        comments,
        reviewer_id,
        listing_id,
        TRUE
    FROM Reviews_final;



/* Inserindo as diárias */
INSERT INTO Diarias_new (
        diaria_id,
        propriedade_id,
        data,
        valor
    )
    SELECT
        calendar_id,
        listing_id,
        date,
        price
    FROM Calendar_final;