## TODO:
## Check if advert & courses file exisits
## Warning about .tex as the include/input doesn't work
## Check length of title to ensure that it doesn't go over page
## Check RSS is true for certain courses
## Change packages to be list config than named elements

#' @title Config checker
#' @description Checks that the config file is correct.
check_config = function() {

  message(yellow(glue("{symbol$circle_filled} Checking config file...check_config()")))
  config_issue = FALSE
  if (is.null(config::get("advert"))) {
    message(blue(glue("{info} Advert missing from config. Add 'advert: advert'")))
    config_issue = TRUE
  }

  if (is.null(config::get("courses"))) {
    message(blue(glue("{info} Course dependency graph has not been included.
                      Add 'courses: course-dependencies' to the config.yml")))
    config_issue = TRUE
  }

  if (isFALSE(config_issue)) {
    message(yellow(glue("{tick} Config looks good!")))
  }
  return(invisible(NULL))
}
