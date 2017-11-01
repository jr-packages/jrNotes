#' Set a consistent colour palette
#' 
#' @param set default 0 (the standard R colour palette). \code{set=1} for
#' alternative palette
#' @param alpha Value between 0 and 255. Sets the transparancy level. Default 255.
#' @export
set_palette = function(set = 0, alpha=255) {
  if(set ==1 ) {#I want hue - pimp
    palette(c(rgb(200,79,178, alpha=alpha,maxColorValue=255), 
              rgb(105,147,45, alpha=alpha, maxColorValue=255),
              rgb(85,130,169, alpha=alpha, maxColorValue=255),
              rgb(204,74,83, alpha=alpha, maxColorValue=255),
              rgb(183,110,39, alpha=alpha, maxColorValue=255),
              rgb(131,108,192, alpha=alpha, maxColorValue=255),
              rgb(63,142,96, alpha=alpha, maxColorValue=255)))
  } else {
    message("Setting Default palette")
    palette("default")
  }
  
}

