######################################################################################################
## rgee: um pacote para acessar o Google Earth Engine(GEE)
## Autor do códgigo: Tainá Rocha & Adapções de exemplos disponíveis na documentação oficial do pacote disponivél em : https://csaybar.github.io/rgee-examples/
## Data: 27 de Agosto de 2022
## Versão do R: 4.2.1
## Versão Rstudio:
## Versão do rgee: 1.1.3
## Roteiro do script:

## 1 Instalações  -------------------------------------------------------------------------------
## 2 Funções por seção e sintaxe(ee_ x ee$) -----------------------------------------------------
## 3 Estudos de caso (2) ------------------------------------------------------------------------

######################################################################################################


#1 Instalações ----------------------------------------------------------------------------------------

# Requisitos:
# Conta no Google com Earth Engine ativado
# Python >= v3.5

#install.packages("rgee") # instalação parte 1- uma vez geralmente

# ee_instal() # instalação parte 2- uma vez geralmente

library(rgee)
ee_install()
# Numpy- pacote para manipulação de objetos do tipo array, ex.:matrizes multi-dimensioais;
# ee - pacote para interagir com a API Python do GEE
# Detalhes sobre a instalação estão disponíveis nas referências da apresentação

#2 Comandos por seção e sintaxe(ee_ x ee$) ----------------------------------------------------

library(rgee)


ee_check()

rgee::ee_check() # de bom tom sempre que iniciar uma nova R/Rstudio session para usar o rgee

# ee_Initialize()
rgee::ee_Initialize() # Obrigatório ao iniciar uma nova R/Rstudio session para usar o rgee

# Sintaxe(ee_ x ee$)


# Importação de dados

## Dados Matriciais (Raster)

###  Image GEE (Fonte- Catálago de dados do GEE https://developers.google.com/earth-engine/datasets/catalog/WORLDCLIM_V1_BIO)


### Image Colecttionns (Fonte- Catálago de Dados do GEE https://developers.google.com/earth-engine/datasets/catalog/WORLDCLIM_V1_MONTHLY)

#imgage_colec = ee.ImageCollection("WORLDCLIM/V1/MONTHLY")


## Dados Vetoriais (Shapefiles. Polígonos, pontos, linhas etc.)

### Feature GEE


### Feature Collections GEE


# Vizualiando os dados

### Load
image <- ee$Image("LANDSAT/LC08/C01/T1/LC08_044034_20140318")


## Map$centerObject(image)

Map$addLayer(image, name = "Landsat 8 original image")

# Define visualization parameters in an object literal.
vizParams <- list(
  bands = c("B5", "B4", "B3"),
  min = 5000, max = 15000, gamma = 1.3
)

Map$addLayer(image, vizParams, "Landsat 8 False color")

# Use Map to add features and feature collections to the map. For example,
counties <- ee$FeatureCollection("TIGER/2016/Counties")

Map$addLayer(
  eeObject = counties,
  visParams = vizParams,
  name = "counties"
)


# Operações matemáticas básicas


## EX 1 Índice de Vegetação por Diferença Normalizada (NDVI). Usando uma Landsat do catalágo de dados GEE

# Importando as imagens 7 composites.

landsat1999 <- ee$Image("LANDSAT/LE7_TOA_5YEAR/1999_2003")
landsat2008 <- ee$Image("LANDSAT/LE7_TOA_5YEAR/2008_2012")

ndvi2008 <- landsat2008$normalizedDifference(c("B4", "B3"))

# Subtração

diff <- landsat2008$subtract(landsat1999)






