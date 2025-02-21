

DROP DATABASE IF EXISTS FYT_AGRANEL;
CREATE DATABASE FYT;
USE FYT;

CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    unidad_medida VARCHAR(50) NOT NULL,
    costo_unitario DECIMAL(10,2) NOT NULL,  -- Precio del proveedor
    precio_venta DECIMAL(10,2) GENERATED ALWAYS AS (costo_unitario * 1.30) STORED,  -- 30% de ganancia automático
    stock_disponible DECIMAL(10,2) NOT NULL DEFAULT 0,
    fecha_actualizacion DATE NOT NULL
);
CREATE TABLE Compras (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    fecha_compra DATE NOT NULL,
    numero_remito VARCHAR(50) NOT NULL
);
CREATE TABLE Detalle_Compras (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    nombre_proveedor VARCHAR(255) NOT NULL, -- Nombre como viene en el remito
    id_producto INT, -- Se completa automáticamente con la tabla de equivalencias
    cantidad DECIMAL(10,2) NOT NULL,
    costo_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_compra) REFERENCES Compras(id_compra),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Equivalencias (
    id_equivalencia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_proveedor VARCHAR(255) NOT NULL,
    id_producto INT NOT NULL,
    unidad_proveedor VARCHAR(50),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    total_venta DECIMAL(10,2) DEFAULT 0 -- Se actualizará automáticamente con un trigger
);
CREATE TABLE Detalle_Ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

DELIMITER //

CREATE TRIGGER before_insert_detalle_compras
BEFORE INSERT ON Detalle_Compras
FOR EACH ROW
BEGIN
    DECLARE producto_id INT;
    DECLARE cantidad_nueva DECIMAL(10,2);
    
    -- Buscar el ID del producto correcto en la tabla de equivalencias
    SELECT id_producto INTO producto_id 
    FROM Equivalencias 
    WHERE nombre_proveedor = NEW.nombre_proveedor 
    LIMIT 1;

    -- Extraer la cantidad desde la descripción del proveedor (último número antes de "KG" o "L")
    SET cantidad_nueva = CAST(SUBSTRING_INDEX(NEW.nombre_proveedor, ' ', -2) AS DECIMAL(10,2));

    -- Asignar los valores correctos a la compra
    SET NEW.id_producto = producto_id;
    SET NEW.cantidad = cantidad_nueva;
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_insert_detalle_ventas
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Productos 
    SET stock_disponible = stock_disponible - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;
//

DELIMITER ;




CREATE OR REPLACE VIEW Vista_Costos_Historicos AS
SELECT dc.id_producto, p.nombre, c.fecha_compra, dc.costo_unitario, c.numero_remito
FROM Detalle_Compras dc
JOIN Compras c ON dc.id_compra = c.id_compra
JOIN Productos p ON dc.id_producto = p.id_producto;

CREATE OR REPLACE VIEW Vista_Ventas AS
SELECT v.id_venta, v.fecha_venta, SUM(dv.subtotal) AS total_venta_calculado
FROM Ventas v
JOIN Detalle_Ventas dv ON v.id_venta = dv.id_venta
GROUP BY v.id_venta, v.fecha_venta;


INSERT INTO Productos (nombre, unidad_medida, costo_unitario, fecha_actualizacion) VALUES 
('Nuez mariposa extra light', 'Kg', 17200, CURDATE());

INSERT INTO Productos (nombre, unidad_medida, costo_unitario, fecha_actualizacion) VALUES 
('Mix tropical', 'Kg', 17200, CURDATE()),
('Mix sin pasas y sin mani', 'Kg', 17200, CURDATE());

