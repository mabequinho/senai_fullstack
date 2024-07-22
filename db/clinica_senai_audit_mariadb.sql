-- https://mariadb.com/kb/en/mariadb-audit-plugin-installation/
INSTALL SONAME 'server_audit';

SELECT PLUGIN_NAME, PLUGIN_STATUS
FROM INFORMATION_SCHEMA.PLUGINS
WHERE PLUGIN_NAME = 'server_audit';

SHOW VARIABLES LIKE 'server_audit%';

-- https://mariadb.com/kb/en/mariadb-audit-plugin-configuration/
SET GLOBAL server_audit_logging=ON;
SET GLOBAL server_audit_events = 'CONNECT,QUERY,TABLE';
SET GLOBAL server_audit_file_rotate_now = ON;
SET GLOBAL server_audit_query_log_limit = 2147483647;


DROP DATABASE IF EXISTS clinica_senai;
CREATE DATABASE clinica_senai /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE clinica_senai;

-- mydb.paciente definition

CREATE TABLE `paciente` (
  `cpf` varchar(14) NOT NULL,
  `nome_paciente` varchar(40) NOT NULL,
  `telefone` varchar(14) NOT NULL,
  `numero_plano` int(11) NOT NULL,
  `nome_plano` varchar(20) NOT NULL,
  `tipo_plano` varchar(10) NOT NULL,
  PRIMARY KEY (`cpf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- mydb.medico definition

CREATE TABLE `medico` (
  `crm` int(11) NOT NULL,
  `nome_medico` varchar(40) NOT NULL,
  `especialidade` varchar(20) NOT NULL,
  PRIMARY KEY (`crm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- mydb.exame definition

CREATE TABLE `exame` (
  `codigo` int(11) NOT NULL,
  `especificacao` varchar(20) NOT NULL,
  `preco` decimal(10,0) NOT NULL,
  PRIMARY KEY (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- mydb.consulta definition

CREATE TABLE `consulta` (
  `numero_consulta` int(11) NOT NULL AUTO_INCREMENT,
  `data_consulta` date NOT NULL,
  `horario_consulta` time NOT NULL,
  `fk_paciente_cpf` varchar(14) NOT NULL,
  `fk_medico_crm` int(11) NOT NULL,
  PRIMARY KEY (`numero_consulta`),
  KEY `consulta_paciente_FK` (`fk_paciente_cpf`),
  KEY `consulta_medico_FK` (`fk_medico_crm`),
  CONSTRAINT `consulta_medico_FK` FOREIGN KEY (`fk_medico_crm`) REFERENCES `medico` (`crm`),
  CONSTRAINT `consulta_paciente_FK` FOREIGN KEY (`fk_paciente_cpf`) REFERENCES `paciente` (`cpf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- mydb.pedido_exame definition

CREATE TABLE `pedido_exame` (
  `numero_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `resultado` varchar(40) NOT NULL,
  `data_exame` date NOT NULL,
  `valor_pagar` decimal(10,0) NOT NULL,
  `desconto` DECIMAL(10, 2) DEFAULT 0.00,
  `fk_consulta_numero_consulta` int(11) NOT NULL,
  `fk_exame_codigo` int(11) NOT NULL,
  PRIMARY KEY (`numero_pedido`),
  KEY `pedido_exame_exame_FK` (`fk_exame_codigo`),
  KEY `pedido_exame_consulta_FK` (`fk_consulta_numero_consulta`),
  CONSTRAINT `pedido_exame_consulta_FK` FOREIGN KEY (`fk_consulta_numero_consulta`) REFERENCES `consulta` (`numero_consulta`),
  CONSTRAINT `pedido_exame_exame_FK` FOREIGN KEY (`fk_exame_codigo`) REFERENCES `exame` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Criando o trigger para definir o valor e ajustar o desconto
DELIMITER $$

CREATE TRIGGER before_insert_pedido_exame
BEFORE INSERT ON pedido_exame
FOR EACH ROW
BEGIN
    DECLARE plano_tipo VARCHAR(10);
    DECLARE desconto_aplicado DECIMAL(10, 2);
    DECLARE preco_exame DECIMAL(10, 0);

    -- Obtendo o preço do exame
    SELECT e.preco
    INTO preco_exame
    FROM exame e
    WHERE e.codigo = NEW.fk_exame_codigo;

    -- Definindo o valor a pagar como o preço do exame
    SET NEW.valor_pagar = preco_exame;

    -- Obtendo o tipo de plano do paciente
    SELECT p.tipo_plano
    INTO plano_tipo
    FROM consulta c
    JOIN paciente p ON c.fk_paciente_cpf = p.cpf
    WHERE c.numero_consulta = NEW.fk_consulta_numero_consulta;

    -- Determinando o desconto com base no tipo de plano
    IF plano_tipo = 'Básico' THEN
        SET desconto_aplicado = 0.1;
    ELSEIF plano_tipo = 'Padrão' THEN
        SET desconto_aplicado = 0.3;
    ELSEIF plano_tipo = 'Especial' THEN
        SET desconto_aplicado = 1;
    ELSE
        SET desconto_aplicado = 0.00; -- Sem desconto para outros tipos de plano
    END IF;

    -- Ajustando o valor do desconto e valor a pagar
    SET NEW.desconto = NEW.valor_pagar * desconto_aplicado;
    SET NEW.valor_pagar = NEW.valor_pagar * (1 - desconto_aplicado);
END$$

DELIMITER ;


-- Sem equivalente ao SET NOCOUNT ON no Mariadb
-- SET NOCOUNT ON
-- DELETE FROM pedido_exame ;
-- equivalento Mariadb ao DBCC CHECKIDENT('pedido_exame', RESEED, 2199);
ALTER TABLE pedido_exame AUTO_INCREMENT = 2199;

-- Inserir dados na tabela paciente
INSERT INTO paciente (cpf, nome_paciente, telefone, numero_plano, nome_plano, tipo_plano) VALUES
('012.345.678-90', 'Leonardo Ribeiro', '(11)91234-5678', 123456, 'Inovamed', 'Padrão'),
('123.456.789-12', 'Bruna Alvez', '(15)92345-6789', 234567, 'Ultramed', 'Básico'),
('234.567.890-23', 'Gilberto Barros', '(11)94567-8901', 345678, 'Inovamed', 'Especial'),
('345.678.901-45', 'Maria Pereira', '(12)95678-9012', 456789, 'Ultramed', 'Padrão'),
('567.890.123-45', 'Ana Santos', '(21)98765-4321', 678901, 'SaúdePlus', 'Padrão'),
('678.901.234-56', 'Paulo Silva', '(31)91234-9876', 789012, 'SaúdeMais', 'Básico');

-- Inserir dados na tabela medico
INSERT INTO medico (crm, nome_medico, especialidade) VALUES
(102030, 'Agildo Nunes', 'Cardiologia'),
(203040, 'Márcia Alvez', 'Gastroenterologia'),
(304050, 'Roberto Gusmão', 'Neurologia'),
(405060, 'Edna Cardoso', 'Ortopedia'),
(506070, 'Ricardo Souza', 'Otorrinolaringologia'),
(607080, 'Lúcia Ferreira', 'Dermatologia');

-- Inserir dados na tabela exame
INSERT INTO exame (codigo, especificacao, preco) VALUES
(10020, 'Hemograma', 120.00),
(10030, 'Tomografia', 270.00),
(10040, 'Ultrassonografia', 600.00),
(10050, 'Ressonância', 850.00),
(10060, 'Radiografia', 90.00),
(10070, 'Ecocardiograma', 150.00),
(10080, 'Mamografia', 200.00);

-- Inserir dados na tabela consulta
INSERT INTO consulta (data_consulta, horario_consulta, fk_paciente_cpf, fk_medico_crm) VALUES
('2023-07-10', '10:30:00', '012.345.678-90', 102030),
('2023-07-11', '09:00:00', '123.456.789-12', 203040),
('2023-07-12', '11:15:00', '234.567.890-23', 304050),
('2023-07-13', '13:45:00', '345.678.901-45', 405060),
('2023-07-14', '15:30:00', '567.890.123-45', 506070),
('2023-07-15', '10:00:00', '678.901.234-56', 607080);

-- Inserir dados na tabela pedido_exame
INSERT INTO pedido_exame (resultado, data_exame, fk_consulta_numero_consulta, fk_exame_codigo) VALUES
('Normal', '2023-07-15', 1, 10020),   -- Paciente com plano Padrão
('', '2023-07-16', 2, 10030),   -- Paciente com plano Básico
('Normal', '2023-07-17', 3, 10040),   -- Paciente com plano Especial
('Alterado', '2023-07-18', 4, 10050),   -- Paciente com plano Padrão
('Inconsistente', '2023-07-19', 5, 10060),   -- Paciente com plano Padrão
('Normal', '2023-07-20', 1, 10070),   -- Paciente com plano Padrão
('', '2023-07-21', 6, 10080);   -- Paciente com plano Básico


-- Consultar os dados para ver o resultado do trigger
SELECT * FROM pedido_exame;

DELIMITER $$

CREATE PROCEDURE Agenda_Medicos()
BEGIN
    SELECT m.nome_medico, m.especialidade, m.crm, c.numero_consulta,
    c.data_consulta, c.horario_consulta, p.nome_paciente, p.cpf,
    p.nome_plano, p.tipo_plano
    FROM medico AS m
    INNER JOIN consulta AS c ON m.crm = c.fk_medico_crm
    INNER JOIN paciente AS p ON c.fk_paciente_cpf = p.cpf
    ORDER BY m.nome_medico, c.data_consulta;
END$$

DELIMITER ;

-- Executar a procedure
CALL Agenda_Medicos();

DELIMITER $$

CREATE PROCEDURE Resumo_Pagamentos(IN nome_pac VARCHAR(40))
BEGIN
    SELECT pa.nome_paciente, SUM(pe.valor_pagar) AS total_pagar
    FROM paciente AS pa
    INNER JOIN consulta AS c ON pa.cpf = c.fk_paciente_cpf
    INNER JOIN pedido_exame AS pe ON c.numero_consulta = pe.fk_consulta_numero_consulta
    WHERE pa.nome_paciente = nome_pac
    GROUP BY pa.nome_paciente;
END$$

DELIMITER ;

-- Executar a procedure com parâmetro
CALL Resumo_Pagamentos('Leonardo Ribeiro');

DELIMITER $$

CREATE PROCEDURE Exames_Solicitados()
BEGIN
    SELECT m.nome_medico, m.especialidade, m.crm, c.numero_consulta,
           p.numero_pedido, p.data_exame, e.codigo, e.especificacao
    FROM medico AS m
    INNER JOIN consulta AS c ON m.crm = c.fk_medico_crm
    INNER JOIN pedido_exame AS p ON c.numero_consulta = p.fk_consulta_numero_consulta
    INNER JOIN exame AS e ON p.fk_exame_codigo = e.codigo
    ORDER BY m.nome_medico, p.data_exame;
END$$

DELIMITER ;

-- Executar a procedure
CALL Exames_Solicitados();

DELIMITER $$

CREATE PROCEDURE Historico_Pagamentos()
BEGIN
    SELECT pa.nome_paciente, pa.cpf, c.numero_consulta,
           c.data_consulta, pe.data_exame, pe.valor_pagar,
           e.codigo, e.especificacao
    FROM paciente AS pa
    INNER JOIN consulta AS c ON pa.cpf = c.fk_paciente_cpf
    INNER JOIN pedido_exame AS pe ON c.numero_consulta = pe.fk_consulta_numero_consulta
    INNER JOIN exame AS e ON pe.fk_exame_codigo = e.codigo
    ORDER BY pa.nome_paciente, pe.data_exame;
END$$

DELIMITER ;

-- Executar a procedure
CALL Historico_Pagamentos();
