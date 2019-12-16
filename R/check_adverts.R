#' @title Advert checker
#' @description Checks that adverts have been included. Prints a message if missing (no error.)
#' @import crayon cli
check_adverts = function() {
  missing_advert = FALSE
  message(yellow(glue("{symbol$circle_filled} Checking adverts...check_adverts()")))
  if (is.null(config::get("advert"))) {
    message(blue(glue("{symbol$info} Note: Advert has not been included.")))
    missing_advert = TRUE
  }
  if (is.null(config::get("courses"))) {
    message(blue(glue("{symbol$info} Note: Course dependency graph has not been included")))
    missing_advert = TRUE
  }

  if (missing_advert) {
    message(blue(glue("{symbol$info} Edit course notes .config file to add missing adverts")))
  } else {
    message(yellow(glue("{symbol$tick} Adverts look good")))
  }

  rm(missing_advert)

}
