set serveroutput ON;

drop type carta force; 
drop type carta_criatura force; 
drop type carta_hechizo force; 
drop type carta_jefe force; 
drop type lista_criaturas force;
drop type horda force;
drop type jugador force;
drop table criatura;
drop table hechizo;
drop table jefe;
drop table mazo;
drop table usuario;

/* ###################################################################################### */
/* APARTADO 1. Creación de los objetos carta, carta_criatura y carta_hechizo
/* 1.a) tipo objeto carta */
create or replace type carta as object (
    id_carta NUMBER,
    nombre varchar2(50),
    descripcion  varchar2(200),
    nivel number(2) 
    ) not final; -- NOT INSTANTIABLE (si ponemos esto, no se podrán crear instancias del objeto carta sólo, sí de sus hijos)
/
/* 1.b) tipo objeto carta_criatura HEREDADO de carta */
create or replace type carta_criatura under carta(
    fuerza number(2),
    defensa number(2),
    vida number(2)
);
/
/* 1.c) tipo objeto carta_hechizo HEREDADO de carta */
create or replace type carta_hechizo under carta (
   danio_base number(2),
   tipo varchar2(20) 
);
/
/* ###################################################################################### */
/* APARTADO 2. Creación del objeto jefe con su función.
/* tipo objeto carta_jefe HEREDADO de carta, incluye objeto  y FUNCION miembro*/
create or replace type carta_jefe under carta (
   tipo varchar2(20) ,
   hechizo carta_hechizo,
   vida number(2),
   member FUNCTION lanzar_hechizo return number
);
/
create or replace type BODY carta_jefe as
    member function lanzar_hechizo return number
    IS
        danio_total number;
        modificador number := 0.5;
    begin
     /* el daño se calcula sumando al daño base del hechizo, el nivel del hechizo x daño base del hechizo x modificador*/
     /* el modificador es 1, si el tipo de carta del jefe, coincide con el tipo de carta del hechizo, en otro caso vale 0.5 */
     /* el daño total es un número entero, si es necesario se redondea a la baja el resultado*/
     if self.tipo = self.hechizo.tipo then
        modificador := 1;
     end if; 
     danio_total := trunc(self.hechizo.danio_base + self.nivel * self.hechizo.danio_base * modificador);
     -- redondear a un número entero a la baja el resultado 
     return danio_total;
     
    end lanzar_hechizo;
end;
/
/* ###################################################################################### */
/* APARTADO 3. lista de 3 objetos  carta_criatura*/

create or replace type lista_criaturas as varray(3) of carta_criatura;
/
/* ###################################################################################### */
/* creamos un tipo horda que contiene un listado de cartas, se añade constructor*/
create or replace type horda as object (
    id_horda number,
    nombre varchar2(20),
    jefe carta_jefe, -- es del tipo de objeto carta_jefe
    criaturas lista_criaturas, -- es dell tipo de objeto lista_criaturas que contiene un array de hasta 3 carta_criatura
    nivel number,
        
    constructor function horda (id_horda number, nombre varchar2, jefe carta_jefe, criaturas lista_criaturas)
        return self as result
);
/

create or replace type body horda as
    constructor function horda (id_horda number, nombre varchar2, jefe carta_jefe, criaturas lista_criaturas)
        return self as result
        IS
            v_nivel number :=0;
            
        BEGIN
            self.id_horda := id_horda;
            self.nombre:=nombre;
            self.jefe := jefe;
            self.criaturas := criaturas;
            v_nivel := self.jefe.nivel; -- inicializo con el nivel del jefe.
            
            for i IN  1..criaturas.COUNT LOOP
                    v_nivel := v_nivel + criaturas(i).nivel;  --vamos sumando el nivel de cada criatura
            end loop;
            -- iniciamos en nivel 1. por cada suma de 5 puntos de nivel de los otrso suma 1 nivel la horda
            self.nivel := 1 + trunc(v_nivel/5);
            dbms_output.put_line('el nivel de la horda es ' ||  self.nivel);
            return;
        END ;
end;
/
/* ###################################################################################### */
/* APARTADO 4. Bloque 
/* crear 3 instancias de cartas de hechizos y 6 instancias de carta_criatura. y dos instancias de tipo jefe.
/* mostrar los nombres, descripción y nivel de cada una de las cartas las cartas*/
/* crear 2 instancias de jefe, Mostrar para una de ellas los datos del jefe, su hechizo, sus criaturas y lanzr el hechizo.*/
/* 4a) Creación de instancias de objetos*/
-- este apartado es una solución propuesta de la alumna Adela
DECLARE
    hechizo1 carta_hechizo;
    hechizo2 carta_hechizo;
    hechizo3 carta_hechizo;
    criatura1 carta_criatura;
    criatura2 carta_criatura;
    criatura3 carta_criatura;
    criatura4 carta_criatura;
    criatura5 carta_criatura;
    criatura6 carta_criatura;
    jefe1 carta_jefe;
    jefe2 carta_jefe;
    lista_criaturas1 lista_criaturas;
    lista_criaturas2 lista_criaturas;
    horda1 horda;
    horda2 horda;

