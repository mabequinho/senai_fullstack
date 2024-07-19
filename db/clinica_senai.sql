
DROP DATABASE clinica_senai;
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

-- Criando o trigger para ajustar o valor do desconto
DELIMITER $$

CREATE TRIGGER before_insert_pedido_exame
BEFORE INSERT ON pedido_exame
FOR EACH ROW
BEGIN
    DECLARE plano_tipo VARCHAR(10);
    DECLARE desconto_aplicado DECIMAL(10, 2);

    -- Obtendo o tipo de plano do paciente
    SELECT p.tipo_plano
    INTO plano_tipo
    FROM consulta c
    JOIN paciente p ON c.fk_paciente_cpf = p.cpf
    WHERE c.numero_consulta = NEW.fk_consulta_numero_consulta;

    -- Determinando o desconto com base no tipo de plano
    IF plano_tipo = 'Padrão' THEN
        SET desconto_aplicado = 0.05;
    ELSEIF plano_tipo = 'Básico' THEN
        SET desconto_aplicado = 0.10;
    ELSEIF plano_tipo = 'Especial' THEN
        SET desconto_aplicado = 0.15;
    ELSEIF plano_tipo = 'Premium' THEN
        SET desconto_aplicado = 0.20;
    ELSE
        SET desconto_aplicado = 0.00; -- Sem desconto para outros tipos de plano
    END IF;

    -- Ajustando o valor do desconto e valor a pagar
    SET NEW.desconto = NEW.valor_pagar * desconto_aplicado;
    SET NEW.valor_pagar = NEW.valor_pagar * (1 - desconto_aplicado);
END$$

DELIMITER ;

-- Inserir dados na tabela paciente
INSERT INTO paciente (cpf, nome_paciente, telefone, numero_plano, nome_plano, tipo_plano) VALUES
('012.345.678-90', 'Leonardo Ribeiro', '(11)91234-5678', 123456, 'Inovamed', 'Padrão'),
('123.456.789-12', 'Bruna Alvez', '(15)92345-6789', 234567, 'Ultramed', 'Básico'),
('234.567.890-23', 'Gilberto Barros', '(11)94567-8901', 345678, 'Inovamed', 'Especial'),
('345.678.901-45', 'Maria Pereira', '(12)95678-9012', 456789, 'Ultramed', 'Padrão'),
('567.890.123-45', 'Ana Santos', '(21)98765-4321', 678901, 'SaúdePlus', 'Premium'),
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
INSERT INTO pedido_exame (resultado, data_exame, valor_pagar, fk_consulta_numero_consulta, fk_exame_codigo) VALUES
('Normal', '2023-07-15', 120.00, 1, 10020),   -- Paciente com plano Padrão
('Normal', '2023-07-16', 270.00, 2, 10030),   -- Paciente com plano Básico
('Normal', '2023-07-17', 600.00, 3, 10040),   -- Paciente com plano Especial
('Normal', '2023-07-18', 850.00, 4, 10050),   -- Paciente com plano Padrão
('Normal', '2023-07-19', 90.00, 5, 10060),    -- Paciente com plano Premium
('Normal', '2023-07-20', 150.00, 1, 10070),   -- Paciente com plano Padrão
('Normal', '2023-07-21', 200.00, 6, 10080);   -- Paciente com plano Básico

-- Consultar os dados para ver o resultado do trigger
SELECT * FROM pedido_exame;
