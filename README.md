# Enunciado

Se debera implementar una BBDD que cumpla los siguientes requisitos:

- Se necesita registrar los socios de un videoclub. Al menos necesito su nombre y apellidos, fecha de nacimiento, teléfono y su número de identificación (DNI, Pasaporte, o el nombre que reciba en tu país) y se debera asignar de manera automtica un número de socio que usaremos para hacer carnets.
- Se necesita registrar la dirección de correspondencia de los socios para, eventualmente, hacer campañas de publicidad, pero no es un requisito obligatorio que un socio nos de esa información. Con el código postal, calle, número y piso es suficiente, sobreentendemos que será de la misma ciudad donde está el videoclub.
- Se necesita registrar cada película. Puedo tener más de una copia de cada una. De cada película se necesita registrar el título, año de publicación, género, director y sinopsis.
- Se necesita saber a que socio le he prestado cada copia y cuando. Es decir, registrar la fecha en la que se la ha llevado y la fecha de la devolución. Cuando una película no tiene fecha de devolución, la consideramos prestada.
- Por último, se necesita consultar a menudo:
  1. Que películas están disponibles para alquilar en este momento (no están prestadas)
  2. Cual es el género favorito de cada uno de mis socios para poder recomendarle películas cuando venga.

# Solucion

#### En primer lugar creo un nuevo esquema donde guardar las tablas y sus valores

```sql
create schema if not exists ouldnetflix;
set schema 'ouldnetflix';
```

### Creacion de las tablas

Para todos los campor _ID_, correspondiente a las PK, de cada tabla utilizo el tipo de variable `smallserial`. Este es un valor numerico autoincremental de 2 bytes (va desde 0 a 32767). Lo cual me parecio un buen rango para esta BBDD.

Se podria considerar cambiar el tipo de dato a `serial` para el caso de _Socio_, _Pelicula_ y a `bigserial` para _Prestamo_. Pero a modo de simplificación los dejo todos como `smallserial`

#### Identificador

```sql
create table if not exists identificador (
  ID smallserial primary key,
  DNI varchar(20) not null,
  NIE varchar(20) default 'N/A',
  Pasaporte varchar(20) default 'N/A'
);
```

En esta tabla quice representar la idea que una persona puede identificar su identidad de varias formas. Siendo la mas comun DNI se le agrega una constraint _Not Null_ y las siguientes se les asigna un valor por defecto _'N/A'_. En la implementacion si alguien qusiera identificarse con el pasaporte, porque es extranjero, habria que asignarle _N/A_ al campo _DNI_

#### Direccion

```sql
create table if not exists direccion (
  ID smallserial,
  Codigo_Postal varchar(5) not null,
  Calle varchar(30) not null,
  Numero smallint not null,
  Piso varchar(5) default 'N/A',
  primary key (ID)
);
```

A diferencia de lo trabajado en clase, quise uní los campos piso y puerta en uno solo, llamandolo piso en este caso. Tambien me parecio interesante que el _Numero_ sea de tipo `smallint` ya que este valor puede contener numeros hasta 32767, el cual me parece un rango mas que suficiente

#### Socio

```sql
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
```

A esta tabla me además de los campos pedidos en el enunciado, le agregue _Fecha_Matriculacion_ con el valor por defecto del dia actual. Esto lo hice pensando en una posible implementacion este campo nos serviria para saber cuando se matriculo en el videoclub y de ahí armar campañas de marketing, emailmarketing, regalos por aniversario, etc.

#### Genero

```sql
create table if not exists genero (
  ID smallserial primary key,
  Genero varchar(30) not null
);
```

#### Director

```sql
create table if not exists director (
  ID smallserial,
  Nombre varchar(25) not null,
  Apellido varchar(25) not null,
  Nombre_Artistico varchar(15) default 'N/A',
  primary key(ID)
);
```

#### Pelicula

```sql
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
```

En este caso quise utilizar la instruccion `alter table` para añadir las FK. Esto simplemente para demostrar mi conocimiento y no definito todas las constraints en la creacion de las tablas.

El campo _Publicacion_ contiene la fecha de publicacion de cada pelicula. Quisiera aclarar que esta informacion no venia en los datos de prueba, por lo que queda el campo vacio al realizar el llenado.

#### Copia