INSERT INTO Productos (nombre, unidad_medida, costo_unitario, fecha_actualizacion) VALUES 
('Nuez mariposa extra light', 'Kg', 17200, CURDATE()),
('Mix tropical', 'Kg', 17200, CURDATE()),
('Mix sin pasas y sin mani', 'Kg', 17200, CURDATE()),
('Nuez mariposa partida', 'Kg', 16923.08, CURDATE()),
('Almendra non pareill', 'Kg', 17715.38, CURDATE()),
('Castañas de caju w4', 'Kg', 11692.31, CURDATE()),
('Mani Tostado sin sal', 'Kg', 2315.38, CURDATE()),
('Mani Tostado con sal', 'Kg', 2315.38, CURDATE()),
('Mani con cascara', 'Kg', 2515.38, CURDATE()),
('Mix de arandanos', 'Kg', 7153.85, CURDATE()),
('Mix cervecero', 'Kg', 4769.23, CURDATE()),
('Mix de frutos secos con pasas y sin mani', 'Kg', 8269.23, CURDATE()),
('Pasas de uvas', 'Kg', 3307.69, CURDATE()),
('Pasas de arandanos', 'Kg', 10000.00, CURDATE()),
('Ciruela D Agen descarozada', 'Kg', 3692.31, CURDATE()),
('Higos tiernizados', 'Kg', 4923.08, CURDATE()),
('Frutas escurridas', 'Kg', 2000.00, CURDATE()),
('Bananitas en chips', 'Kg', 7307.69, CURDATE()),
('Anillos de avena y miel', 'Kg', 3569.23, CURDATE()),
('Anillos frutales', 'Kg', 3830.77, CURDATE()),
('Copos sin azucar', 'Kg', 3707.69, CURDATE()),
('Ositos de avena y miel', 'Kg', 3753.85, CURDATE()),
('Almohaditas de frutillas', 'Kg', 4246.15, CURDATE()),
('Almohaditas de limon', 'Kg', 4246.15, CURDATE()),
('Almohaditas de avellana', 'Kg', 4246.15, CURDATE()),
('Almohaditas de chocolate', 'Kg', 5230.77, CURDATE()),
('Tutuca con edulcorante', 'Kg', 4046.15, CURDATE()),
('Granola crocante sin pasas economica', 'Kg', 3084.62, CURDATE()),
('Granola crocante sin pasas premium', 'Kg', 4946.15, CURDATE()),
('Garbanzos', 'Kg', 1284.62, CURDATE()),
('Poroto Negros', 'Kg', 1584.62, CURDATE()),
('Porotos Pallares', 'Kg', 4030.77, CURDATE()),
('Arroz yamani integral', 'Kg', 1538.46, CURDATE()),
('Chia', 'Kg', 2830.77, CURDATE()),
('Girasol', 'Kg', 2092.31, CURDATE()),
('Lino', 'Kg', 1092.31, CURDATE()),
('Quinoa Peruana', 'Kg', 5030.77, CURDATE()),
('Maiz pisingallo', 'Kg', 961.54, CURDATE()),
('Avena gruesa', 'Kg', 1569.23, CURDATE()),
('Avena instantanea', 'Kg', 1446.15, CURDATE()),
('Salvado de avena', 'Kg', 1576.92, CURDATE()),
('Soja texturizada', 'Kg', 1538.46, CURDATE()),
('Fecula de mandioca', 'Kg', 1753.85, CURDATE()),
('Harina de almendras', 'Kg', 2861.54, CURDATE()),
('Harina de arroz', 'Kg', 1369.23, CURDATE()),
('Harina de avena', 'Kg', 1353.85, CURDATE()),
('Harina de trigo integral organica', 'Kg', 1230.77, CURDATE()),
('Yerba Tucangua', 'Kg', 2923.08, CURDATE()),
('Cacao amargo calidad extra', 'Kg', 8423.08, CURDATE()),
('Azucar mascabo', 'Kg', 2038.46, CURDATE()),
('Sal Marina Macrozen (fina) 500g', 'UNIDAD', 1476.92, CURDATE()),
('Aceite de oliva extra virgen 500cc', 'UNIDAD', 10169.23, CURDATE()),
('Aceite de coco neutro 200cc', 'UNIDAD', 3600.00, CURDATE()),
('Aceite de coco virgen 360cc', 'UNIDAD', 7953.85, CURDATE()),
('Leche de almendras 1L', 'UNIDAD', 2853.85, CURDATE()),
('Maca negra peruana 150g', 'UNIDAD', 1038.46, CURDATE()),
('Miel Pura 1kg', 'UNIDAD', 4230.77, CURDATE()),
('Pimienta negra molida', 'Kg', 10461.54, CURDATE()),
('Pasta de mani Oddis 350g', 'UNIDAD', 2061.54, CURDATE());


