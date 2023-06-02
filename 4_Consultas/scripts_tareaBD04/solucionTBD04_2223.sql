/* SOLUCIÓN a las consultas de la Tarea 4 de BD - Curso 2022/2023
	IES Cristóbal de Monroy

	La base de datos, y consultas han sido diseñadas e ideadas por P.Lluyot
*/
-- ###################### ACTIVIDAD 1 #######################
--  CONSULTA 1:
-- mostrar el nombre de los instrumentos de origen italiano que no son de cuerda.
Select nombre from INSTRUMENTO where origen="Italia" and tipo!="Cuerda";
SELECT nombre FROM INSTRUMENTO WHERE origen ='Italia' AND NOT tipo ='Cuerda';

--  CONSULTA 2:
-- Mostrar todos los datos de la tabla PRECIO cuya fecha de actualización está comprendida entre el 1 de diciembre del 2022 y la fecha actual.
select id_modelo_instrumento, id_tienda, precio, fecha_actualizacion from PRECIO WHERE fecha_actualizacion BETWEEN '2022-12-01' AND NOW();
SELECT * FROM PRECIO WHERE fecha_actualizacion BETWEEN '2022/12/01' AND CURDATE();

--  CONSULTA 3:
-- muestra el nombre de todas las tiendas que no están ubicadas ni en Málaga ni en Sevilla
-- y que tengan un horario de apertura de Lunes a Domingos
select nombre from TIENDA where ubicacion NOT IN ('Sevilla','Málaga')
AND horario like 'L-D%';

--  CONSULTA 4: 
-- Muestra los nombres de los músicos que comienzan por la letra A o M, y cuyo identificador de instrumento sea GTR
select nombre from MUSICO where ( nombre liKE 'A%' OR nombre LIKE 'M%' )AND id_instrumento='GTR';
-- otra forma con expr regulares:
SELECT nombre FROM MUSICO WHERE nombre REGEXP '^[AM].*' AND id_instrumento = 'GTR';
SELECT nombre FROM MUSICO WHERE nombre REGEXP '^A|^M'  AND id_instrumento = 'GTR';

-- ###################### ACTIVIDAD 2 #################### ######################### ###################### ###################### 
-- ACTIVIDAD 2: Composiciones internas
-- CONSULTA 5:
-- ¿Cuáles son los distintos nombres de instrumentos de cuerda que han sido fabricados por la marca 'Gibson'?
SELECT DISTINCT i.nombre
	FROM INSTRUMENTO i
		INNER JOIN MODELO_INSTRUMENTO im ON i.id = im.id_instrumento
		INNER JOIN MARCA m ON m.id = im.id_marca
	WHERE i.tipo = 'Cuerda'
		AND m.nombre = 'Gibson';
-- otra forma
SELECT DISTINCT INSTRUMENTO.nombre 
	FROM INSTRUMENTO, MODELO_INSTRUMENTO, MARCA 
	WHERE MARCA.nombre = 'Gibson' 
		AND MARCA.id = MODELO_INSTRUMENTO.id_marca
		AND MODELO_INSTRUMENTO.id_instrumento = INSTRUMENTO.id 
		AND INSTRUMENTO.tipo ='Cuerda';

-- CONSULTA 6: 
-- Mostrar un listado de los instrumentos que tiene disponible la tienda "Musical Store" junto al modelo de instrumento y su precio de venta, ordenados
-- alfabéticamente por el nombre de instrumento.
select I.nombre, MI.id_modelo, P.precio 
from TIENDA T 
	JOIN PRECIO P ON T.id = P.id_tienda
	JOIN MODELO_INSTRUMENTO MI ON P.id_modelo_instrumento = MI.id_modelo
	JOIN INSTRUMENTO I ON I.id=MI.id_instrumento
WHERE T.nombre='Musical Store' order by I.nombre asc;

-- CONSULTA 7:
-- Invéntate una consulta en la que se incluyan al menos las tablas "MARCA" y "TIENDA". La consulta debe filtrar algunos resultados y realizar una ordenación. A continuación elabora dicha consulta.
/* Consultas inventadas por algunos alumnos */
-- **** Alumno 1 ****: Mostrar un listado con las distintas marcas que se venden en la tienda de Sevilla ordenado alfabeticamente.
SELECT DISTINCT m.nombre 
FROM MARCA m, TIENDA t, PRECIO p, MODELO_INSTRUMENTO mi 
WHERE m.id = mi.id_marca AND p.id_modelo_instrumento = mi.id_modelo AND t.id = p.id_tienda AND t.ubicacion = 'Sevilla' 
ORDER BY m.nombre ASC;
-- **** Alumno 2 ****: Mostrar los modelos de los instrumentos, el nombre de la marca del instrumento y el precio de los instrumentos
-- mayores de 1000,00 € de la marca STRADIVARIUS y YAMAHA que tenga la tienda Musical Express, ordenado por el precio 
-- descendentemente
SELECT 
    MODELO_INSTRUMENTO.id_modelo 'modelo',
    MARCA.nombre 'marca',
    PRECIO.precio
