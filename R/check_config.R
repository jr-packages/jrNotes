## TODO:
## Check if advert & courses file exisits
## Warning about .tex as the include/input doesn't work
## Check length of title to ensure that it doesn't go over page
## Check RSS is true for certain courses
## Change packages to be list config than named elements

#' @title Config checker
#' @description Checks that the config file is correct.
check_config = function() {
  msg_start("Checking config file...check_config()")
  config_issue = FALSE
  if (is.null(config::get("advert"))) {
    msg_info("Advert missing from config.", padding = 2)
    msg_info("Add 'advert: advert'", padding = 4)
    config_issue = TRUE
  }

  if (is.null(config::get("courses"))) {
    msg_info("Course dependency graph has not been included.", padding = 2)
    msg_info("Add 'courses: course-dependencies' to the config.yml", padding = 4)
    config_issue = TRUE
  }

  if (isFALSE(config_issue)) {
    msg_ok("Config looks good!")
  }
  return(invisible(NULL))
}
