-- Creacion de la base de datos (DATABASE=SCHEMA)
CREATE DATABASE banco_libro;

USE banco_libro;

CREATE TABLE cliente(
	id_cliente CHAR(10),
    nombre_cliente VARCHAR(50) NOT NULL,
    calle_cliente VARCHAR(50),
    ciudad_cliente VARCHAR(50),
    CONSTRAINT PK_cliente_id
		PRIMARY KEY(id_cliente)
);

CREATE TABLE sucursal(
	nombre_sucursal VARCHAR(50),
    ciudad_sucursal VARCHAR(50),
    activos DECIMAL(11,2) UNSIGNED NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_sucursal_nombre
		PRIMARY KEY(nombre_sucursal)
);

CREATE TABLE empleado(
	id_empleado VARCHAR(10),
    nombre_empleado VARCHAR(50) NOT NULL,
    numero_telefono VARCHAR(16),
    fecha_contratacion DATE NOT NULL,
    CONSTRAINT PK_empleado_id
		PRIMARY KEY(id_empleado)
);

CREATE TABLE prestamo(
	numero_prestamo VARCHAR(7),
    nombre_sucursal VARCHAR(50),
    importe DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 1000.00,
    CONSTRAINT PK_prestamo_numero
		PRIMARY KEY(numero_prestamo)
);

CREATE TABLE pago(
	numero_prestamo VARCHAR(7),
    numero_pago TINYINT UNSIGNED NOT NULL DEFAULT 1,
    fecha_pago DATE NOT NULL,
    importe_pago DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_pago_prestamo_numero
		PRIMARY KEY(numero_prestamo,numero_pago)
);

CREATE TABLE cuenta(
	numero_cuenta VARCHAR(7),
    nombre_sucursal VARCHAR(50),
    saldo DECIMAL(8,2) SIGNED NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_cuenta_numero
		PRIMARY KEY(numero_cuenta)
);

CREATE TABLE cuenta_ahorro(
	numero_cuenta VARCHAR(7) NOT NULL,
    tasa_interes DECIMAL(5,2) UNSIGNED NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_ahorro_numero
		PRIMARY KEY(numero_cuenta)
);

CREATE TABLE cuenta_corriente(
	numero_cuenta VARCHAR(7) NOT NULL,
    importe_descubiero DECIMAL(8,2) UNSIGNED NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_corriente_numero
		PRIMARY KEY(numero_cuenta)
);

CREATE TABLE asesor_persona(
	id_empleado CHAR(10) NOT NULL,
    id_cliente CHAR(10) NOT NULL,
    tipo ENUM('Asesor Personal', 'Prestatario') NOT NULL DEFAULT 'Asesor Personal',
    CONSTRAINT PK_asesor_cliente_empleado
		PRIMARY KEY(id_empleado,id_cliente)
);

CREATE TABLE trabajar_para(
	id_trabajador CHAR(10) NOT NULL,
    id_jefe CHAR(10),
    CONSTRAINT PK_trabajar_trabajador
		PRIMARY KEY(id_trabajador)
);

CREATE TABLE impositor(
	id_cliente CHAR(10),
    numero_cuenta VARCHAR(7),
    fecha_acceso DATE NOT NULL,
    CONSTRAINT PK_impositor_cliente_cuenta
		PRIMARY KEY(id_cliente,numero_cuenta)
);

CREATE TABLE prestatario(
	id_cliente CHAR(10),
    numero_prestamo VARCHAR(7),
    CONSTRAINT PK_prestatario_cliente_prestamo
		PRIMARY KEY(id_cliente,numero_prestamo)
);

-- Modificaciones de las tablas de la base de datos
ALTER TABLE prestamo
ADD CONSTRAINT FK_sucursal_prestamo
	FOREIGN KEY(nombre_sucursal)
    REFERENCES sucursal(nombre_sucursal)
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT;

