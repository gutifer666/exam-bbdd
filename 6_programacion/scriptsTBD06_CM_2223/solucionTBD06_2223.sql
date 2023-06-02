/* ############################################ EJERCICIO 1 #####################################################
Crear un procedimiento llamado ​ actualizar_ocupacion​ de forma que tenga como parámetros de entrada:
 - identificador de una sesión
El procedimiento debe de actualizar el número de inscritos de una sesión, para ello debes realizar las siguientes acciones:
- Mostrar un mensaje por consola en el caso de que la sesión pasada por parámetros no exista en la base de datos
- En el caso de que la sesión exista, se deben contar las inscripciones realizadas por los clientes para esa sesión (sólo las que se encuentren en estado "Reservado") y actualizar en la base de datos la ocupación de la sesión. 
- Una vez actualizada la ocupación, se mostrará un mensaje por consola, indicando el nombre de la actividad a la que pertenece dicha sesión, la fecha de la sesión, el código de la sesión, la ocupación actual y la ocupación máxima de la actividad. El formato de salida debe ser similar a las imágenes que se muestran en los siguientes ejemplos de llamada al procedimiento:

Nota: La ocupación máxima de cada sesión, viene indicada en la actividad a la que pertenece dicha sesión.
################################################################################################################*/
create or replace procedure actualizar_ocupacion (vSesion sesion.id%TYPE)
as
    vNombreActividad actividad.nombre%TYPE;
    vMaxOcupacion actividad.capacidad_max%TYPE;
    vFechaSesion sesion.fecha_actividad%TYPE;
    vExiste NUMBER;
    -- declaramos variables para recoger los números de inscripciones actuales
    vNumInscritos sesion.ocupacion%TYPE;
begin
    -- comprobamos si la sesión existe en la base de datos
    Select actividad.nombre, actividad.capacidad_max, sesion.fecha_actividad
    into vNombreActividad,  vMaxOcupacion, vFechaSesion
        from sesion JOIN actividad ON sesion.id_actividad = actividad.id 
        where sesion.id=vSesion;
    
    --usamos un cursos implícito para almacenar el número de inscripciones activas (en estado reservado)
    select count(*) into vNumInscritos from inscripcion where id_sesion=vSesion and estado='Reservado';
    -- actualizamos el número actual de inscritos para la sesión actual en la tabla sesión 
    update sesion set ocupacion=vNumInscritos where id=vSesion;
    -- mostramos un mensaje indicando el nombre de la actividad, el número máximo de ocupación de la actividad que corresponde a la sesión, la fecha de la sesión y el número actual de ocupación.
    DBMS_OUTPUT.PUT_LINE('La sesión de ' || vNombreActividad || '('||vFechaSesion ||'), con código ' || vSesion || ', tiene una ocupación actual de (' || vNumInscritos ||'/' || vMaxOcupacion || ')');

exception 
    -- si no existe el identificador de la sesión se genera un error, el cual controlamos y mostramos un mensaje
    when no_data_found then
        DBMS_OUTPUT.PUT_LINE('No existe la sesión con código ' || vSesion);
    when others then
        DBMS_OUTPUT.PUT_LINE('otro');
end;
/
-- habilitamos la salida por consola.
set serveroutput ON;
-- creamos un bloque para realizar distintas pruebas
BEGIN
    actualizar_ocupacion (100);
    actualizar_ocupacion (5);
    actualizar_ocupacion (8);
    actualizar_ocupacion (1);
END;
/

/* ############################################ EJERCICIO 2 #####################################################
Crear una función llamada ​num_sesiones​, donde a partir de un identificador de una actividad y un rango de fechas, devuelva el número de sesiones existentes de dicha actividad comprendidas entre la fecha de inicio y de fin. Parámetros de entrada a la función
- id_actividad
- fecha_inicio
- fecha_fin
Hay que tener en cuenta que los parámetros fecha_inicio y fecha_fin son opcionales y que el valor por defecto de ambos es la fecha actual del sistema
Nota: La ocupación máxima de cada sesión, viene indicada en la actividad a la que pertenece dicha sesión.
################################################################################################################*/
create or replace function num_sesiones(p_id_actividad actividad.id%TYPE, p_fec_inicio DATE DEFAULT SYSDATE, p_fec_fin DATE DEFAULT SYSDATE)
RETURN NUMBER
is
    v_num NUMBER default 0;
BEGIN
    /*select count(*) into v_num from actividad JOIN sesion ON actividad.id = sesion.id_actividad 
    where actividad.id=p_id_actividad and sesion.fecha_actividad BETWEEN p_fec_inicio and p_fec_fin;
    return v_num;*/
    -- contamos cuantas sesiones existen para la actividad entre las fechas seleccionadas
    select count(*) into v_num from sesion where id_actividad = p_id_actividad and fecha_actividad BETWEEN p_fec_inicio and p_fec_fin;
    -- devolvemos el número de sesiones
    return v_num;  
