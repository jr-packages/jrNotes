#' Set a consistent colour palette
#'
#' @param set default 0 (the standard R colour palette). \code{set=1} for
#' alternative palette
#' @param alpha Value between 0 and 255. Sets the transparency level. Default 255.
#' @export
set_palette = function(set = 0, alpha=255) {
  #I want hue - pimp
  if (set == 1) {
    grDevices::palette(c(
      grDevices::rgb(200, 79, 178, alpha = alpha, maxColorValue = 255),
      grDevices::rgb(105, 147, 45, alpha = alpha, maxColorValue = 255),
      grDevices::rgb(85, 130, 169, alpha = alpha, maxColorValue = 255),
      grDevices::rgb(204, 74, 83, alpha = alpha, maxColorValue = 255),
      grDevices::rgb(183, 110, 39, alpha = alpha, maxColorValue = 255),
      grDevices::rgb(131, 108, 192, alpha = alpha, maxColorValue = 255),
      grDevices::rgb(63, 142, 96, alpha = alpha, maxColorValue = 255))
    )
  } else {
    msg_info("Setting Default palette")
    grDevices::palette("default")
  }
}
