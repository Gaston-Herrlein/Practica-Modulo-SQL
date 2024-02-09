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

En esta rama mi objetivo es concluir con mi idea original que era hacer uso del trigger para llevar las cuentas de las copias de las peliculas.
Esto pretendia hacerlo para llevar lo aprendido en el modulo un escalon mas arriba.

Por cuestiones de tiempo, y de complicaciones con la utilizacion del mismo, cambio el modelo de la base de datos en la rama main para precindir del uso de triggers.