END;
/
-- habilitamos la salida por consola.
set serveroutput ON;
-- creamos un bloque para realizar distintas pruebas
BEGIN
    dbms_output.put_line(num_sesiones('SPI', to_date('12/04/2023','DD/MM/YYYY'), to_date('12/05/2023','DD/MM/YYYY')));
    dbms_output.put_line(num_sesiones('YOG', to_date('12/01/2023','DD/MM/YYYY')));
    dbms_output.put_line(num_sesiones('ZZZ', to_date('12/01/2023','DD/MM/YYYY')));
END;
/

/* ############################################ EJERCICIO 3 #####################################################
Crear un procedimiento llamado ​ info_cliente​ de forma que pasándole como parámetros de entrada:
- dni de un cliente (*se pasa el dni de un cliente no el identificador del cliente)
El procedimiento debe realizar una serie de comprobaciones y mostrar por pantalla la siguiente información
- El nombre y apellidos del cliente a través del siguiente mensaje: 'El cliente "nombre apellidos" ha realizado las siguientes actividades'
- En el caso de que el cliente no exista, se debe indicar con otro mensaje a través de la consola.

Además se mostrará por pantalla un listado de las actividades que ha realizado el cliente, la fecha de las actividades y el coste de cada actividad. Para ello hay que tener en cuenta:
- Sólo se mostrarán las actividades que el cliente fue inscrito con el estado "Reservado"
- El listado aparecerá ordenado por fecha de actividad desde la más reciente a la más antigua.
- La fecha de la actividad se mostrará con el formato "día/mes/año hora:minutos"
- El coste se mostrará con el símbolo del €
- Hacer uso de las funciones LPAD y RPAD para mostrar los datos correctamente posicionados tal y como se muestran en las siguientes imágenes

Finalmente el procedimiento mostrará el coste total del cliente.
- El coste total del cliente se calcula sumando todas las actividades del cliente en estado "Reservado"
Para la resolución de esta actividad tienes que hacer uso de cursores.
################################################################################################################*/

create or replace procedure info_cliente(p_dni cliente.dni%TYPE)
is
    v_nombre cliente.nombre%TYPE;
    v_apellidos cliente.apellidos%TYPE;

    v_precio_total number(4,1) default 0;
    CURSOR c_actividades_cliente IS
         select actividad.nombre, sesion.fecha_actividad, actividad.coste
            from inscripcion JOIN sesion ON inscripcion.id_sesion=sesion.id
                JOIN actividad ON actividad.id=sesion.id_actividad
                JOIN cliente ON inscripcion.id_cliente=cliente.id
            where dni=p_dni and estado='Reservado'
            order by sesion.fecha_actividad desc;
    v_actividad c_actividades_cliente%ROWTYPE;
    
begin
    -- comprobamos si el cliente existe
    -- una forma es recuperando sus datos
    select nombre, apellidos into v_nombre, v_apellidos from cliente where dni=p_dni;
    -- si el cliente no existiera saltaría una excepción y saldríamos del procedimiento
    
    -- mostramos los datos de ese cliente. Vamos a usar un cursor para iterarlo y mostrar alguna operación
    -- abrimos el cursor
    DBMS_OUTPUT.PUT_LINE(' El cliente "'|| v_nombre || ' ' || v_apellidos|| '" ha realizado las siguientes actividades');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(RPAD('Actividad',12,' ') || RPAD('Fecha actividad',20,' ') || RPAD('Coste',8,' '));

    DBMS_OUTPUT.PUT_LINE(RPAD('-',38,'-'));
    open c_actividades_cliente;
    /* leemos la primera fila*/
    fetch c_actividades_cliente into v_actividad;
    while c_actividades_cliente%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(Rpad(v_actividad.nombre,12,' ') ||
                             Rpad(to_char(v_actividad.fecha_actividad,'DD/MM/YYYY HH24:MI'),20,' ') ||
                             Lpad(v_actividad.coste || '€',3,' ') );
        /* acumulamos el valor total */
        v_precio_total:=v_precio_total+v_actividad.coste;
        fetch c_actividades_cliente into v_actividad;
    end loop;
    DBMS_OUTPUT.PUT_LINE(RPAD('-',38,'-'));
    DBMS_OUTPUT.PUT_LINE('Total : ' || v_precio_total || '€'); -- TO_CHAR(vCoste_total, 'fmU990D00')
    /* cerramos el cursor*/
    close c_actividades_cliente;
exception
    when no_data_found then
        DBMS_OUTPUT.PUT_LINE('No existe un cliente con el dni ' || p_dni);
end;
/
set SERVEROUTPUT on;
begin
    info_cliente('50984975R');
    info_cliente('06349006V');
    info_cliente('00000000A');
