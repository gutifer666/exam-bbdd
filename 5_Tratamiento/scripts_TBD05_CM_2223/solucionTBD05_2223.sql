/* SOLUCIÓN a la Tarea 5 de BD - Curso 2022/2023
	IES Cristóbal de Monroy

	La base de datos y actividades han sido diseñadas e ideadas por P.Lluyot
*/

-- ## Actividad 1.1a
-- Inserta el centro público 'E.O.I. Alcalá de Guadaíra' (cuya denominación es Escuela Oficial de Idiomas) 
-- y con dirección en C/ Cuesta de Santa María, 14, Alcalá de Guadaíra (Sevilla). cp:41500. 
-- Su teléfono es 955622115. (No bilingüe). #1
begin;
INSERT INTO `grupos_trabajo`.`centro`
(`codigo`,`denominacion`,`nombre`,`dependencia`,`domicilio`,`localidad`,`provincia`,`cp`,`telefono`,`bilingue`)
VALUES
('41700932','Escuela Oficial de Idiomas','E.O.I. Alcalá de Guadaíra','público',
'C/ Cuesta de Santa María, 14','Alcalá de Guadaíra','Sevilla','41500','955622115','0');
commit;

-- ## Actividad 1.1b
-- Inserta el grupo de trabajo Primeros auxilios con código GT110232, en el siguiente período: del 01/10/2018 al 31/05/2019. El coordinador será el profesor con código: AE112.
-- (Código de profesor no existente --> Error FK) #0
insert into grupotrabajo
values ('GT110232', 'Primeros auxilios', '2018-10-01', '2019-05-31', 0, 'AE112');

-- ## Actividad 1.2a
-- Elimina todos los teléfonos de los profesores del centro con código 41000272 que pertenecen al departamento de Dibujo (2). 
UPDATE `grupos_trabajo`.`profesor` SET `telefono` = NULL WHERE (`cod_centro` = '41000272' and `cod_dep`='2');
-- Realizado por alumno con SQL no de forma gráfica:
UPDATE profesor p, departamento d 
SET telefono = null 
WHERE p.cod_dep = d.codigo AND cod_centro = '41000272' AND d.nombre = 'Dibujo';

-- ## Actividad 1.2b
-- actualizar el departamento del profesor Cristina Sevilla López por el departamento de Latín y Griego (16)
-- (no se puede, no existe el dep. 16 en el centro del profesor).
UPDATE `grupos_trabajo`.`profesor` SET `cod_dep` = '16' WHERE (`cod_profesor` = 'SL344');

-- ## Actividad 1.3a
-- eliminar del grupo de trabajo "Arduino en el aula" al profesor "David Ares" #1
DELETE FROM `grupos_trabajo`.`componentes_gt` WHERE (`cod_gt` = 'GT110231') and (`cod_profesor` = 'AR002');

-- ## Actividad 1.3b
-- elimina a la profesora de la localidad Moguer que aún no tiene asignado ningún centro educativo. #1
select * from profesor where localidad='Moguer'; -- (es Ana Vallejo VS827)
DELETE FROM `grupos_trabajo`.`profesor` WHERE (`cod_profesor` = 'VS827');

-- ## Actividad 2.1
-- Asocia los siguientes profesores a cada grupo de trabajo, insertando los siguientes registros en la base de datos, usando una única sentencia SQL.
-- #4
INSERT INTO `grupos_trabajo`.`componentes_gt`
(`cod_gt`,`cod_profesor`)
VALUES ('GT900122', 'CC989'),('GT663526', 'CS115'),('GT993818', 'FP664'),('GT188934', 'FT369');

-- ## Actividad 2.2
-- Actualizar el nombre del profesor "Raquel Aguirre Ballester" del centro con código 41700105, por el profesor "Ana Domínguez Navarro". #1
set sql_safe_updates=0;
UPDATE `grupos_trabajo`.`profesor` 
	SET `nombre` = 'Ana', `apellido1` = 'Domínguez', `apellido2` = 'Navarro' 
    WHERE (cod_centro= 41700105 and nombre="Raquel" and apellido1="Aguirre" and apellido2="Ballester");
set sql_safe_updates=1;

-- ## Actividad 2.3
-- Elimina (en una única sentencia SQL) a todos los profesores de cualquier centro educativo de la provincia de Córdoba que pertenecen al departamento 14 (Departamento de Tecnología) 
-- de cualquier centro  educativo, además de los profesores que tienen los teléfonos 620387725 y 645800612
-- #2
set sql_safe_updates=0;
delete from profesor
where cod_centro IN (select codigo from centro where provincia='Córdoba') and cod_dep='14'
	or telefono IN ('620387725' ,'645800612');
set sql_safe_updates=1;
-- otra forma por alumno:
DELETE p FROM profesor p, centro c
WHERE (p.cod_dep = '14' AND p.cod_centro = c.codigo AND c.provincia = 'Córdoba')
OR p.telefono IN (‘620387725’, ‘645800612’);
-- si el enunciado fuese todos los profesores de la provincia de Córdoba que pertenecen al departamento 14 #4
set sql_safe_updates=0;
select *  from profesor
where (provincia='Córdoba' and cod_dep=14) or telefono IN ('620387725' ,'645800612');
set sql_safe_updates=1;
-- otra forma quitando los paréntesis auqneu es igual, pero hay que saber que el operador AND va antes que el OR
DELETE from profesor
WHERE provincia = 'Córdoba' AND cod_dep = 14 OR telefono IN ('645800612' , '620387725'); 

