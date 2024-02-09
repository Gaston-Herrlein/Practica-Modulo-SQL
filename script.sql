create schema if not exists ouldnetflix;
set schema 'ouldnetflix';

-- Eliminacion de tablas existentes
/*
drop table if exists director;
drop table if exists genero;
drop table if exists prestamo;
drop table if exists socio;
drop table if exists pelicula;
drop table if exists identificador;
drop table if exists direccion;
*/

--Creacion de tablas

create table if not exists identificador (
  ID smallserial primary key,
  DNI varchar(20) not null,
  NIE varchar(20),
  Pasaporte varchar(20)
);

create table if not exists direccion (
  ID smallserial,
  Codigo_Postal varchar(5) not null,
  Calle varchar(30) not null,
  Numero smallint not null,
  Piso varchar(5) default 'N/A',
  primary key (ID)
);

create table if not exists socio (
  ID smallserial primary key,
  Nombre varchar(25) not null,
  Apellidos varchar(50) not null,
  Email varchar(50) not null,
  Fecha_Nacimiento date not null,
  Telefono varchar(50) not null,
  Fecha_Matriculacion date default current_date,
  ID_Identificacion smallserial references identificador(ID),
  ID_Direccion smallserial references direccion(ID)
);

create table if not exists genero (
  ID smallserial primary key,
  Genero varchar(30) not null
);

create table if not exists director (
  ID smallserial,
  Nombre varchar(25) not null,
  Apellido varchar(25) not null,
  Nombre_Artistico varchar(15) default 'N/A',
  primary key(ID)
)

create table if not exists pelicula (
  ID smallserial primary key,
  Titulo varchar(80) not null,
  Publicacion date,
  Sinopsis text not null,
  ID_Genero smallserial,
  ID_Director smallserial
);
alter table pelicula add constraint FK_ID_Genero foreign key (ID_Genero) references genero (ID);
alter table pelicula add constraint FK_ID_Directo foreign key (ID_Director) references director (ID);

create table if not exists Copia (
  ID smallint primary key,
  ID_Pelicula smallserial,
  Is_Rented boolean default false
)

create table if not exists prestamo (
  ID smallserial primary key,
  Fecha_Prestamo date default current_date,
  Fecha_Devolucion date default null,
  ID_Copia smallserial references pelicula(ID),
  ID_Socio smallserial references socio(ID)
);

-- Llenado de tablas completandolas con los datos proporcionados en 'tmp_videoclub'

-- Direccion
insert into direccion (codigo_postal, calle, numero, piso)
select distinct tv.codigo_postal, tv.calle, cast (tv.numero as smallint), tv.ext  from tmp_videoclub tv;  
-- Identificador
insert into identificador (dni)
select distinct tv.dni from tmp_videoclub tv;
-- Genero
insert into genero (genero)
select distinct tv.genero from tmp_videoclub tv;
-- Director
insert into director (nombre, apellido)
select distinct split_part(tv.director, ' ', 1) as name, split_part(tv.director, ' ', 2) as apellido from tmp_videoclub tv;
-- Socio 
insert into socio (
  Nombre,
  Apellidos,
  Email,
  Fecha_Nacimiento,
  Telefono,
  ID_Identificate,
  ID_Direccion
)
select distinct tv.nombre, concat(tv.apellido_1, ' ', tv.apellido_2) as apellidos, tv.email, cast (tv.fecha_nacimiento as date),
tv.telefono, i.id as ID_identificacion, d.id as ID_Direccion 
from tmp_videoclub tv 
join identificador i on i.dni = tv.dni
join direccion d on d.calle = tv.calle and cast (d.numero as varchar) = tv.numero; 
-- Pelicula
insert into pelicula (titulo, sinopsis, copias, id_genero, id_director)
select tv.titulo, tv.sinopsis, count(tv.titulo) as Copias, g.id as genero_id, d.id as director_id from tmp_videoclub tv
join genero g on g.genero = tv.genero
join director d on concat(d.nombre, ' ', d.apellido) = tv.director
group by tv.titulo, TV.sinopsis, g.id, d.id;
-- Prestamo
insert into prestamo (fecha_prestamo, fecha_devolucion, id_pelicula, id_socio)
select distinct tv.fecha_alquiler, tv.fecha_devolucion, p.id as Pelicula_ID, s.id as Socio_ID from tmp_videoclub tv
join pelicula p on p.titulo = tv.titulo
join socio s on s.email = tv.email;
--SCRIPT PARA ACTUALIZAR COPIAS DE PELICULAS
update pelicula set copias = ( 
select SUM(case when prestamo.fecha_devolucion is not null then 1 else -1 end) from prestamo where pelicula.id = prestamo.id_pelicula
)
where exists(
    select 1
    from prestamo p
    where pelicula.id = p.id_pelicula
);

-- FUNCTION TRIGGER
create or replace function actualizar_copias()
returns trigger as $actualizar_copias$
begin
	update pelicula
	set copias = ( 
	select SUM(case when prestamo.fecha_devolucion is not null then 1 else -1 end) from prestamo where new.id = prestamo.id_pelicula
	)
	where exists(
    	select 1
    	from prestamo p
    	where new.id = p.id_pelicula
	);

	return new;
end
$actualizar_copias$
language plpgsql;
-- DEFINITION TRIGGER
create trigger TR_Actualizar_copias
after insert or update on prestamo
for each row
execute function actualizar_copias();

--ELIMINAR TRIGGER
--drop trigger if exists TR_Actualizar_copias on prestamo;

--PRUEBA TRIGGER nº1
insert into prestamo (id_pelicula, id_socio) values (90, 30);
select * from prestamo p where p.id_pelicula  = 90;
select * from pelicula p where p.id=90;

--PRUEBA TRIGGER nº2
update prestamo set fecha_devolucion = current_date where id > 495; 
select * from prestamo p where p.id_pelicula  = 90;
select * from pelicula p where p.id=90;

--CORROBORAR LOS VALORES DE LAS QUERYS DE ARRIBA PARA SABER SI SE DISPARA EL TRIGGER
SELECT
    p.id_pelicula,
    COUNT(p.id_pelicula) AS cantidad_total,
    SUM(CASE WHEN p.fecha_devolucion IS NOT NULL THEN 1 ELSE -1 END) AS devueltas
FROM
    prestamo p
GROUP BY
    p.id_pelicula;




--Version de Posgresql
--select version();

-- Tamaño ocupado en la DB
/*select pg_size_pretty(pg_database_size(current_database())) AS size;*/

-- Tamaño de las tablas de la DB
/* 
 SELECT 'tmp_videoclub', pg_size_pretty(pg_total_relation_size('tmp_videoclub')) AS size
 FROM information_schema.tables
 WHERE table_schema = 'ouldnetflix';
*/
