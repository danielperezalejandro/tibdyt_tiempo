# tibdyt_tiempo
## Introducción
Esta aplicación muestra información del tiempo(temperatura, estado del cielo y humedad) para un municipio especificado,  obteniendo la información a través de la api de www.el-tiempo.net

## Estructura
Tiene las siguientes funciones principalmente:
- **main(config):** Función principal que procesa la entrada del usuario y renderiza la interfaz de usuario.
- **obtener_codigo_provincia(nombre_provincia):** Obtiene el código de la provincia mediante la API de El Tiempo.
- **obtener_id_municipio(codProv, nombre_municipio):** Obtiene el ID del municipio mediante la API de El Tiempo.
- **cambiar_formato_fecha(fecha):** Cambia el formato de la fecha de aaaa-mm-dd a dd-mm-aaaa.

## Flujo de Trabajo 
Entrada del Usuario:
El usuario ingresa el nombre de la provincia y el municipio, selecciona el formato de fecha y la unidad de medida para la temperatura.

Obtención de Datos:
La aplicación obtiene los datos meteorológicos del municipio especificado mediante llamadas a la API de El Tiempo.
  
Renderización de la Interfaz de Usuario:
Se muestra la información del tiempo, incluyendo la temperatura actual, el estado del cielo, la humedad y la fecha, utilizando los iconos correspondientes y actualizando el color según las condiciones climáticas.

## Instalación
Para la instalación y uso de la aplicación, debes descargar este repositorio. Una vez descargado, deberás acceder desde la consola al directorio donde estén los archivos y ejecutar el comando pixlet serve nombre_del_archivo.star. Con esto realizado, la consola te devolverá la URL en la que se está ejecutando la aplicación. Si ingresas en ella, podrás usarla y verla funcionar.

## Uso
El usuario debe insertar la provincia y el municipio, tambien tendrá la opcion de cambiar el formato de la fecha y elegir en que unidad de medida mostrar los grados.

## Autor
danielperezalejandro
