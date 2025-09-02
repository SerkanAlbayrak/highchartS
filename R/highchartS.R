#' highchartS: Highstock tabanlı htmlwidget (highcharter'sız)
#'
#' @param series list of series; her biri list(name=?, data=?), data: list( list(ms, val), ... )
#' @param title  (character) grafik başlığı
#' @param yAxis  (list) Highcharts/Highstock yAxis konfig (tek ya da çoklu)
#' @param rangeSelector (logical) Highstock range selector açık/kapalı
#' @param width,height,elementId htmlwidget boyut/ID
#'
#' @export
highchartS <- function(series,
                       title = "My Highstock Chart",
                       yAxis = NULL,
                       rangeSelector = TRUE,
                       width = NULL, height = NULL, elementId = NULL) {

  x <- list(
    title = title,
    series = series,
    yAxis = yAxis,
    rangeSelector = rangeSelector
  )

  htmlwidgets::createWidget(
    name = "highchartS",
    x = x,
    width = width,
    height = height,
    package = "highchartS",
    elementId = elementId,
    dependencies = list(highcharts_dependency())
  )
}

# Highcharts/Highstock JS bağımlılıklarını (CDN) ekleyebiliriz. CDN yerine yerel dağıtım
# için JS dosyalarını inst/htmlwidgets/lib/highcharts/ altına koyup src = "lib/highcharts" şeklinde değiştirildi.
highcharts_dependency <- function() {
  htmltools::htmlDependency(
    name    = "highcharts",
    version = "11.4.0",   # siz hangi sürümü indirdiyseniz yazın
    src     = "htmlwidgets/lib/highcharts",   # paketteki local path
    package = "highchartS",
    script  = c(
      "highstock.js",
      "exporting.js",
      "data.js",
      "boost.js",
      "drilldown.js",
      "highcharts-more.js",
      "solid-gauge.js"
    )
  )
}


# htmlwidget'in HTML kabı (gerekirse ileri özelleştirme yapabilirsiniz)
highchartS_html <- function(id, style, class, ...) {
  htmltools::tags$div(id = id, class = class, style = style)
}

# ---- Yardımcılar (pakete dahil) ----

#' xts/zoo veya data.frame'i Highcharts dizi formatına çevirin
#'
#' Highcharts zaman ekseni milisaniye bekler. Bu fonksiyon, tek kolonlu xts/zoo
#' veya (Date|POSIXct, value) iki kolonlu data.frame'i
#' list(list(ms, val), ...) yapısına çevirir.
#'
#' @param x xts/zoo (tek kolon) ya da data.frame(Date|POSIXct, value)
#' @param name Seri adı
#' @export
as_hc_series <- function(x, name = "Series") {
  if (requireNamespace("xts", quietly = TRUE) && xts::is.xts(x)) {
    idx <- as.numeric(zoo::index(x)) * 1000
    val <- as.numeric(zoo::coredata(x))
    data <- Map(function(a, b) list(a, b), idx, val)
  } else if (is.data.frame(x)) {
    if (!inherits(x[[1]], c("Date", "POSIXct", "POSIXt")))
      stop("data.frame'in ilk kolonu Date/POSIX olmalı.")
    idx <- as.numeric(as.POSIXct(x[[1]], tz = "UTC")) * 1000
    val <- as.numeric(x[[2]])
    data <- Map(function(a, b) list(a, b), idx, val)
  } else {
    stop("Desteklenmeyen veri tipi. xts/zoo ya da iki kolonlu data.frame kullanın.")
  }

  list(name = name, data = data)
}

#' OHLC veri hazırlama yardımcı fonksiyonu (opsiyonel)
#'
#' @param df data.frame ya da xts, kolonlar: time, open, high, low, close
#' @param name Seri adı
#' @export
as_hc_ohlc <- function(df, name = "OHLC") {
  to_ms <- function(t) as.numeric(as.POSIXct(t, tz = "UTC")) * 1000

  if (requireNamespace("xts", quietly = TRUE) && xts::is.xts(df)) {
    time <- to_ms(zoo::index(df))
    o <- as.numeric(df[, 1]); h <- as.numeric(df[, 2])
    l <- as.numeric(df[, 3]); c <- as.numeric(df[, 4])
  } else if (is.data.frame(df)) {
    if (ncol(df) < 5) stop("En az 5 kolon gerekli: time, open, high, low, close")
    time <- to_ms(df[[1]])
    o <- as.numeric(df[[2]]); h <- as.numeric(df[[3]])
    l <- as.numeric(df[[4]]); c <- as.numeric(df[[5]])
  } else stop("xts ya da data.frame bekleniyor.")

  data <- Map(function(tt, oo, hh, ll, cc) list(tt, oo, hh, ll, cc),
              time, o, h, l, c)

  list(name = name, type = "candlestick", data = data)
}