BEGIN
    -- Inicialización de 3 instancias tipo carta_hechizo
    hechizo1 := carta_hechizo(1, 'Bola de Fuego', 'Inflige daño de fuego a un enemigo', 1, 5, 'fuego');
    hechizo2 := carta_hechizo(2, 'Hechizo de Aire', 'Invoca un torbellino que daña a todos los enemigos', 1, 4, 'aire'); 
    hechizo3 := carta_hechizo(3, 'Flecha de Fuego', 'Inflige daño de fuego a un enemigo', 2, 4, 'fuego');

    -- Inicialización de 6 instancias tipo carta_criatura
    criatura1 := carta_criatura(101, 'Elfo de Fuego', 'Guerrero experto en la batalla', 1, 4, 1, 15);
    criatura2 := carta_criatura(102, 'Dragón Escarlata', 'Feroz depredador de las montañas', 2, 8, 2, 20);
    criatura3 := carta_criatura(103, 'Ogro de las Nieves', 'Bestia gigante que ronda por los valles helados', 3, 12, 2, 30);
    criatura4 := carta_criatura(104, 'Hombre Rata', 'Ágil ladrón que merodea por las alcantarillas', 1, 3, 3, 10);
    criatura5 := carta_criatura(105, 'Gárgola de Piedra', 'Guardián de los templos antiguos', 2, 6, 3, 15);
    criatura6 := carta_criatura(106, 'Demonio de la Oscuridad', 'Criatura infernal invocada por magos oscuros', 3, 10, 1, 30);

    -- Inicialización de 2 instancias tipo carta_jefe:
    jefe1 := carta_jefe(201, 'Jefe Dragón', 'El rey de los dragones', 3, 'fuego', hechizo1, 40);
    jefe2 := carta_jefe(202, 'Dama del aire', 'Dama del aire', 3, 'aire',  hechizo3, 35);
    
    -- Inicialización de 2 listas de tipo lista_criaturas:
    lista_criaturas1 := lista_criaturas(criatura1, criatura2, criatura3);
    lista_criaturas2 := lista_criaturas(criatura4, criatura5, criatura6);
    
    -- Inicialización de 2 instancias tipo horda:
    horda1 := horda(301, 'Dragones del Caos', jefe1, lista_criaturas1, 3);
    horda2 := horda(302, 'Tornado Final', jefe2, lista_criaturas2);
    
    
    /* 4b) Generar salidas por consola: */
    -- Criatura:
    DBMS_OUTPUT.PUT_LINE('    ######################## CARTA CRIATURA ########################    ');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------- ');
    DBMS_OUTPUT.PUT_LINE(RPAD('ID', 5) || RPAD('Nombre', 20) || 'Descripcion');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------- ');
    DBMS_OUTPUT.PUT_LINE(RPAD(criatura1.id_carta, 5) || RPAD(criatura1.nombre, 20) || criatura1.descripcion);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Hechizo:
    DBMS_OUTPUT.PUT_LINE('    ######################## CARTA HECHIZO ########################');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------- ');
    DBMS_OUTPUT.PUT_LINE(RPAD('ID', 5) || RPAD('Nombre', 20) || 'Descripcion');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------- ');
    DBMS_OUTPUT.PUT_LINE(RPAD(hechizo1.id_carta, 5) || RPAD(hechizo1.nombre,20) || hechizo1.descripcion);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Jefe
    DBMS_OUTPUT.PUT_LINE('    ######################## CARTA JEFE ######################## ');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------- ');
    DBMS_OUTPUT.PUT_LINE(RPAD('Nombre', 20) || RPAD('Descripcion', 30) || RPAD('Hechizo', 20) || 'Daño Total');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------- ');
    DBMS_OUTPUT.PUT_LINE(RPAD(jefe2.nombre, 20) || RPAD(jefe2.descripcion,30) || ' ' || RPAD(jefe2.hechizo.tipo,20) || ' ' || jefe2.lanzar_hechizo());
    DBMS_OUTPUT.PUT_LINE('');
    
    
    -- Horda:
    DBMS_OUTPUT.PUT_LINE(' ################# CARTA HORDA ################ ');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD('Nombre', 30) || RPAD('Nivel de la Horda', 20));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD(horda1.nombre, 30)|| RPAD(horda1.nivel,20));
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('            ~~ JEFE DE LA HORDA ~~         ' );
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD('Nombre', 20) || RPAD('Nivel', 15) || 'Vida');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD(horda1.jefe.nombre, 20)|| RPAD(horda1.jefe.nivel, 15) || horda1.jefe.vida);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('           ~~ CRIATURAS DE LA HORDA ~~               ' );
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD('Nombre', 25) || RPAD('Nivel', 10) || RPAD('Fuerza', 10) || RPAD('Defensa', 10) || RPAD('Vida', 10));
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
    -- Recorrer criaturas con la lista de una de los objetos horda:
    for i IN (SELECT * from TABLE(lista_criaturas1)) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(i.nombre, 25) || RPAD(i.nivel, 10) || RPAD(i.fuerza, 10) || RPAD(i.defensa, 10) || RPAD(i.vida, 10));
    END LOOP;

