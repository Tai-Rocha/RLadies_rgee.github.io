######################################################################################################
## rgee: um pacote para acessar o Google Earth Engine(GEE)
## Autor do códgigo: Tainá Rocha & Adapções de exemplos disponíveis na documentação oficial do pacote disponivél em : https://csaybar.github.io/rgee-examples/
## Data: 27 de Agosto de 2022
## Versão do R: 4.2.1
## Versão Rstudio:
## Versão do rgee: 1.1.3
## Roteiro do script:

## 1 Instalações  -------------------------------------------------------------------------------
## 2 Funções por seção
## 3 Sintaxe(ee_ x ee$) -----------------------------------------------------
## 4 Exemplos e Estudos de casos ------------------------------------------------------------------------

######################################################################################################


#1 Instalações ----------------------------------------------------------------------------------------

# Requisitos:
# Conta no Google com Earth Engine ativado
# Python >= v3.5

# install.packages("rgee") # instalação do pacote

## Função para instalação do ambiente virtual Python e suas dependecias:

# rgee::ee_install(py_env = "rgee")

# ou:
# library(rgee)
# ee_install(py_env = "rgee")


# Numpy- pacote para manipulação de objetos do tipo array, ex.:matrizes multi-dimensioais;
# ee - pacote para interagir com a API Python do GEE
# Detalhes sobre a instalação estão disponíveis nas referências da apresentação
# Defindo um lugar na sua máquina para istalação da dependecias phtyon


#2 Comandos por seção -----------------------------------------------------------

library(rgee)

# ou rgee::função

# Aconselhável executar a função de check sempre que iniciar uma R/Rstudio session.

rgee::ee_check()

rgee::ee_Initialize() # Obrigatório ao iniciar uma nova R/Rstudio session para usar o rgee


# 3 Sintaxe rgee x GEE -----------------------------------------------------------



# 4 Exemplos e Estudos de casos ------------------------------------------------------------------------

## Importação de dados

## Dados Matriciais (Raster)- No GEE esses dados podem ser uma Image ou ImageCollection

###  Image GEE (Fonte- Catálago de dados do GEE https://developers.google.com/earth-engine/datasets/catalog/AU_GA_DEM_1SEC_v10_DEM-H)

img_elev = rgee::ee$Image("AU/GA/DEM_1SEC/v10/DEM-H")

### Vendo o conteudo

img_elev$getInfo()

#### Plot / Visualização

rgee::Map$addLayer(img_elev)

### Parametrizando um pouco mais...para uma boa visualizaçao
### Definindo cores de acordo com valores mins e maxs. O códigos das pode ser obtido nesse site https://www.color-hex.com/

 vizParams = list(
  min = -10.0,
  max = 1300.0,
  palette = c("00FFFF", "ff0000")
  )

# Uma das maneiras de definir o "zoom" da imagem.

rgee::Map$setCenter(133.95, -24.69, 5)

#Map$centerObject(img_elev, zoom = 2)

rgee::Map$addLayer(img_elev, vizParams, "elevation_color")

### Image Collections (Fonte- Catálago de Dados do GEE https://developers.google.com/earth-engine/datasets/catalog/WORLDCLIM_V1_MONTHLY)

imgCol_clim = rgee::ee$ImageCollection("WORLDCLIM/V1/MONTHLY")

rgee::Map$addLayer(imgCol_clim) # not work


## Dados Vetoriais (Shapefiles. Polígonos, pontos, linhas etc.). No GEE dados vetorias são : Geometry, Feature ou FeatureCollection

## Geometry

geom = ee$Geometry$Polygon(
  list(
    c(-35, -10),
    c(35, -10),
    c(35, 10),
    c(-35, 10),
    c(-35, -10)
  )
)

#geom$getInfo()

## Plot / Visualização

Map$addLayer(geom)


### Feature

uma_Feature = ee$Feature(geom, list('x' = 42, 'y' = 'africa'))
uma_Feature$getInfo()

### Plot / Visualização

Map$addLayer(uma_Feature,name =  'Africa')


## Mas uma Feature NÃO necessariamente precisa ser uma Geometry. Pode ser um obejeto contendo apenas "propriedades" (dados ou informações)


### Feature Collections GEE

ecoreg <- ee$FeatureCollection("RESOLVE/ECOREGIONS/2017")

### Plot / Visualização

Map$addLayer(ecoreg)

### Aritimética básica

# Importando as imagens 7 composites.

landsat1999 = ee$Image("LANDSAT/LE7_TOA_5YEAR/1999_2003")
landsat2008 = ee$Image("LANDSAT/LE7_TOA_5YEAR/2008_2012")

# Subtração

subt = landsat2008$subtract(landsat1999)

Map$addLayer(subt)

#subt$getInfo()

## Divisão

div = landsat2008$divide(landsat1999)

Map$addLayer(div)

#div$getInfo()


## Adição

add = landsat2008$add(landsat1999)

Map$addLayer(add)

#add$getInfo()

## Multiplicação

mult = landsat2008$multiply(landsat1999)

Map$addLayer(mult)

#mult$getInfo()

