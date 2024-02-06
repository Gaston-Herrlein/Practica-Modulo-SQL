create schema if not exists OuldNetflix;

set schema "OuldNetflix";

create table if not exists Socio (
  ID uuid primary key,
  Nombre varchar[25] not null,
  Apellidos varchar[25] not null,
  Fecha_Nacimiento date,
  Telefono numeric not null,
  Fecha_Matriculacuion date default current_date,
  ID_Identificate uuid references Identificador(ID),
  ID_Direccion uuid references Direccion(ID)
);

create table if not exists Identificador (
  ID uuid primary key,
  DNI varchar[25],
  Pasaporte varchar[25]
);

create table if not exists Direccion (
  ID uuid primary key,
  Codigo_Postal smallint,
  Calle varchar[30] not null,
  Numero smallint not null,
  Piso varchar[5]
);

create table if not exists Pelicula (
  ID uuid primary key,
  Titulo varchar[25] not null,
  Publicacion date not null,
  Sinopsis text,
  Copias smallint not null,
  ID_Director uuid references Director(ID),
  ID_Genero uuid references Genero(ID)
);

create table if not exists Director (
  ID uuid primary key,
  Nombre varchar[25] not null
  Apellido varchar[25] not null
  Nombre_Artistico varchar[15]
)

create table if not exists Genero (
  ID uuid primary key,
  Genera varchar[30] not null
);

create table if not exists Prestamo (
  ID uuid primary key,
  Fecha_Prestamo date default current_date,
  Fecha_Devolucion date default null
  ID_Pelicula uuid references Pelicula(ID),
  ID_Socio uuid references Socio(ID)
);

/*
alter table Identificador add constraint FK_ID_Identificador foreign key (id) references Socio (ID_Identificate);

alter table Direccion add constraint FK_ID_Direccion foreign key (id) references Socio (ID_Direccion);

alter table Genero add constraint FK_ID_Genero foreign key (id) references Pelicula (ID_Genero);

alter table Pelicula add constraint FK_ID_Pelicula foreign key (id) references Prestamo (ID_Pelicula);

alter table Socio add constraint FK_ID_Socio foreign key (id) references Prestamo (ID_Socio);
*/