END;
/

/*
    --Creacion Cursor Horda
    CURSOR cCriaturasHorda 
    IS SELECT h.nombre, h.nivel,h.fuerza,h.defensa,h.vida
    FROM TABLE(horda2.criaturas) h;
    
    OPEN cCriaturasHorda;
    LOOP
        FETCH cCriaturasHorda INTO vCriaturaNombre,vCriaturaNivel,vCriaturaFuerza,vCriaturaDefensa,vCriaturaVida;
    EXIT WHEN cCriaturasHorda%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || vCriaturaNombre ||' -- ' || ' Nivel: ' || vCriaturaNivel ||' -- ' || ' Fuerza: ' ||vCriaturaFuerza ||' -- ' || ' Defensa: ' ||vCriaturaDefensa ||' -- ' || ' Vida: ' ||vCriaturaVida);
    END LOOP;
    

*/
/* ###################################################################################### */
/* APARTADO 5. objeto REF y tablas 
/* 
/* creamos un tipo de objeto que hace REF a otro tipo de objeto.*/
create or replace type jugador as object (
    id_jugador number,
    nombre_jugador varchar2(20),
    partidas_jugadas number,
    partidas_ganadas number,
    horda_jugador REF horda
);
/
/* ###################################################################################### */
/* creación de tablas de tipo objeto*/
/*create table criatura of carta_criatura;
anteriormente hemos creado objetos pero su ciclo de vida acaba cuando finaliza el bloque en el que los hemos definido. Vamos a crear una serie de tablas para almacenar los objetos y así quedar los datos
de forma permanente.
*/
create table criatura of carta_criatura;
create table hechizo of carta_hechizo;
create table jefe of carta_jefe;
create table mazo of horda;
create table usuario of jugador;

/
/* puedes reutilizar el código anterior para insertar en las tablas mazo las dos hordas creadas anteriormente.
además de generar dos usuarios e insertalos en la tabla jugador.
/* ###################################################################################### */
/*Actividad 6.*/

/*6. a) Crea seis instancias de carta_criatura y después debes insertarlos en la tabla CRIATURA. (Puedes usar los datos del apartado 4.a) para las criaturas)*/
DECLARE
    criatura1 carta_criatura;
    criatura2 carta_criatura;
    criatura3 carta_criatura;
    criatura4 carta_criatura;
    criatura5 carta_criatura;
    criatura6 carta_criatura;
BEGIN 
    criatura1:=NEW carta_criatura('101', 'Elfo de Fuego', 'Guerrero experto en la batalla', '1', '4', '1', '15');
    criatura2:=NEW carta_criatura('102', 'Dragón Escarlata', 'Feroz depredador de las montañas', '2', '8', '2', '20');
    criatura3:=NEW carta_criatura('103', 'Ogro de las Nieves', 'Bestia gigante que ronda por los valles helados', '3', '12', '2', '30');
    criatura4:=NEW carta_criatura('104', 'Hombre Rata', 'Ágil ladrón que merodea por las alcantarillas', '1', '3', '3', '10');
    criatura5:=NEW carta_criatura('105', 'Gárgola de Piedra', 'Guardián de los templos antiguos', '2', '6', '3', '15');
    criatura6:=NEW carta_criatura('106', 'Demonio de la Oscuridad', 'Criatura infernal invocada por magos oscuros', '3', '10', '1', '30');
    
    INSERT INTO CRIATURA VALUES(criatura1);
    INSERT INTO CRIATURA VALUES(criatura2);
    INSERT INTO CRIATURA VALUES(criatura3);
    INSERT INTO CRIATURA VALUES(criatura4);
    INSERT INTO CRIATURA VALUES(criatura5);
    INSERT INTO CRIATURA VALUES(criatura6);
END;
/
/* 6. b) Crea tres instancias de carta_hechizo y después debes insertarlos en la tabla HECHIZO. (Puedes usar los datos del apartado 4.a) para los hechizos)*/
DECLARE
    hechizo1 carta_hechizo;
    hechizo2 carta_hechizo;
    hechizo3 carta_hechizo;