FROM
    MARCA
        JOIN
    MODELO_INSTRUMENTO ON MODELO_INSTRUMENTO.id_marca = MARCA.id
        JOIN
    PRECIO ON PRECIO.id_modelo_instrumento = MODELO_INSTRUMENTO.id_modelo
        JOIN
    TIENDA ON PRECIO.id_tienda = TIENDA.id
WHERE
    PRECIO.precio > 1000.00
        AND MARCA.nombre IN ('Stradivarius' , 'Yamaha')
        AND TIENDA.nombre = 'Musical Express'
ORDER BY PRECIO.precio DESC; 
-- **** Alumno 3 ****: 
/* Mostrar un listado con los instrumentos junto a la marca, la tienda en la que se ofrece, el modelo y la ubicación de la tienda.
-- Necesitamos mostrar sólo los instrumentos de la marca "Kala" y que se ofrezcan en tiendas que se nombren como "Music#", ordenados
-- por la ubicación.*/
SELECT i.nombre AS "instrumento", m.nombre AS "marca", t.nombre, mi.id_modelo AS "modelo", t.ubicacion
FROM INSTRUMENTO i, MARCA m, TIENDA t, PRECIO p, MODELO_INSTRUMENTO mi
WHERE i.id = mi.id_instrumento AND mi.id_marca = m.id AND m.nombre = "Kala" AND mi.id_modelo = p.id_modelo_instrumento 
AND p.id_tienda = t.id AND t.nombre LIKE "Music%"
ORDER BY t.ubicacion;
-- **** Alumno 4 ****: 
/* Queremos saber en que ciudades y tiendas pueden comprarse pianos
de marca Stradivarius. Ordenados alfabeticamente por nombre de la tienda */
SELECT DISTINCT t.ubicacion, t.nombre
FROM TIENDA t, PRECIO p, MODELO_INSTRUMENTO mi, INSTRUMENTO i, MARCA m
WHERE i.nombre = 'Piano' AND m.nombre ='Stradivarius'
		AND mi.id_modelo = p.id_modelo_instrumento
			AND p.id_tienda = t.id
				AND mi.id_instrumento = i.id
					AND mi.id_marca = m.id
ORDER BY t.ubicacion;
-- **** Alumno 5 ****: 
-- Indica las tiendas donde se venda algún instrumento "Stradivarius" y la ubicación de dichas tiendas, ordenando el nombre de las tiendas alfabéticamente en orden inverso.
SELECT DISTINCT TIENDA.nombre, TIENDA.ubicacion
FROM TIENDA
JOIN PRECIO ON TIENDA.id = PRECIO.id_tienda
JOIN MODELO_INSTRUMENTO ON PRECIO.id_modelo_instrumento = MODELO_INSTRUMENTO.id_modelo
JOIN MARCA ON MODELO_INSTRUMENTO.id_marca = MARCA.id
WHERE MARCA.nombre= 'Stradivarius'
ORDER BY TIENDA.nombre DESC;

-- ###################### ACTIVIDAD 3 ####################### ####################### ####################### #######################
-- Composiciones externas
-- CONSULTA 8: 
-- De los distintos instrumentos existentes en la base de datos, mostrar aquellos que no son vendidos en ninguna de las tiendas
select I.nombre from INSTRUMENTO I
                LEFT JOIN MODELO_INSTRUMENTO MI ON MI.id_instrumento = I.id
                LEFT JOIN PRECIO P ON MI.id_modelo = P.id_modelo_instrumento
            where P.id_tienda is null;
-- si usáramos subselect sería:
SELECT 
    nombre
FROM
    INSTRUMENTO
WHERE
    id NOT IN (SELECT DISTINCT
            I.id
        FROM
            INSTRUMENTO I
                JOIN
            MODELO_INSTRUMENTO MI ON MI.id_instrumento = I.id
                JOIN
            PRECIO P ON MI.id_modelo = P.id_modelo_instrumento
                JOIN
            TIENDA T ON T.id = P.id_tienda)
            ;

