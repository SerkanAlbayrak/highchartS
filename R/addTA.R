#' Add Technical Analysis (TA) chart with OHLC + Volume
#'
#' Bu fonksiyon, OHLC (candlestick) ve opsiyonel Volume serilerini birlikte çizer.
#' Kullanımı kolaylaştırmak için `highchartS()` fonksiyonunu çağırır.
#'
#' @param ohlc_data list of OHLC values: list(list(ms, open, high, low, close), ...)
#' @param volume_data list of volume values: list(list(ms, volume), ...). Varsayılan NULL.
#' @param name character, OHLC serisi adı (varsayılan "Symbol")
#' @param id character, OHLC serisinin id'si (varsayılan "ohlc")
#' @param title chart başlığı
#' @param subtitle chart alt başlığı
#' @param height chart yüksekliği (ör. 600 veya "600px")
#'
#' @return highchartS htmlwidget
#'
#' @examples
#' # Örnek OHLC ve Volume verisi
#' ohlc_data <- list(
#'   list(1735689600000, 93576, 94509.41, 93489.03, 94401.14),
#'   list(1735693200000, 94401.13, 94408.72, 93578.77, 93607.74)
#' )
#'
#' volume_data <- list(
#'   list(1735689600000, 755.99),
#'   list(1735693200000, 586.53)
#' )
#'
#' # Grafik çizimi
#' addTA(
#'   ohlc_data   = ohlc_data,
#'   volume_data = volume_data,
#'   name = "AAPL",
#'   id   = "aapl",
#'   title = "AAPL Historical",
#'   subtitle = "With OHLC + Volume"
#' )
#'
#' @export
addTA <- function(ohlc_data,
                  volume_data = NULL,
                  name = "Symbol",
                  id   = "ohlc",
                  title = "OHLC Chart",
                  subtitle = NULL,
                  height = 600) {

  # OHLC serisi
  s_ohlc <- list(
    type = "candlestick",
    name = name,
    id   = id,
    zIndex = 2,
    data = ohlc_data
  )

  # Volume serisi (opsiyonel)
  if (!is.null(volume_data)) {
    s_vol <- list(
      type = "column",
      name = "Volume",
      id   = paste0(id, "_vol"),
      data = volume_data,
      yAxis = 1
    )
    series <- list(s_ohlc, s_vol)
  } else {
    series <- list(s_ohlc)
  }

  # yAxis ayarları
  yaxes <- if (!is.null(volume_data)) {
    list(
      list(
        startOnTick = FALSE,
        endOnTick   = FALSE,
        labels = list(align="right", x=-3),
        title  = list(text="OHLC"),
        height = "60%",
        lineWidth = 2,
        resize = list(enabled=TRUE)
      ),
      list(
        labels = list(align="right", x=-3),
        title  = list(text="Volume"),
        top    = "65%",
        height = "35%",
        offset = 0,
        lineWidth = 2
      )
    )
  } else {
    list(list(title = list(text="OHLC")))
  }

  # highchartS çağrısı
  highchartS(
    series = series,
    title  = list(text = title),
    subtitle = list(text = subtitle),
    yAxis  = yaxes,
    tooltip = list(split=TRUE),
    height = height
  )
}