INSERT INTO Equivalencias (nombre_proveedor, id_producto, unidad_proveedor) VALUES
('NUEZ MARIPOSA EXTRA LIGHT POR 2.5 KG', 1, '2.5 Kg'),
('MIX TROPICAL 5 KG', 2, '5 Kg'),
('MIX SIN PASAS Y SIN MANI 5 KG', 3, '5 Kg'),
('NUEZ MARIPOSA PARTIDA POR.5 KG', 7, '2.5 Kg'),
('ALMENDRA NON PAREILL POR 2.5 KG', 8, '2.5 Kg'),
('CASTAÑAS DE CAJU W4 POR 2.5 KG', 9, '1 Kg'),
('MANI TOSTADO SIN SAL 5 KG', 10, '1 Kg'),
('MANI TOSTADO CON SAL 5 KG', 11,'1 Kg'),
('MANI CON CASCARA 5 KG', 12 , '5 Kg'),
('MIX DE ARANDANOS 5 KG', 13, '1 Kg'),
('MIX CERVECERO 1 KG', 14, '1 Kg'),
('MIX FRUTOS SECOS PASAS SIN MANI 5 KG', 15, '5 Kg'),
('PASAS DE UVAS 10 KG', 16, '1 Kg'),
('PASAS DE ARANDANOS 1 KG', 17, '1 Kg'),
('CIRUELA D AGEN DESCAROZADA 5 KG', 18, '5 Kg'),
('HIGOS TIERNIZADOS 2.5 KG', 19, '5 Kg'),
('FRUTAS ESCURRIDAS 5 KG', 20, '5 Kg'),
('BANANITAS EN CHIPS 1 KG', 21, '1 Kg'),
('LASFOR ARITOS DE MIEL x 2 kg', 22, '2 Kg'),
('ANILLO SABOR A FRUTA NUTRIFOOD x 2.5 Kg', 23, '1 Kg'),
('COPOS SIN AZUCAR 2.5 KG', 24, '1 Kg'),
('OSITOS DE AVENA Y MIEL NUTRIFOOD x 2.5 Kg', 22, '2.5 Kg'),
('LASFOR ALMOHADITAS DE FRUTILLA 2.5 KG', 23, '2.5 Kg'),
('LASFOR ALMOHADITAS DE LIMON 2.5 KG', 23, '2.5 Kg'),
('LASFOR ALMOHADITAS DE AVELLANA 2.5 KG', 23, '2.5 Kg'),
('LASFOR ALMOHADITAS DE CHOCOLATE 2.5 KG', 23, '2.5 Kg'),
('TUTUCA CON EDULCORANTE 3 KG', 27, '3 Kg'),
('GRANOLA CROCANTE SIN PASAS ECONOMICA 1 KG', 28, '1 Kg'),
('GRANOLA CROCANTE SIN PASAS PREMIUM 1 KG', 29, '1 Kg'),
('GARBANZOS 5 KG', 30, '5 Kg'),
('POROTOS NEGROS 5 KG', 31, '5 Kg'),
('POROTOS PALLARES 5 KG', 32, '5 Kg'),
('ARROZ YAMANI INTEGRAL 5 KG', 33, '5 Kg'),
('CHIA 5 KG', 34, '5 Kg'),
('GIRASOL 5 KG', 35, '5 Kg'),
('LINO 5 KG', 36, '5 Kg'),
('QUINOA PERUANA 5 KG', 37, '5 Kg'),
('MAIZ PISINGALLO 5 KG', 38, '5 Kg'),
('AVENA GRUESA 5 KG', 39, '5 Kg'),
('AVENA INSTANTANEA 5 KG', 40, '5 Kg'),
('SALVADO DE AVENA 5 KG', 41, '5 Kg'),
('SOJA TEXTURIZADA 5 KG', 42, '5 Kg'),
('FECULA DE MANDIOCA 1 KG', 43, '1 Kg'),
('HARINA DE ALMENDRAS 5 KG', 44, '5 Kg'),
('HARINA DE ARROZ 5 KG', 45, '5 Kg'),
('HARINA DE AVENA 5 KG', 46, '5 Kg'),
('HARINA DE TRIGO INTEGRAL ORGANICA 25 KG', 47, '25 Kg'),
('YERBA TUCANGUA 10 KG', 48, '10 Kg'),
('CACAO AMARGO CALIDAD EXTRA 1 KG', 49, '1 Kg'),
('AZUCAR MASCABO 5 KG', 50, '5 Kg'),
('SAL MARINA MACROZEN FINA 500G', 51, '500 g'),
('ACEITE DE OLIVA EXTRA VIRGEN 500CC', 52, '500 cc'),
('ACEITE DE COCO NEUTRO 200CC', 53, '200 cc'),
('ACEITE DE COCO VIRGEN 360CC', 54, '360 cc'),
('LECHE DE ALMENDRAS 1L', 55, '1 L'),
('MACA NEGRA PERUANA 150G', 56, '150 g'),
('MIEL PURA 1KG', 57, '1 Kg'),
('PIMIENTA NEGRA MOLIDA 1 KG', 58, '1 Kg'),
('PASTA DE MANI ODDIS 350G', 59, '350 g');