-- Consulta 9: 
-- Mostrar un listado de los distintos músicos que tocan el piano junto al grupo al que pertenece. 
-- Si hay músicos que no pertenecen a un grupo musical, debe mostrar el texto "#solista#".
select MUSICO.nombre , IFNULL(GRUPO.nombre,'#solista#') 
	from MUSICO JOIN INSTRUMENTO ON MUSICO.id_instrumento = INSTRUMENTO.id 
			LEFT JOIN MUSICO_GRUPO ON MUSICO.id =id_musico
			LEFT JOIN GRUPO ON MUSICO_GRUPO.id_grupo = GRUPO.id
WHERE INSTRUMENTO.nombre="Piano"
ORDER BY MUSICO.nombre; -- no es necesaria la ordenación

-- Consulta 10: #2
-- Invéntate el enunciado de otra consulta de forma que se usen al menos las tablas "INSTRUMENTO" y "MARCA", 
-- y en el que se haga uso de la palabra reservada "RIGHT JOIN". La consulta debe filtrar algunos resultados 
-- y realizar una ordenación. A continuación elabora dicha consulta.

-- **** Alumno 1 ****:  Instrumentos que no tienen marcas de origen alemán.
SELECT DISTINCT i.nombre
FROM MARCA m RIGHT JOIN MODELO_INSTRUMENTO mi ON mi.id_marca=id_marca
	RIGHT JOIN INSTRUMENTO i ON i.id = mi.id_instrumento
WHERE  
m.id is null
and i.origen='Alemania'
order by i.nombre;

-- **** Alumno 2 ****:  Muestra el nombre de los instrumentos que empiecen con ‘C’ o ‘B’, debe aparecer a qué marca pertenece o si no tiene una marca 
-- registrada aparecerá ‘No tiene marca’. Los instrumentos que aparezcan serán los que su marca haya sido fundada posterior a 1910. Se ordenará por el nombre de la marca alfabéticamente. 
select distinct INSTRUMENTO.nombre 'Nombre instrumento', ifnull(MARCA.nombre, 'No tiene marca') 'Marca'
from MARCA 
right join MODELO_INSTRUMENTO on MODELO_INSTRUMENTO.id_marca = MARCA.id
right join INSTRUMENTO on INSTRUMENTO.id = MODELO_INSTRUMENTO.id_instrumento
where INSTRUMENTO.nombre like 'C%' or INSTRUMENTO.nombre like 'B%'
and MARCA.fecha_fundacion > '1910-01-01'
order by MARCA.nombre asc
;
-- ###################### ACTIVIDAD 4 ####################### ####################### ####################### #######################
-- Consulta 11:
-- cuál es el precio medio de los instrumentos de cuerda existentes en la base de datos. Mostrar el resultado redondeado a dos decimales
select Round(AVG(precio),2) 'Precio Medio' from INSTRUMENTO I JOIN MODELO_INSTRUMENTO MI ON I.id=MI.id_instrumento
JOIN PRECIO P ON P.id_modelo_instrumento = MI.id_modelo
where tipo="Cuerda";
-- se puede interpretar por cada instrumentos de cuerda
SELECT i.nombre, Round(avg(precio),2) PrecioMedio
FROM INSTRUMENTO i
	JOIN MODELO_INSTRUMENTO mi ON i.id=mi.id_instrumento
    JOIN PRECIO p ON p.id_modelo_instrumento = mi.id_modelo
WHERE i.tipo = 'Cuerda'
GROUP BY i.nombre;

-- Consulta 12: 
-- Mostrar el nombre de los instrumentos que están incluídos en más de dos estilos musicales.
select INSTRUMENTO.nombre -- , COUNT(ESTILO.nombre) 
from ESTILO JOIN ESTILO_INSTRUMENTO ON ESTILO.id=ESTILO_INSTRUMENTO.id_estilo
					JOIN INSTRUMENTO ON ESTILO_INSTRUMENTO.id_instrumento = INSTRUMENTO.id
GROUP BY INSTRUMENTO.nombre
having (COUNT(ESTILO.nombre)>2);
-- no es necesario meter la tabla estilos:
SELECT i.nombre as 'Instrumentos con +2 estilos'
	FROM INSTRUMENTO i
	INNER JOIN ESTILO_INSTRUMENTO ei ON (i.id=ei.id_instrumento)
	GROUP BY i.nombre
	HAVING COUNT(ei.id_estilo) > 2;

-- Consulta 13:
-- Invéntate el enunciado de una consulta en el que se emplee una de las siguientes funciones de agregado: "SUM" o "COUNT" 
-- y en el que se incluyan al menos dos tablas de la base de datos.