```sql
create table if not exists Copia (
  ID serial primary key,
  ID_Pelicula smallserial,
  Is_Available boolean default true
);
alter table Copia add constraint FK_ID_Pelicula foreign key (ID_Pelicula) references pelicula (ID);
```

Esta tabla tiene como objetivo guardas cada copia de cada pelicula, además de un campo que nos dice si la copa esta disponible para alquilar `TRUE` o no `FALSE`.

Podria plantearse la idea de agrupar _ID_ con _ID_Pelicula_ de esta forma el ID podria ser el numero de copias correspondiente, lo cual tendria un valor mas significativo. Ej:

- Para la pelicula _E Padrino_ podriamos tener ID=1, ID=2, ID=3
- Para la pelicula _El Caballero Oscuro_ tambien podriamos tener ID=1, ID=2, ID=3.

Y con esto no violariamos la condicion de unisidad de las PK ya que serian 2 campos.

**_Nuevamente por simplicidad a la hora de realizar el ejercicio deje con el ID como unico campo de la PK_**

#### Prestamo

```sql
create table if not exists prestamo (
  ID smallserial primary key,
  Fecha_Prestamo date default current_date,
  Fecha_Devolucion date default null,
  ID_Copia integer references Copia(ID),
  ID_Socio smallserial references socio(ID)
);
```

En este caso le asigno, como valor por defecto, al campo _Fecha_Devolucion_ `NULL`. Aunque viole una condicion de la primera forma normal, esta fue la forma que encontre para identificar que todavia no estaba devuelta.

Otra idea fue asignarle a la fecha de prestamo y devolucion la misma fecha. Considerando que si eran iguales no se habia actualizado la tabla por lo que no se habia devuelto. Esta logica me dio problemas a la hora de implementarla por lo que la descarté

### LLenado de tablas

#### Solamente voy a comentar la query del llenado de la tabla _Copia_ ya que tiene una particularidad.

```sql
insert into copia (id, id_pelicula)
select distinct tv.id_copia, p.id from tmp_videoclub tv
join pelicula p on p.titulo = tv.titulo;
update copia set is_available = (
	select sum(case when tv.fecha_devolucion is null then 1 else 0 end) = 0
	from tmp_videoclub tv
	where copia.id = tv.id_copia
	group by tv.id_copia
);
```

Para completar esta tabla no pude hacerlo con una unica consulta, ya que me daba conflictos con los joins de la forma que pensaba hacerlo. Para solucionarlo primero cargo los valores de los campos _id_ e _id_pelicula_ de forma muy sencilla. Posteriormente procedo a actualizar la el campo _is_available_ el cual, al no cargarle nada queda por defecto como `TRUE`.

Para actualizarlo primero utilizo `sum(case when tv.fecha_devolucion is null then 1 else 0 end)`, lo suma 1 en casode que _tv.fecha_devolucion_ sea `NULL`, en caso contrario (que contenga un valor) se suma 0. Lo cual al agruparlo por _tv.id_copia_ `group by tv.id_copia` se espera un valor entre 0 y 1, representando pelicula no devuelta/devuelta respectivamente.

### Querys de consultas

#### ¿Que películas están disponibles?

```sql
select p.titulo, sum(case when c.is_available is true then 1 else 0 end) as copias_disponibles from copia c
join pelicula p on p.id = c.id_pelicula
group by p.id
order by copias_disponibles desc;
```

Esta query muestra todas las peliculas, ya sea que esten prestadas o no, las agrupa por peliculas (con el ID) y muestra en primer lugar las que estan disponibles para alquilar

#### Género favorito de cada socio

```sql
select s.id as N°_socio, concat(s.nombre, ' ', s.apellidos) as Socio, genero.genero, count(genero.id) as veces_alquilada
from socio s
join prestamo on prestamo.id_socio = s.id
join copia on copia.id = prestamo.id_copia
join pelicula on pelicula.id = copia.id_pelicula
join genero on genero.id = pelicula.id_genero
group by s.id, genero.id
order by s.id, count(genero.id) desc;
```

En este caso similar al enterior se muestran todos los socios y la cantidad de veces que han alquilado peliculas de determinado genero. Ordenandolo de forma ascendente para tener sus generos favoritos en primer lugar

### NOTA

En caso de querer probar el script completo primero se tendran que cargar las tablas con los [datos de prueba](/tmp_videoclub.sql)
