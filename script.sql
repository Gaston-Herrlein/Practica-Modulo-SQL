create schema if not exists ouldnetflix;
set schema 'ouldnetflix';

-- Eliminacion de tablas existentes
/*
drop table if exists director cascade;
drop table if exists genero cascade;
drop table if exists prestamo cascade;
drop table if exists socio cascade;
drop table if exists pelicula cascade;
drop table if exists identificador cascade;
drop table if exists direccion cascade;
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
);

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
  ID serial primary key,
  ID_Pelicula smallserial,
  Is_Available boolean default true
);
alter table Copia add constraint FK_ID_Pelicula foreign key (ID_Pelicula) references pelicula (ID);

create table if not exists prestamo (
  ID smallserial primary key,
  Fecha_Prestamo date default current_date,
  Fecha_Devolucion date default null,
  ID_Copia integer references Copia(ID),
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
  ID_Identificacion,
  ID_Direccion
)
select distinct tv.nombre, concat(tv.apellido_1, ' ', tv.apellido_2) as apellidos, tv.email, cast (tv.fecha_nacimiento as date),
tv.telefono, i.id as ID_identificacion, d.id as ID_Direccion 
from tmp_videoclub tv 
join identificador i on i.dni = tv.dni
join direccion d on d.calle = tv.calle and cast (d.numero as varchar) = tv.numero; 
-- Pelicula
insert into pelicula (titulo, sinopsis, id_genero, id_director)
select distinct tv.titulo, tv.sinopsis, g.id as genero_id, d.id as director_id from tmp_videoclub tv
join genero g on g.genero = tv.genero
join director d on concat(d.nombre, ' ', d.apellido) = tv.director;
-- Copia
insert into copia (id, id_pelicula)
select distinct tv.id_copia, p.id from tmp_videoclub tv
join pelicula p on p.titulo = tv.titulo;
update copia set is_available = (
	select sum(case when tv.fecha_devolucion is null then 1 else 0 end) = 0
	from tmp_videoclub tv
	where copia.id = tv.id_copia
	group by tv.id_copia
);
-- Prestamo
insert into prestamo (fecha_prestamo, fecha_devolucion, id_copia, id_socio)
select distinct tv.fecha_alquiler, tv.fecha_devolucion, c.id as Copia_ID, s.id as Socio_ID from tmp_videoclub tv
join copia c on c.id = tv.id_copia
join socio s on s.email = tv.email;

-- Queris de consultas

--Pelicula|Copias disponibles
select p.titulo, sum(case when c.is_available is true then 1 else 0 end) as copias_disponibles from copia c
join pelicula p on p.id = c.id_pelicula
group by p.id
order by copias_disponibles desc;






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