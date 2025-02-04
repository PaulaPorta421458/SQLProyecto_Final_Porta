USE FYT_AGRANEL; 

    
INSERT INTO productos (id_producto, nombre, descripcion, precio_unitario, unidad_medida, stock_disponible, id_categoria)
VALUES
    (1, 'Nueces', NULL, 6735.00, 'Kg', 10, 10),
    (2, 'Almendras', NULL, 11565.00, 'Kg', 10, 10),
    (3, 'Almohaditas de Limón', NULL, 1380.00, 'Kg', 10, 12),
    (4, 'Almohaditas de Frutilla', NULL, 6790.00, 'Kg', 10, 12),
    (5, 'Almohaditas de Chocolate', NULL, 3395.00, 'Kg', 10, 12),
    (6, 'Almohaditas de Avellanas', NULL, 2760.00, 'Kg', 10, 12),
    (7, 'Aceite de oliva 500cc.', NULL, 12390.00, 'Unidades', 10, 13),
    (8, 'Chia', NULL, 2075.00, 'Kg', 10, 14),
    (9, 'Harina de almendras', NULL, 3800.00, 'Kg', 10, 15),
    (10, 'Pasas de uva', NULL, 2610.00, 'Kg', 10, 16),
    (11, 'Mix con pasas y mani', NULL, 3615.00, 'Kg', 10, 17),
    (12, 'Mix con pasas sin mani', NULL, 7890.00, 'Kg', 10, 17),
    (13, 'Mix con arandanos', NULL, 2310.00, 'Kg', 10, 17),
    (14, 'Avena', NULL, 930.00, 'Kg', 10, 15),
    (15, 'Quinoa peruana', NULL, 3230.00, 'Kg', 10, 14),
    (16, 'Granola crocante sin pasas (eco)', NULL, 3760.00, 'Kg', 10, 18),
    (17, 'Ciruelas descarozadas', NULL, 1252.00, 'Kg', 10, 16),
    (18, 'Maní sin sal', NULL, 4007.25, 'Kg', 10, 10),
    (19, 'Mix cervecero', NULL, 6000.00, 'Kg', 10, 17);
    
    INSERT INTO clientes (nombre, apellido, direccion, telefono, ciudad)
VALUES
    ('Roxi', 'Barreiro', 'Los nogales 2025', '3533452959', 'Cordoba'),
    ('Franco', 'Colapinto', 'Juan B Justo 4800', '3533452959', 'Cordoba'),
    ('Julia', 'Oviedo', 'Ovidio Lagos 325', '3533452959', 'Cordoba');
    
ALTER TABLE ventas MODIFY COLUMN Total_Venta DECIMAL(10,2) NULL;

select * from ventas;
ALTER TABLE detalle_ventas MODIFY COLUMN subtotal DECIMAL(10,2) NULL;

INSERT INTO ventas (id_venta, fecha, id_cliente, total_venta)
VALUES
    (1, '2024-07-01', 1, NULL),
    (2, '2024-07-05', 1, NULL),
    (3, '2024-07-06', 1, NULL);
    
    INSERT INTO detalle_ventas (id_detalle, id_venta, id_producto, cantidad, subtotal)
VALUES
    (1, 1, 11, 1.3, NULL),
    (2, 1, 12, 0.7, NULL),
    (3, 1, 14, 1, NULL),
    (4, 1, 2, 0.5, NULL),
    (5, 1, 13, 0.5, NULL),
    (6, 1, 15, 0.5, NULL),
    (7, 1, 16, 1, NULL),
    (8, 1, 1, 1, NULL),
    (9, 1, 17, 1, NULL),
    (10, 1, 18, 1, NULL),
    (11, 1, 19, 1, NULL);

INSERT INTO Precios_semanales (id_precio, id_producto, precio, fecha_inicio, fecha_fin)
VALUES
    (15, 1, 6735.00, '2024-07-01', '2024-07-10'),
    (20, 2, 11565.00, '2024-07-01', '2024-07-10'),
    (25, 3, 1380.00, '2024-07-01', '2024-07-10'),
    (30, 4, 6790.00, '2024-07-01', '2024-07-10'),
    (35, 5, 3395.00, '2024-07-01', '2024-07-10'),
    (40, 6, 2760.00, '2024-07-01', '2024-07-10'),
    (45, 7, 12390.00, '2024-07-01', '2024-07-10'),
    (50, 8, 2075.00, '2024-07-01', '2024-07-10'),
    (55, 9, 3800.00, '2024-07-01', '2024-07-10'),
    (60, 10, 2610.00, '2024-07-01', '2024-07-10'),
    (65, 11, 3615.00, '2024-07-01', '2024-07-10'),
    (70, 12, 7890.00, '2024-07-01', '2024-07-10'),
    (75, 13, 2310.00, '2024-07-01', '2024-07-10'),
    (80, 14, 930.00, '2024-07-01', '2024-07-10'),
    (85, 15, 3230.00, '2024-07-01', '2024-07-10'),
    (90, 16, 3760.00, '2024-07-01', '2024-07-10'),
    (95, 17, 1252.00, '2024-07-01', '2024-07-10'),
    (100, 18, 4007.25, '2024-07-01', '2024-07-10'),
    (105, 19, 6000.00, '2024-07-01', '2024-07-10');

CREATE OR REPLACE VIEW vista_total_ventas AS
SELECT 
    v.id_venta,
    v.fecha,
    v.id_cliente,
    COALESCE(SUM(dv.cantidad * p.precio), 0) AS total_venta
FROM ventas v
LEFT JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
LEFT JOIN precios_semanales p ON dv.id_producto = p.id_producto
WHERE p.fecha_inicio <= v.fecha AND p.fecha_fin >= v.fecha
GROUP BY v.id_venta, v.fecha, v.id_cliente;

SELECT * FROM vista_total_ventas;

CREATE OR REPLACE VIEW vista_ventas_con_clientes AS
SELECT 
    v.id_venta,
    v.fecha,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.apellido AS apellido_cliente,
    COALESCE(SUM(dv.cantidad * p.precio), 0) AS total_venta
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
LEFT JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
LEFT JOIN precios_semanales p ON dv.id_producto = p.id_producto
WHERE p.fecha_inicio <= v.fecha AND p.fecha_fin >= v.fecha
GROUP BY v.id_venta, v.fecha, c.id_cliente, c.nombre, c.apellido;

SELECT * FROM vista_ventas_con_clientes;

DELIMITER //

CREATE FUNCTION calcular_total_venta(idVenta INT) 
RETURNS DECIMAL(10,2) 
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT COALESCE(SUM(dv.cantidad * p.precio), 0) 
    INTO total
    FROM detalle_ventas dv
    JOIN precios_semanales p ON dv.id_producto = p.id_producto
    JOIN ventas v ON dv.id_venta = v.id_venta
    WHERE dv.id_venta = idVenta
    AND p.fecha_inicio <= v.fecha 
    AND p.fecha_final >= v.fecha;

    RETURN total;
END //

DELIMITER ;

SELECT calcular_total_venta(1) AS total_venta;

UPDATE ventas 
SET total_venta = calcular_total_venta(id_venta);



