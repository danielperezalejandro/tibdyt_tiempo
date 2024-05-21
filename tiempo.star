"""
Applet: Tiempo
Summary:  informacion del tiempo
Description: Muesttra informacion dle timepo.
Author: danielperezalejandro
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/base64.star", "base64")


SUN_ICON = base64.decode("iVBORw0KGgoAAAANSUhEUgAAAA0AAAALCAYAAACksgdhAAAAAXNSR0IArs4c6QAAAIVJREFUKFNjZMAC/l9i+M+ox8CITQ4khlWCKE2EFKHbCLcJphFEwxTd57mHol5JSQmsHsV5+DTAdIM0MsIUgjwOY6PbgNN59+7dgzsLWdHu3zxgrivrF7gw2HmENMBUwzQywjTATISZisxHthmkEWzTzJuvsDoNW+Smq4sx4ox1XKkBJA4AoH84cEr5M3wAAAAASUVORK5CYII=")
DEFAULT_PROVINCIA = "Las Palmas"
DEFAULT_MUNICIPIO="Firgas"
DEFAULT_FORMATO="2"
DEFAULT_GRADOS="celcius"

#Obtiene el codigo de la provincia
def obtener_codigo_provincia(nombre_provincia):
    urlProvincias = "https://www.el-tiempo.net/api/json/v2/provincias"
    response = http.get(urlProvincias)
    
    if response.status_code == 200:
        data = response.json()
        provincias = data.get("provincias", [])
        
        # Se busca el código de provincia correspondiente al nombre proporcionado
        for provincia in provincias:
            if provincia["NOMBRE_PROVINCIA"].lower() == nombre_provincia.lower():
                return provincia["CODPROV"]
    return None

#Obtiene el id del municipio
def obtener_id_municipio(codProv,nombre_municipio):
    urlMunicipios = "https://www.el-tiempo.net/api/json/v2/provincias/{}/municipios".format(codProv)
    response = http.get(urlMunicipios)
    
    if response.status_code == 200:
        data = response.json()
        municipios = data.get("municipios", [])
        
        # se busca el código del municipio correspondiente al nombre proporcionado
        for municipio in municipios:
            if municipio["NOMBRE"].lower() == nombre_municipio.lower():
                codigo_completo=municipio["CODIGOINE"]
                codigo_ajustado = codigo_completo[:5]
                return codigo_ajustado
    return None


def main(config):
    #Se obtienen los datos que introduce el usuario
    nombre_provincia = config.str("nombre_provincia", DEFAULT_PROVINCIA)
    nombre_municipio = config.str("nombre_municipio", DEFAULT_MUNICIPIO)
    formato_fecha=config.str("formato_fecha",DEFAULT_FORMATO)
    tipo_grados=config.str("grados_tipo",DEFAULT_GRADOS)
    simbolo="°C"
    
    
    codigo_provincia = obtener_codigo_provincia(nombre_provincia)
    cod_municipio = obtener_id_municipio(codigo_provincia, nombre_municipio)

    # Verifica si se encontró el código de provincia y municipio
    if codigo_provincia and cod_municipio:
        
        url_clima = "https://www.el-tiempo.net/api/json/v2/provincias/{}/municipios/{}".format(codigo_provincia, cod_municipio)
        
        
        # Se realiza la solicitud para obtener los datos del clima
        response = http.get(url_clima)
        
        if response.status_code == 200:
            data = response.json()
            
            # se obtienen los datos a mostrar por pantalla
            municipio_nombre = response.json()["municipio"]["NOMBRE"]
            temperatura = response.json()["temperatura_actual"]
            estado_cielo = response.json()["stateSky"]["description"]
            fecha=response.json()["fecha"]
            humedad=response.json()["humedad"]
            viento=response.json()["viento"]

            if tipo_grados=="kelvin":
                temperatura=int(temperatura)+273,14
                temperatura=str(temperatura).replace("(","")
                temperatura=str(temperatura).replace(")","")
                simbolo="K"
            elif tipo_grados=="fahrenheit":
                temperatura=(int(temperatura)*9/5)+32
                simbolo="°F"

            if formato_fecha=="1":
                fecha=cambiar_fromato_fecha(fecha)
            
            cielo = "{}".format( estado_cielo)
            nombre="{}".format(municipio_nombre)

            informacion="{}   Cielo: {} Humedad: {}%".format(fecha,cielo,humedad)
            
            
            #Se muetra la información
            return render.Root(
                child = render.Column(
                    children=[
                        render.Marquee(
                            width=66,
                            child=render.Text(nombre,color="#FFD700"),
                            offset_start=0,
                            offset_end=0,
                            scroll_direction="horizontal",
                            align="center",
                            

                        ),
                        render.Row(
                            expanded=True,
                            main_align="space_evenly",
                            cross_align="center",
                            children=[
                                render.Image(src=SUN_ICON),
                                render.Text("{}{}".format(temperatura,simbolo),color="#6495ED")
                            ]
                        ),
                        render.Marquee(
                            
                            width=65,
                            child=render.Text(informacion),
                            offset_start=0,
                            offset_end=0,
                            scroll_direction="horizontal",
                            align="center"
                        ),
                    ]
                )
            )
        else:
            # Mostrar un mensaje de error si no se pudo obtener los datos del clima
            return render.Root(
                child = render.WrappedText(
                    content="Error al obtener los datos",
                    width=65,
                    color="#FF0000",
                ),
            )
    else:
        # Mostrar un mensaje de error si no se encontró el código de provincia o municipio
        return render.Root(
            child = render.WrappedText(
                content="Los datos proporcionados no son válidos",
                width=65,
                color="#FF0000",
            ),
        )

def get_schema():
    fecha_options = [
        schema.Option(display="dd-mm-aaaa", value="1"),
        schema.Option(display="aaaa-mm-dd", value="2"),
    ]
    grados_options = [
        schema.Option(display="Celcius", value="celcius"),
        schema.Option(display="Kelvin", value="kelvin"),
        schema.Option(display="Fahrenheit", value="fahrenheit"),
    ]
    return schema.Schema(
        version="1",
        fields=[
            schema.Text(
                id="nombre_provincia",
                name="Nombre de Provincia",
                desc="Ingrese el nombre de la provincia.",
                icon="location",
            ),
            schema.Text(
                id="nombre_municipio",
                name="Nombre de Municipio",
                desc="Ingrese el nombre del municipio.",
                icon="location_city",
            ),
            schema.Dropdown(
                id="formato_fecha",
                name="Formato fecha",
                desc="Seleccione el formato de la fecha",
                options=fecha_options,
                default="aaaa-mm-dd",
                icon = "calendar",
            ),
            schema.Dropdown(
                id="grados_tipo",
                name="Métrica grados",
                desc="Seleccione la unidad de medida",
                options=grados_options,
                default="Celcius",
                icon = "thermometer",
            ),
        ],
    )
#Cambia el formato de la fecha
def cambiar_fromato_fecha(fecha):
    year, month, day=fecha.split("-")
    fecha="{}-{}-{}".format(day,month,year)
    return fecha
    