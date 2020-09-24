## TODO:
## Check if advert & courses file exists
## Warning about .tex as the include/input doesn't work
## Check length of title to ensure that it doesn't go over page
## Check RSS is true for certain courses

#' @title Config checker
#' @description Checks that the config file is correct.
check_config = function() {
  msg_start("Checking config file...check_config()")
  config_issue = FALSE

  ## Check length of title on front page
  front = config::get("front")
  ## Remove line breaks & right hand whitespace
  front = stringr::str_split(front, "\\\\")[[1]][1]
  front = stringr::str_trim(front, side = "right")
  if (stringr::str_length(front) > 25L) {
    msg_error("Title is too long. Add a line break?", padding = 2)
    set_error()
    config_issue = TRUE
  }

  if (is.null(config::get("advert"))) {
    msg_error("Advert missing from config.", padding = 2)
    msg_error("Add 'advert: advert'", padding = 4)
    set_error()
    config_issue = TRUE
  }

  if (is.null(config::get("courses"))) {
    msg_info("Course dependency graph has not been included.", padding = 2)
    msg_info("Add 'courses: course-dependencies' to the config.yml", padding = 4)
    config_issue = TRUE
  }

  p = config::get("packages")
  if (!is.null(p)) {
    lang = get_repo_language()
    msg_error("Old style pkg config detected. Please remove", padding = 2)
    msg_error("Instead use:", padding = 2)
    message(glue::glue("  {lang}_packages:"))
    message("    - package1")
    message("    - package2")
    set_error()
  }

  if (isFALSE(config_issue)) {
    msg_ok("Config looks good!")
  }
  return(invisible(NULL))
}
