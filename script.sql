--create schema if not exists ouldnetflix;
--set schema 'ouldnetflix';

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
  DNI varchar(20),
  Pasaporte varchar(20)
);

create table if not exists direccion (
  ID smallserial,
  Codigo_Postal varchar(5),
  Calle varchar(30) not null,
  Numero smallint not null,
  Piso varchar(5),
  primary key (ID)
);

create table if not exists socio (
  ID smallserial primary key,
  Nombre varchar(25) not null,
  Apellidos varchar(50) not null,
  Email varchar(30) not null,
  Fecha_Nacimiento date,
  Telefono varchar(50) not null,
  Fecha_Matriculacuion date default current_date,
  ID_Identificate smallserial references identificador(ID),
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
  Nombre_Artistico varchar(15),
  primary key(ID)
)

create table if not exists pelicula (
  ID smallserial primary key,
  Titulo varchar(25) not null,
  Publicacion date not null,
  Sinopsis text,
  Copias smallint not null,
  ID_Genero smallserial,
  ID_Director smallserial
);

alter table pelicula add constraint FK_ID_Genero foreign key (ID_Genero) references genero (ID);
alter table pelicula add constraint UNIC_ID_Directtor unique (ID_Director);
alter table pelicula add constraint FK_ID_Directo foreign key (ID_Director) references director (ID);

create table if not exists prestamo (
  ID smallserial primary key,
  Fecha_Prestamo date default current_date,
  Fecha_Devolucion date default null,
  ID_Pelicula smallserial references pelicula(ID),
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



-- TRIGGER
/*
create function actualizar_copias() return trigger
as $$
begin
	select ID_pelicula from pelicula 
	update pelicula set Copias = (pelicula.Copias - 1) where ID = old.ID;
	return new;
end
$$
language plpgsql

create trigger TR_sumar_copias before insert on Prestamo
for each row
execute procedure actualizar_copias
*/



-- Tamaño ocupado en la DB
/*select pg_size_pretty(pg_database_size(current_database())) AS size;*/

-- Tamaño de las tablas de la DB
/* 
 SELECT 'tmp_videoclub', pg_size_pretty(pg_total_relation_size('tmp_videoclub')) AS size
 FROM information_schema.tables
 WHERE table_schema = 'ouldnetflix';
*/