## Média  ????

med = landsat2008$add(landsat1999)$divide(2)

Map$addLayer(med)


## Algumas estatítcas de fácil acesso

## EX 1 Índice de Vegetação por Diferença Normalizada (NDVI).

## Normalized Difference Vegetation Index (NDVI)  | Índice de Vegetação de Diferença Normalizada (IVDN)

ndvi2008 = landsat2008$normalizedDifference(c("B4", "B3"))

## SQRT
landsat1999$sqrt

## Max

## Min

### Estudos de caso mais elaborados

# Análise exploratória de dados climáticos (Precipitação), com o objetivo de verificar a tendência dos valores de precipitação ao longo de um determinado ano.


# Visualizar essa tendência em um gráfico

library(dplyr) # manipulação dos dados (dataframe)
library(geojsonio) # Converter dados para 'GeoJSON'
library(ggplot2) # gráficos
library(rgee) # obtenção dos dados / estatísticas
library(raster) # manipulação de dados vetoriais e matriciais
library(sf)   # manipulação de dados vetoriais
library(tidyr) # manipulação de dataframe


# Lendo o dado vetorial - área de estudo
nc_shape <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

# Plotando o dado
plot(sf::st_geometry(nc_shape)) #plotando

# Pipeline para acessar o dado de precipitação, fazer um recorte temporal, selecionar a variável de interesse (prec) e renomear.

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") |>
  ee$ImageCollection$filterDate("2001-01-01", "2002-01-01") |>
  ee$ImageCollection$map(function(x) x$select("pr")) |>  # Selecionar bandas de precipitação
  ee$ImageCollection$toBands() |>  # converter de um objeto imagecollection para objeto image
  ee$Image$rename(sprintf("PP_%02d",1:12)) # renomeando as bandas

ee$ImageCollection()

# Extraindo os valores de precipitação
ee_nc_rain <- ee_extract(x = terraclimate, y = nc_shape["NAME"], sf = FALSE)

## Manipulação do dataframe
ee_nc_rain |>
  tidyr::pivot_longer(-NAME, names_to = "month", values_to = "pr")  |>
  dplyr::mutate(month, month=gsub("PP_", "", month)) |>
  ggplot2::ggplot(aes(x = month, y = pr, group = NAME, color = pr)) +
  ggplot2::geom_line(alpha = 0.4) +
  ggplot2::xlab("Month") +
  ggplot2::ylab("Precipitation (mm)") +
  ggplot2::theme_minimal()

# Estudo de caso 2: obtendo estatísticas para determinadas áreas

library(purrr)
library(raster)


dat <- structure(list(ID = 758432:758443,
                      lat = c(-14.875, -14.875, -14.625, -14.625, -14.875, -14.875, -14.625, -14.625, -14.375, -14.375, -14.125, -14.125),
                      lon = c(-42.875, -42.625, -42.625, -42.875, -42.375, -42.125, -42.125, -42.375, -42.375, -42.125, -42.125, -42.375)),
                 class = "data.frame", row.names = c(NA, -12L))


dat_rast <- raster::rasterFromXYZ(dat[, c('lon', 'lat', 'ID')], crs = '+proj=longlat +datum=WGS84 +no_defs')
dat_poly <- raster::rasterToPolygons(dat_rast, fun=NULL, na.rm=TRUE, dissolve=FALSE)

plot(dat_poly)

# Transformando o dado vetorial em um objeto ee$FeatureCollection

coords <- as.data.frame(raster::geom(dat_poly))

polygonsFeatures <- coords %>%
  split(.$object) %>%
  purrr::map(~{
    rgee::ee$Feature(ee$Geometry$Polygon(mapply( function(x,y){list(x,y)} ,.x$x,.x$y,SIMPLIFY=F)))
  })

polygonsCollection <- rgee::ee$FeatureCollection(unname(polygonsFeatures))

# Plotando
rgee::Map$addLayer(polygonsCollection)

Map$addLayer()

# Acessando o dado de clima (temperatura mínima e máxima)

# Selecionando alguns dias

startDate <- rgee::ee$Date('2020-01-01');
endDate <- rgee::ee$Date('2020-01-10');

ImageCollection <- rgee::ee$ImageCollection('NASA/NEX-GDDP')$filter(ee$Filter$date(startDate, endDate))
ee$ImageCollection$filter

# Lista de imagens (um por dia)

ListOfImages <- ImageCollection$toList(ImageCollection$size());


# Apenas uma imagem (com três bandas)
image <- rgee::ee$Image(ListOfImages$get(8))

# Média

Means <- image$reduceRegions(collection = polygonsCollection,reducer= ee$Reducer$mean())
Means$getInfo()

## Vizualindo

mean_ggplot = ee_as_sf(Means)

ggplot(data = mean_ggplot) +
  geom_sf(aes(fill = mean_ggplot$tasmax))+
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")

# Salvando o resultado no Drive

output_mean <- rgee::ee_table_to_drive(
  collection = Means,
  fileFormat = "CSV",
  fileNamePrefix = "test"
)
output_mean$start()

ee_monitoring(output_mean)

####### Fim






