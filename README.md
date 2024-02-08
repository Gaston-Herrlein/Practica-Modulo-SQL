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

### En esta seccion voy explicar el porque de cada decisión que tomé en la creación de la BBDD

1. Se crea una tabla para director entendiendo que un director puede dirigir varias peliculas.
2. La relacion de _Socio_ con _Identificador_ y _Socio_ con _Direccion_ se plantea como 1 a 1 entendiendo que cada persona (socio) tiene 1 unico _Identificador_ y una unica _Direccion_, para los fines practicos del videoclub.
3. Para los campos que corresponden a fechas eh decidido utilizar el tipo de dato **Dates** ya que, en ninguno, se necesita la hora de la misma.
4. Para los campor _ID_ correspondiente a las PK de cada tabla utilizo smallserial, que es un valor numerico autoincremental de 2 bytes (de 0 a 32767)
5. Para los campos de texto se utiliza **Varchar[]** para delimitar la cantidad de caracteres y hacer un mejor uso del espacio de almacenamiento.
6. Referente al punto anterior hay una excepción, el campo _Sinopsis_ de la tabla **Pelicula**. Esta es de tipo **Text** para no limitar el largo
7. Para el campo _Numero_ de la tabla **Direccion** se utiliza el tipo de dato **Smallint** ya que con este tipo de datos podemos representar numeros hasta 32767 (se entiende que es un buen rango para una direccion)
8. Se decide separar el **Identificacor** en una tabla aparte, entendiendo que se pueden registar o con el DNI/NIE, o con el NIF, o con el Pasaporte (esto con el proposito de ampliar las opciones de identificación). De esta forma ampliamos la posibilidad de traer socios de otrso sitios, con sus respectivos "Idenificadores" y no solamente por registro directo.
9. Se agrega un campo _Fecah_Matriculacion_ ya que podria ser interesantea saber cuando se hizo socio del videoclub.
10. Para cada constraint intente hicerlos de varias maneras
11. Al completar la tabla de peliculas conte todos los prestamos de peliculas (ya sea que fueron devueltas o no) para obtener el total de peliculas en stock. Esto simplemente por simplicidad. Luego con un trigger actualizo las tablas;