-- ## Actividad 3.1
--  eliminar del grupo de trabajo GT123411 los profesores del IES Cristóbal de Monroy  #2 -->GT123411 - JF040    GT123411 - LM039
begin;
set sql_safe_updates=0;
delete from componentes_gt
where cod_profesor in (select A.cod_profesor from 
(select X.cod_profesor from profesor X, componentes_gt, centro where 
X.cod_centro=centro.codigo and
X.cod_profesor=componentes_gt.cod_profesor
and cod_gt='GT123411' and centro.nombre='Cristóbal de Monroy' order by componentes_gt.cod_gt) A)
and cod_gt='GT123411';

-- otra forma
begin;
DELETE FROM componentes_gt 
WHERE componentes_gt.cod_gt ='GT123411' 
AND componentes_gt.cod_profesor IN (SELECT profesor.cod_profesor 
									FROM profesor
									JOIN centro ON centro.codigo = profesor.cod_centro
									WHERE centro.nombre = 'Cristóbal de Monroy');
rollback;
-- otra forma muy diferente por alumno:
DELETE cgt FROM profesor p, grupotrabajo gt, componentes_gt cgt, centro c
WHERE gt.cod_gt = cgt.cod_gt AND cgt.cod_profesor = p.cod_profesor AND p.cod_centro = c.codigo
	AND c.nombre = 'Cristóbal de Monroy' AND gt.cod_gt = 'GT123411';
    
-- 3.2 inserta el departamento de Informática para aquellos centros en los que no exista dicho departamento
-- (Advertencia: Usar el nombre del departamento para obtener el código del departamento) #6
begin;
insert into dep_centro (cod_centro, cod_dep)
select centro.codigo,  departamento.codigo from centro, departamento
	where departamento.nombre='Informática' and
			centro.codigo NOT in( select cod_centro from dep_centro where dep_centro.cod_dep=departamento.codigo);
rollback; 
-- otra forma por alumno, usando RIGHT JOINS:
begin;
INSERT INTO dep_centro (cod_centro, cod_dep)
SELECT t2.codigo, t2.dcode FROM
(SELECT c.codigo, d.codigo AS dcode FROM centro c, dep_centro dc, departamento d
WHERE c.codigo = dc.cod_centro AND dc.cod_dep = d.codigo AND d.nombre IN ("Informática")
) AS t1
RIGHT JOIN
(SELECT c.codigo, d.codigo AS dcode FROM centro c, departamento d WHERE d.nombre = 'Informática') AS t2
ON t1.codigo = t2.codigo WHERE t1.codigo IS NULL;
 rollback;
 
-- 3.3 actualiza en una única sentencia la columna número de profesores de cada grupo de trabajo. #10
begin;
UPDATE grupotrabajo
SET num_profesores = 
	(SELECT COUNT(CGT.cod_profesor) 
		FROM componentes_gt CGT
        WHERE grupotrabajo.cod_gt = CGT.cod_gt);
ROLLBACK;

-- otra forma
begin;
update grupotrabajo 
,
(select GT.cod_gt, count(GT.cod_gt) 'numero' from grupotrabajo GT JOIN componentes_gt CGT ON GT.cod_gt=CGT.cod_gt
group by GT.cod_gt) X

set num_profesores=X.numero
where grupotrabajo.cod_gt=X.cod_gt;

-- UPDATE grupotrabajo g JOIN (SELECT cod_gt, COUNT(cod_profesor) AS total FROM componentes_gt GROUP BY cod_gt) c ON g.cod_gt = c.cod_gt SET g.num_profesores = c.total;
rollback;
commit;

-- 4**********************************************************
-- 4.1 INSERT + UPDATE + DELETE
/* Queremos modificar el actual coordinador del grupo de trabajo "Huerto en el centro" de forma que sea el profesor 
"Francisca Jorge Ferrández". El actual coordinador formará parte de los participantes de ese grupo de trabajo.
Debes tener en cuenta que en un grupo de trabajo siempre hay un único coordinador. 
Un coordinador de un grupo de trabajo no puede ser participante del mismo grupo de trabajo y viceversa, 
si es participante en un grupo de trabajo no puede ser el coordinador de ese grupo.*/
begin;
set sql_safe_updates=0;
-- añadimos como participante el antiguo coordinador
insert into componentes_gt 
select cod_gt, cod_coordinador from grupotrabajo where nombre="Huerto en el centro";
-- actualizamos el nuevo coordinador
update grupotrabajo set cod_coordinador=(select cod_profesor from profesor where nombre="Francisca" and apellido1="Jorge" and apellido2="Ferrández")
where nombre="Huerto en el centro";
-- eliminamos el nuevo coordinador como participante
delete from componentes_gt
where (cod_gt, cod_profesor) IN (select cod_gt, cod_coordinador from grupotrabajo where nombre="Huerto en el centro");
set sql_safe_updates=0;
rollback;
/* podríamos lanzar dos updates */
begin;
set sql_safe_updates=0;
update componentes_gt, (select cod_gt, cod_coordinador from grupotrabajo where nombre="Huerto en el centro") TEMP
	set cod_profesor=TEMP.cod_coordinador
	where componentes_gt.cod_gt=TEMP.cod_gt and cod_profesor = (select cod_profesor from profesor where nombre="Francisca" and apellido1="Jorge" and apellido2="Ferrández");
update grupotrabajo set cod_coordinador=(select cod_profesor from profesor where nombre="Francisca" and apellido1="Jorge" and apellido2="Ferrández")
where nombre="Huerto en el centro";
set sql_safe_updates=1;
rollback;

-- bloqueo de registros
begin;
LOCK TABLES grupotrabajo WRITE;
select * from grupotrabajo;
insert into grupotrabajo values ('GT999991','prueba GT', '2023-01-01', '2023-05-01', 0, NULL);
unlock tables;
rollback;