-- **** Alumno 1 ****: Muestra un listado de las tiendas que tiene productos de la marca Yamaha (En otra columna especifica la cantidad de productos que tiene en la tienda).
SELECT t.nombre, COUNT(m.nombre) Total_Prod_Yamaha
FROM TIENDA t
	JOIN PRECIO p ON p.id_tienda = t.id
    JOIN MODELO_INSTRUMENTO mi ON p.id_modelo_instrumento = mi.id_modelo
    JOIN MARCA m ON m.id = mi.id_marca
WHERE m.nombre = 'Yamaha'
GROUP BY t.nombre;
-- **** Alumno 2 ****:  Mostrar la cantidad de músicos y el nombre de cada músico del grupo The Beatles concatenado
SELECT 
    COUNT(MUSICO.id) 'numero de musicos',
    GROUP_CONCAT(MUSICO.nombre
        SEPARATOR ', ') 'componentes'
FROM
    MUSICO
        JOIN
    MUSICO_GRUPO ON MUSICO.id = MUSICO_GRUPO.id_musico
        JOIN
    GRUPO ON MUSICO_GRUPO.id_grupo = GRUPO.id
WHERE
    GRUPO.nombre = 'The Beatles'
;

-- **** Alumno 3 ****:  Mostrar la suma de los precios de los instrumentos fabribados por la marca 'GIbson'
SELECT SUM(PRECIO.PRECIO) 'Precio Total Instrumentos Marca GIBSON'
FROM PRECIO
	JOIN MODELO_INSTRUMENTO ON MODELO_INSTRUMENTO.id_modelo = PRECIO.id_modelo_instrumento
    JOIN MARCA ON MARCA.id = MODELO_INSTRUMENTO.id_marca
WHERE MARCA.nombre='Gibson';
-- **** Alumno 4 ****: 
/*Una persona quiere saber por instrumento el rango de precios y total disponibles, para
aquellos cuyo precio medio en el grupo sea inferior a 500€, mostrándolos ordenados de forma
ascendente por el número total disponible en cada conjunto de instrumentos.*/
SELECT i.nombre, COUNT(mi.id_modelo) as 'Total', MIN(p.precio) as 'Precio mínimo', MAX(p.precio) as 'Precio máximo'
FROM INSTRUMENTO i
INNER JOIN MODELO_INSTRUMENTO mi ON (i.id=mi.id_instrumento)
INNER JOIN PRECIO p ON (p.id_modelo_instrumento=mi.id_modelo)
GROUP BY i.nombre
HAVING AVG(p.precio) < 500
ORDER BY 2;
-- **** Alumno 5 ****: 
/* Cuántos grupos de música tienen al menos, a un guitarrista en su formación.*/
SELECT COUNT(DISTINCT g.id) AS 'Número de grupos' FROM GRUPO g
JOIN MUSICO_GRUPO mg ON mg.id_grupo = g.id
JOIN MUSICO mu ON mu.id = mg.id_musico
JOIN INSTRUMENTO i ON i.id = mu.id_instrumento
WHERE i.id = 'GTR';
-- **** Alumno 6 ****: Elabora una consulta en la que se muestran los distintos instrumentos y cuántas marcas tienen cada uno de ellos.
-- Muestra también aquellos que no tengan marca.
select INSTRUMENTO.nombre 'Nombre', count(distinct MARCA.nombre) 'Marcas existentes para cada instrumento'
from INSTRUMENTO 
left join MODELO_INSTRUMENTO on INSTRUMENTO.id = MODELO_INSTRUMENTO.id_instrumento
left join MARCA on MODELO_INSTRUMENTO.id_marca = MARCA.id
group by INSTRUMENTO.nombre
;
-- **** Alumno 7 ****: 
/*Averigua el número de músicos que cada banda tiene en la base de datos*/
SELECT GRUPO.nombre, COUNT(MUSICO_GRUPO.id_GRUPO) AS "numero_componentes" FROM MUSICO_GRUPO, GRUPO
WHERE GRUPO.id = MUSICO_GRUPO.id_GRUPO 
GROUP BY GRUPO.id;
-- ###################### ACTIVIDAD 5 ####################### ####################### ####################### #######################
-- subconsultas
-- Consulta 14: #2
-- Cuales son los instrumentos de la base de datos que tienen la exclusividad con una marca francesa.
-- (Es decir, qué instrumentos, cuyos modelos sólo son distribuidos por marcas ubicadas en Francia, pero no son distribuidos por otras marcas ubicadas en otros lugares)
select distinct I.nombre from 
	INSTRUMENTO I JOIN MODELO_INSTRUMENTO MI ON I.id = MI.id_instrumento
				JOIN MARCA M ON MI.id_marca = M.id