ALTER TABLE pago
ADD CONSTRAINT FK_prestamo_pago
	FOREIGN KEY(numero_prestamo)
    REFERENCES  prestamo(numero_prestamo)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
ALTER TABLE cuenta
ADD CONSTRAINT FK_sucursal_cuenta
	FOREIGN KEY(nombre_sucursal)
    REFERENCES sucursal(nombre_sucursal)
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT;

ALTER TABLE cuenta_ahorro
ADD CONSTRAINT FK_cuenta_cuenta_ahorro
	FOREIGN KEY(numero_cuenta)
    REFERENCES cuenta(numero_cuenta)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
ALTER TABLE cuenta_corriente
ADD CONSTRAINT FK_cuenta_cuenta_corriente
	FOREIGN KEY(numero_cuenta)
    REFERENCES cuenta(numero_cuenta)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
ALTER TABLE asesor_persona
ADD CONSTRAINT FK_empleado_asesor
	FOREIGN KEY(id_empleado)
    REFERENCES empleado(id_empleado)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
ADD CONSTRAINT FK_cliente_asesor
	FOREIGN KEY(id_cliente)
    REFERENCES cliente(id_cliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
ALTER TABLE trabajar_para
ADD CONSTRAINT FK_empleado_trabaja
	FOREIGN KEY(id_trabajador)
    REFERENCES empleado(id_empleado)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
ADD CONSTRAINT FK_empleado_trabaja_jefe
	FOREIGN KEY(id_jefe)
    REFERENCES empleado(id_empleado)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;
    
ALTER TABLE impositor
ADD CONSTRAINT FK_cliente_impositor
	FOREIGN KEY(id_cliente)
    REFERENCES cliente(id_cliente)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
ADD CONSTRAINT FK_cuenta_impositor
	FOREIGN KEY(numero_cuenta)
    REFERENCES cuenta(numero_cuenta)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
    
ALTER TABLE prestatario
ADD CONSTRAINT FK_cliente_prestatario
	FOREIGN KEY(id_cliente)
    REFERENCES cliente(id_cliente)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
ADD CONSTRAINT FK_cuenta_prestatario
	FOREIGN KEY(numero_prestamo)
    REFERENCES prestamo(numero_prestamo)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Creacion de llaves candidatas
ALTER TABLE cliente
ADD CONSTRAINT UQ_cliente_nombre
	UNIQUE KEY (nombre_cliente);

ALTER TABLE empleado
ADD CONSTRAINT UQ_empleado_nombre
	UNIQUE KEY (nombre_empleado);

-- Creacion de indices para la realizacion de busquedas
ALTER TABLE empleado
ADD INDEX IDX_empleado_antiguedad(fecha_contratacion);

ALTER TABLE pago
ADD INDEX IDX_pago_datos(numero_pago, fecha_pago, importe_pago);

-- Modificacion de valores por defecto con casos especiales
ALTER TABLE empleado
MODIFY fecha_contratacion DATE NOT NULL DEFAULT(CURRENT_DATE); 

ALTER TABLE pago
MODIFY fecha_pago DATE NOT NULL DEFAULT(CURRENT_DATE);

ALTER TABLE impositor
MODIFY fecha_acceso DATE NOT NULL DEFAULT(CURRENT_DATE);

-- Agregar retricciones CHECK
ALTER TABLE cliente
ADD CONSTRAINT CK_cliente_patron
CHECK(id_cliente RLIKE '[0-9][0-9]\\.[0-9][0-9][0-9]\\.[0-9][0-9][0-9]');

ALTER TABLE empleado
ADD CONSTRAINT CK_empleado_patron
CHECK(id_empleado RLIKE '[0-9][0-9]\\.[0-9][0-9][0-9]\\.[0-9][0-9][0-9]');

ALTER TABLE empleado
ADD CONSTRAINT CK_empleado_telefono_patron
CHECK(numero_telefono RLIKE '\\(\\+591\\)[0-9]{3}-[0-9]{2}-[0-9]{3}');