end;
/
/* ############################################ EJERCICIO 4 #####################################################
Crear un trigger o disparador llamado ​ insertar_inscripcion de forma que cuando se vaya a insertar​ una inscripción de un cliente en una sesión​, antes de grabarlo se hagan una serie de acciones que se detallan a continuación:
- Comprobaremos que la inscripción que se va a insertar va a estar en estado "Reservado"
- Comprobaremos que el cliente no estaba inscrito previamente en dicha sesión o bien tenía alguna inscripción en estado "Cancelado"

Si se cumplen, se debe permitir la inscripción del cliente en la sesión, pero hay que tener en cuenta:
- Si tenía una inscripción en estado "Cancelada", se debe eliminar previamente.

Si no se cumplen ambas condiciones no se debe insertar el registro. Debes lanzar diferentes excepciones con mensajes que detallen qué condiciones incumple para no poder insertar el registro.
################################################################################################################*/
create or replace trigger insertar_inscripcion
before insert on inscripcion
for each row
declare
    v_num NUMBER;

begin
    -- si no está en estado reservada lanzamos un error
    IF :new.estado != 'Reservado' then
        raise_application_error(-20001,'La inscripción a insertar no se ha llevado a cabo ya que no está en estado Reservado');
    end if;
    -- comprobamos si previamente tiene una reserva (en estado Reservado)
    select count(*) into v_num from inscripcion where id_sesion = :new.id_sesion
        and id_cliente = :new.id_cliente and estado='Reservado';
    If v_num>0 then
        raise_application_error(-20001,'El cliente ya tenía una reserva realizada para esa actividad');
    end if;
    -- si la tenía en estado cancelada
    select count(*) into v_num from inscripcion where id_sesion = :new.id_sesion
        and id_cliente = :new.id_cliente and estado='Cancelado';
    If v_num>0 then
        -- eliminamos la reserva
        delete from inscripcion where id_cliente= :new.id_cliente and id_sesion = :new.id_sesion and estado='Cancelado';
         dbms_output.put_line('Eliminamos la reserva');
    end if;
    -- finalmente insertamos la reserva
    dbms_output.put_line('Inscripción insertada');
end;
/
/* ################# otra forma #################### */
CREATE OR REPLACE TRIGGER insertar_inscripcion BEFORE INSERT ON inscripcion
FOR EACH ROW
DECLARE
    
    vIdSesion inscripcion.id_sesion%TYPE;
    vIdInscripcion inscripcion.id%TYPE;
    vEstado inscripcion.estado%TYPE;

BEGIN
    -- si no está en estado reservada lanzamos un error
    IF :new.estado != 'Reservado' then
        raise_application_error(-20001,'La inscripción a insertar no se ha llevado a cabo ya que no está en estado Reservado');
    end if;
    
    -- almacenamos los datos de la inscripción en el caso de tener alguna 
    SELECT inscripcion.id,inscripcion.id_sesion, inscripcion.estado INTO vIdInscripcion,vIdSesion, vEstado 
    FROM inscripcion 
    WHERE inscripcion.id_cliente = :new.id_cliente AND inscripcion.id_sesion = :new.id_sesion and ROWNUM=1;
    -- si ha devuelto algún dato, comprobamos que valor tiene su estado (vEstado)
    -- si no hay registros se genera una excepción.
    IF vEstado = 'Reservado' THEN 
        RAISE_APPLICATION_ERROR(-20002,'El cliente ya tenía una reserva realizada para esa actividad');
    ELSIF vEstado = 'Cancelado' THEN
       DELETE FROM inscripcion WHERE inscripcion.id = vIdInscripcion; 
       DBMS_OUTPUT.PUT_LINE('El cliente tenía una reserva en estado Cancelado. Se elimina la reserva anterior. Inscripción realizada');
    END IF;

EXCEPTION
        -- cuando no hay datos en la select, se genera una excepcion que la controlamos aquí. Finalizamos en trigger permitiendo insertar
        -- el registro.
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Inscripción realizada');       
END;
/

--pruebas
begin
--INSERT INTO inscripcion VALUES (46, 3, 7, SYSDATE, 'Cancelado'); --La inscripción a insertar no se ha llevado a cabo ya que no está en estado Reservado
-- INSERT INTO inscripcion VALUES (47, 3, 7, SYSDATE, 'Reservado'); --Inscripción insertada
--INSERT INTO inscripcion VALUES (48, 3, 7, SYSDATE, 'Reservado'); --El cliente ya tenía una reserva realizada para esa actividad
    INSERT INTO inscripcion VALUES (249, 1, 1, SYSDATE, 'Reservado'); -- El cliente tenía una reserva en estado Cancelado. Se elimina la reserva anterior. Inscripción realizada.
--INSERT INTO inscripcion VALUES (46, 10, 7, TO_TIMESTAMP('20-05-2023 11:12:00', 'DD/MM/YYYY HH24:MI:SS'), 'Cancelado');

end;