BEGIN
    hechizo1:=NEW carta_hechizo('1', 'Bola de Fuego', 'Inflige daño de fuego a un enemigo', '1', '5', 'fuego');
    hechizo2:=NEW carta_hechizo('2', 'Hechizo de Aire', 'Invoca un torbellino que daña a todos los enemigos', '1', '4', 'aire');
    hechizo3:=NEW carta_hechizo('3', 'Flecha de Fuego', 'Inflige daño de fuego a un enemigo', '2', '4', 'fuego');
    
    INSERT INTO HECHIZO VALUES(hechizo1);
    INSERT INTO HECHIZO VALUES(hechizo2);
    INSERT INTO HECHIZO VALUES(hechizo3);
END;
/
/*6. c) Crea dos instancias de carta_jefe y después debes insertarlos en la tabla JEFE. (Puedes usar los datos del apartado 4.a) para los Jefes,
IMPORTANTE: El hechizo de cada jefe debe ser obtenido a través de una consulta (SELECT) a la tabla "HECHIZO" por el nombre del hechizo, que será 'Bola de Fuego'
y 'Hechizo de Aire' respectivamente,no creando directamente objetos carta_hechizo.*/
DECLARE    
    vH1 carta_hechizo;
    vH2 carta_hechizo;
BEGIN
    SELECT VALUE(H) INTO vH1 FROM HECHIZO H WHERE nombre='Bola de Fuego';    
    SELECT VALUE(H) INTO vH2 FROM HECHIZO H WHERE nombre='Hechizo de Aire';
    
    INSERT INTO JEFE VALUES('201', 'Jefe Dragón', 'El rey de los dragones', '3', 'fuego', vH1, '40');
    INSERT INTO JEFE VALUES('202', 'Dama del aire', 'Dama del aire', '3', 'aire', vH2, '35');
END;
/

/*6. d) Crea una instancia de horda y después debes insertarlo en la la tabla MAZO (Puedes usar los datos del apartado 4.a) para la horda
IMPORTANTE: Las criaturas para generar la lista de criaturas de la horda deben ser generadas y obtenidas a través de varias consultas a la tabla "CRIATURA"
El jefe de la horda debe ser obtenido de la tabla "JEFE" a través del nombre del jefe "Jefe Dragón".*/
DECLARE
    vCriarura1 carta_criatura;
    vCriarura2 carta_criatura;
    vCriarura3 carta_criatura;  
    vLista lista_criaturas;
    vJefe carta_jefe;
    vHorda horda;
BEGIN
    SELECT VALUE(C) INTO vCriarura1 FROM CRIATURA C WHERE id_carta='101'; 
    SELECT VALUE(C) INTO vCriarura2 FROM CRIATURA C WHERE id_carta='102';
    SELECT VALUE(C) INTO vCriarura3 FROM CRIATURA C WHERE id_carta='103';
    vLista:= NEW lista_criaturas(vCriarura1,vCriarura2,vCriarura3);    
    SELECT VALUE(J) INTO vJefe FROM JEFE J WHERE nombre='Jefe Dragón';
    
    vHorda:= NEW horda('302', 'Tornado Final', vJefe, vLista);
    INSERT INTO MAZO VALUES(vHorda);
END;
/
/*6. e) Insertar en la tabla USUARIO a un jugador, con la horda incluida en la tabla de MAZO.
NOTA: se incluye en la tabla una referencia a un objeto de tipo horda*/
DECLARE    
    rHorda1 REF horda;
BEGIN
    SELECT REF(M) INTO rHorda1 FROM MAZO M WHERE M.nombre='Tornado Final' and ROWNUM=1;   
    INSERT INTO USUARIO VALUES('1001','miusuario','35','29',rHorda1);
END;
/

/*6.f ) Aumenta el valor del nivel del hechizo de uno de los jefes incluidos en la tabla JEFE mediante una sentencia SQL y muestra el nuevo nivel por consola.*/
DECLARE
    vNivel NUMBER;    
    vNombre VARCHAR2(20);
BEGIN
    SELECT nombre,J.hechizo.nivel INTO vNombre, vNivel from JEFE J WHERE nombre='Jefe Dragón';
    DBMS_OUTPUT.PUT_LINE('El nivel de '|| vNombre ||' ANTES del update es : '|| vNivel ||'.');
    UPDATE JEFE J
        SET J.hechizo.nivel=vNivel+1
        WHERE nombre=vNombre;
    SELECT nombre,J.hechizo.nivel INTO vNombre, vNivel from JEFE J WHERE nombre=vNombre;
    DBMS_OUTPUT.PUT_LINE('El nivel de '|| vNombre ||' DESPUES del update es : '|| vNivel ||'.');    
END;
/
