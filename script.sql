create schema if not exists OuldNetflix;

set schema "OuldNetflix";

create table if not exists Socio (
  ID uuid primary key,
  Nombre varchar[25] ,
  Apellidos varchar[25],
  Fecha_Nacimiento timestamp,
  Telefono int,
  ID_Identificate uuid,
  ID_Adress uuid
);

create table if not exists Identificador (
  ID uuid primary key,
  DNI varchar[12],
  Pasport varchar[15]
);

create table if not exists Adress (
  ID uuid primary key,
  Codigo_Postal int,
  Calle varchar,
  Numero int,
  Piso varchar[3]
);

create table if not exists Pelicula (
  ID uuid primary key,
  Titulo varchar[20],
  Year_Publicacion datetime,
  Director varchar[50],
  Sinopsis text,
  Copias int,
  ID_Genero uuid
);

create table if not exists Genero (
  ID uuid primary key,
  Genera varchar[20]
);

create table if not exists Prestamo (
  ID uuid primary key,
  ID_Pelicula uuid,
  ID_Socio uuid
);

alter table Identificador add constraint FK_ID_Identificador foreign key (id) references Socio (ID_Identificate);

alter table Adress add constraint FK_ID_Adress foreign key (id) references Socio (ID_Adress);

alter table Genero add constraint FK_ID_Genero foreign key (id) references Pelicula (ID_Genero);

alter table Pelicula add constraint FK_ID_Pelicula foreign key (id) references Prestamo (ID_Pelicula);

alter table Socio add constraint FK_ID_Socio foreign key (id) references Prestamo (ID_Socio);