SELECT * FROM Equivalencias;	

INSERT INTO Compras (id_compra, fecha_compra, numero_remito) VALUES
(1, '2024-02-15', '00070664'),
(2, '2024-02-16', '00070363');

select * from compras;

INSERT INTO Detalle_Compras (id_compra, nombre_proveedor, costo_unitario) VALUES
(1, 'MIX TROPICAL 5 KG', 7035),
(1, 'MIX SIN PASAS Y SIN MANI 5 KG', 8250),
(1, 'CASTAÑAS DE CAJU W4 POR 2.5 KG', 11690),
(1, 'LASFOR ALMOHADITAS DE FRUTILLA 2.5 KG', 4245),
(1, 'LASFOR ALMOHADITAS DE LIMON 2.5 KG', 4245),
(1, 'LASFOR ALMOHADITAS DE AVELLANA 2.5 KG', 4245),
(1, 'LASFOR ALMOHADITAS DE CHOCOLATE 2.5 KG', 4240),
(1, 'ANILLO SABOR A FRUTA NUTRIFOOD X 2.5 KG', 3810),
(1, 'GRANOLA CROCANTE SIN PASAS PREMIUM 1 KG', 3086),
(1, 'TUTUCA CON EDULCORANTE 3 KG', 4040),
(2, 'GRANOLA CROCANTE SIN PASAS PREMIUM 1 KG', 3080),
(2, 'GRANOLA CROCANTE SIN PASAS ECONOMICA 1 KG', 4949),
(2, 'MIX CERVECERO 1 KG', 4630),
(2, 'MANI TOSTADO CON SAL 5 KG', 2500),
(2, 'GIRASOL 5 KG', 1040),
(2, 'AVENA GRUESA 5 KG', 1440),
(2, 'AVENA INSTANTANEA 5 KG', 1560),
(2, 'FECULA DE MANDIOCA 1 KG', 2780);

