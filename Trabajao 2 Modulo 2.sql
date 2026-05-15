CREATE SCHEMA Ventas;
GO

CREATE TABLE Ventas.Clientes (
ID_Cliente BIGINT IDENTITY (1, 1) PRIMARY KEY,
CUIT VARCHAR (15) NOT NULL,
Nombre VARCHAR (25) NOT NULL,
Direccion VARCHAR (40) NOT NULL,
Provincia VARCHAR (40) NOT NULL
);

CREATE TABLE Ventas.Producto (
ID_Producto BIGINT IDENTITY (1, 1) PRIMARY KEY,
Nombre_Producto VARCHAR (40) NOT NULL,
Precio_Compra DECIMAL (18, 2) NOT NULL CHECK (Precio_Compra >=0),
Precio_Venta DECIMAL (18, 2) NOT NULL CHECK (Precio_Venta >=0),
Stock INT NOT NULL
);

CREATE TABLE Ventas.Venta (
ID_Venta BIGINT IDENTITY (1, 1) PRIMARY KEY,
Fecha_Venta DATE NOT NULL,
ID_Cliente BIGINT NOT NULL,
ID_Producto BIGINT NOT NULL,

FOREIGN KEY (ID_Cliente) REFERENCES Ventas.Clientes (ID_Cliente),
FOREIGN KEY (ID_Producto) REFERENCES Ventas.Producto (ID_Producto)
);
GO


CREATE SCHEMA Logistica;
GO

CREATE TABLE Logistica.Camion (
ID_Camion BIGINT IDENTITY (1, 1) PRIMARY KEY,
Patente VARCHAR (20) NOT NULL,
Modelo VARCHAR (20) NOT NULL,
Motor VARCHAR (20) NOT NULL,
Chasis VARCHAR (20) NOT NULL
);

CREATE TABLE Logistica.Chofer (
ID_Chofer BIGINT IDENTITY (1, 1) PRIMARY KEY,
Nombre VARCHAR (25) NOT NULL,
Apellido VARCHAR (25) NOT NULL,
DNI VARCHAR (15) NOT NULL,
Telefono VARCHAR (15) NOT NULL
);

CREATE TABLE Logistica.Envio (
ID_Envio BIGINT IDENTITY (1, 1) PRIMARY KEY,
ID_Venta BIGINT,
Fecha_Envio DATE NOT NULL,
Estado_Envio VARCHAR (25) DEFAULT 'En Curso',
Fecha_de_Entrega DATE NOT NULL,
ID_Camion BIGINT,
ID_Chofer BIGINT,

FOREIGN KEY (ID_Venta) REFERENCES Ventas.Venta (ID_Venta),
FOREIGN KEY (ID_Camion) REFERENCES Logistica.Camion (ID_Camion),
FOREIGN KEY (ID_Chofer) REFERENCES Logistica.Chofer (ID_Chofer)
);
GO


CREATE SCHEMA Analytics;
GO


CREATE VIEW Analytics.vw_Margenes_de_Venta AS
SELECT
    V.ID_Venta,
    V.Fecha_Venta,
	P.Nombre_Producto,
	P.Precio_Compra,
	P.Precio_Venta,
	(P.Precio_Venta - P.Precio_Compra) AS Ganancia_Absoluta,
	ROUND ((P.Precio_Venta - P.Precio_Compra) / P.Precio_Venta * 100,2) AS Porcentaje_Margen
	FROM Ventas.Venta V INNER JOIN Ventas.Producto P ON V.ID_Producto = P.ID_Producto;
GO


CREATE VIEW Analytics.vw_Ventas_por_Cliente AS
SELECT
    C.ID_Cliente,
	C.Nombre AS Nombre_Cliente,
	COUNT (V.ID_Venta) AS Total_Ventas_Realizadas,
	SUM (P.Precio_Venta) AS Facturación_Total_Cliente
FROM Ventas.Clientes C
LEFT JOIN Ventas.Venta V ON C.ID_Cliente = V.ID_Cliente
LEFT JOIN Ventas.Producto P ON V.ID_Producto = P.ID_Producto
GROUP BY C.ID_Cliente, C.Nombre;
GO


CREATE VIEW Analytics.vw_Tiempo_de_Entrega AS
SELECT
    E.ID_Envio,
	E.ID_Venta,
	V.Fecha_Venta,
	E.Fecha_Envio,
	E.Fecha_de_Entrega,
	DATEDIFF(day, V.Fecha_Venta, E.Fecha_Envio) AS Dias_Compra_Envio,
	DATEDIFF(day, E.Fecha_Envio, E.Fecha_de_Entrega) AS Dias_Envio_Entrega,
	E.Estado_Envio,
	CH.Nombre + ',' + CH.Apellido AS Chofer,
	CA.Patente AS Unidad_Motora
FROM Logistica.Envio E
INNER JOIN Ventas.Venta V ON E.ID_Venta = V.ID_Venta
INNER JOIN Logistica.Chofer CH ON E.ID_Chofer = CH.ID_Chofer
INNER JOIN Logistica.Camion CA ON E.ID_Camion = CA.ID_Camion;
GO