where ubicacion='Francia'
and I.nombre NOT IN (
	select distinct I.nombre from 
	INSTRUMENTO I JOIN MODELO_INSTRUMENTO MI 
	ON I.id = MI.id_instrumento
	JOIN MARCA M 
	ON MI.id_marca = M.id
	where ubicacion!='Francia');

-- Consulta 15*:
-- Queremos mostrar un listado donde aparezca junto a cada modelo de instrumento existente en la base de datos, 
-- cual es el nombre de la tienda que ofrece el precio más bajo, y su precio.
-- *Ayuda: Puedes realizar una subconsulta para obtener el precio mínimo de cada modelo de instrumento.

SELECT P.id_modelo_instrumento, T.nombre, P.precio from TIENDA T
JOIN PRECIO P ON T.id = P.id_tienda
where (P.precio, P.id_modelo_instrumento) IN (select MIN(P.precio), P.id_modelo_instrumento from PRECIO P
group BY P.id_modelo_instrumento);
-- otra forma por **** Alumno1 ****:
SELECT 
    mi.id_modelo AS modelo,
    t.nombre AS tienda,
    p.precio
FROM
    MODELO_INSTRUMENTO mi
		JOIN
    INSTRUMENTO i ON mi.id_instrumento = i.id
        JOIN
    MARCA m ON mi.id_marca = m.id
		JOIN
    PRECIO p ON mi.id_modelo = p.id_modelo_instrumento
         JOIN
    TIENDA t ON p.id_tienda = t.id
WHERE
    p.precio = (SELECT 
            MIN(p2.precio)
        FROM
            PRECIO p2
        WHERE
            p2.id_modelo_instrumento = mi.id_modelo)
ORDER BY mi.id_modelo;
-- otra forma por **** Alumno2 ****:
SELECT pm.modelo, pm.minimo, t.nombre as 'tienda'
FROM (SELECT p.id_modelo_instrumento as 'modelo', MIN(p.precio) as 'minimo'
FROM PRECIO p
GROUP BY p.id_modelo_instrumento) pm
INNER JOIN PRECIO p ON (pm.modelo=p.id_modelo_instrumento AND pm.minimo=p.precio)
INNER JOIN TIENDA t ON (t.id=p.id_tienda);

-- Consulta 16:
-- Invéntate el enunciado de una consulta en el que se emplee la tabla "TIENDA" y haga uso de subconsultas a otras tablas. 
-- A continuación elabora dicha consulta.

-- **** Alumno 1 ****: 
-- Muestra un listado con el nombre del músico y el instrumento que toca. Este instrumento debe ser de origen chino.
SELECT m.nombre, i.nombre
FROM MUSICO m
	JOIN INSTRUMENTO i ON i.id = m.id_instrumento
WHERE i.nombre IN(SELECT i.nombre
FROM INSTRUMENTO i
WHERE origen = 'China');

-- **** Alumno 2 ****: Mostrar el nombre, ubicación y horario de todas las tiendas que venden instrumentos de Viento con un precio inferior a 100 euros.
SELECT nombre, ubicacion, horario 
FROM TIENDA 
WHERE id IN (SELECT id_tienda 
             FROM PRECIO 
             WHERE id_modelo_instrumento IN (SELECT id_modelo 
                                             FROM MODELO_INSTRUMENTO 
                                             WHERE id_instrumento IN (SELECT id 
                                                                      FROM INSTRUMENTO 
                                                                      WHERE tipo = 'Viento')) 
             AND precio < 100);
             
-- **** Alumno 3 ****:              
-- Mostar una lista con el producto más caro de cada TIENDA. En la lista debe aparecer el nombre de la TIENDA, la ubicacion, el MODELO del INSTRUMENTO y el PRECIO,
-- ordenada por PRECIO del más barato al más caro:

SELECT 
    T.nombre,
    T.ubicacion,
    P.id_MODELO_INSTRUMENTO 'INSTRUMENTO más caro de la TIENDA',
    P.PRECIO
FROM
    PRECIO P,
    TIENDA T
WHERE
    P.id_TIENDA = T.id
        AND P.PRECIO = (SELECT 
            MAX(P2.PRECIO)
        FROM
            PRECIO P2
        WHERE
            P2.id_TIENDA = T.id)
ORDER BY P.PRECIO;

-- **** Alumno 4 ****: 
-- Indica el nombre de la tienda que actualizo mas recientemente un articulo.
SELECT 
    TIENDA.nombre
FROM
    TIENDA
WHERE
    id = (SELECT 
            id_tienda
        FROM
            PRECIO
        ORDER BY fecha_actualizacion DESC
        LIMIT 1); 