DELIMITER //
CREATE TRIGGER actualizar_total_venta
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Ventas v
    SET v.total_venta = (
        SELECT IFNULL(SUM(dv.subtotal), 0) 
        FROM Detalle_Ventas dv
        WHERE dv.id_venta = NEW.id_venta
    )
    WHERE v.id_venta = NEW.id_venta;
END;
//
DELIMITER ;
SELECT * FROM PRODUCTOS;

INSERT INTO Ventas (fecha_venta, total_venta) VALUES
('2024-12-02', NULL),
('2024-11-04', NULL),
('2024-11-27', NULL),
('2024-11-27', NULL),
('2024-12-09', NULL),
('2025-01-29', NULL),
('2025-01-29', NULL),
('2024-12-02', NULL),
('2024-12-09', NULL),
('2024-11-04', NULL),
('2024-12-09', NULL),
('2024-12-16', NULL),
('2025-01-15', NULL),
('2024-12-02', NULL),
('2024-12-23', NULL),
('2024-11-04', NULL),
('2025-01-20', NULL),
('2024-11-27', NULL),
('2024-11-27', NULL),
('2024-11-04', NULL);
select * from ventas;
INSERT INTO Detalle_Ventas (id_venta, id_producto, cantidad) VALUES
(21, 9, 0.5),
(21, 11, 1),
(21, 11, 1),
(22, 2, 0.5),
(22, 14, 0.5),
(23, 26, 1),
(23, 27, 1),
(23, 28, 1),
(23, 2, 1),
(23, 23, 1),
(24, 38, 0.5),
(24, 38, 1),
(24, 27, 0.5),
(24, 29, 0.5),
(25, 30, 1),
(26, 31, 1),
(27, 32, 1),
(28, 54, 1),
(28, 54, 1),
(28, 23, 1),
(29, 28, 1),
(29, 32, 1),
(29, 38, 1),
(29, 38, 0.5),
(30, 42, 0.5),
(30, 43, 1),
(30, 42, 1),
(30, 43, 0.5),
(31, 15, 0.5),
(31, 15, 0.5),
(31, 15, 0.5),
(32, 38, 0.5),
(33, 42, 0.5),
(34, 43, 0.5),
(35, 42, 1),
(36, 46, 1),
(36, 2, 1),
(36, 2, 1),
(37, 43, 1),
(37, 42, 1),
(38, 43, 0.5),
(39, 28, 1),
(40, 30, 1),
(40, 30, 1),
(40, 42, 1),
(40, 43, 1),
(40, 42, 1);


DELIMITER //
CREATE TRIGGER calcular_precios_detalle_ventas
BEFORE INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    -- Obtener el precio de venta del producto
    SET NEW.precio_unitario = (SELECT precio_venta FROM Productos WHERE id_producto = NEW.id_producto);
    
    -- Calcular el subtotal automáticamente
    SET NEW.subtotal = NEW.cantidad * NEW.precio_unitario;
END;
//
DELIMITER ;
UPDATE Ventas v
SET v.total_venta = (
    SELECT IFNULL(SUM(dv.subtotal), 0) 
    FROM Detalle_Ventas dv
    WHERE dv.id_venta = v.id_venta
);
SET SQL_SAFE_UPDATES = 0;
DELETE FROM detalle_ventas;
DELETE FROM ventas;

	DELIMITER //
	DROP TRIGGER IF EXISTS calcular_precios_detalle_ventas;
	CREATE TRIGGER calcular_precios_detalle_ventas
	BEFORE INSERT ON Detalle_Ventas
	FOR EACH ROW
	BEGIN
		-- Obtener el precio de venta del producto
		SET NEW.precio_unitario = (SELECT precio_venta FROM Productos WHERE id_producto = NEW.id_producto);
		
		-- Calcular el subtotal automáticamente
		SET NEW.subtotal = NEW.cantidad * NEW.precio_unitario;
	END;
	//
	DELIMITER ;
SELECT * FROM ventas;