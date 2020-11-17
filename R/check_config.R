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
  con = get_config()
  ## Check length of title on front page
  front = con$front
  ## Remove line breaks & right hand whitespace
  front = stringr::str_split(front, "\\\\\\\\")[[1]][1]
  front = stringr::str_trim(front, side = "right")
  if (stringr::str_length(front) > 25L) {
    msg_error("Title is too long. Add a line break?", padding = TRUE)
    config_issue = TRUE
  }

  ## Check version
  version = con$version
  version = as.integer(stringr::str_split(version, "\\.")[[1]])
  if (version[3] > 9L) {
    msg_error("Point version larger than 10", padding = 2)
    msg_error(glue("New version should be {version[1]}.{version[2]+1}.0"), padding = 2)
    msg_error(glue("Please condense the previous NEWS.md entries to {version[1]}.{version[2]}.*"),
              padding = 2)
    config_issue = TRUE
  }

  if (is.null(con$advert)) {
    msg_error("Advert missing from config.", padding = TRUE)
    msg_error("Add 'advert: advert'", padding = TRUE)
    config_issue = TRUE
  }

  if (is.null(con$courses)) {
    msg_info("Course dependency graph has not been included.", padding = TRUE)
    msg_info("Add 'courses: course-dependencies' to the config.yml", padding = TRUE)
    config_issue = TRUE
  }

  p = con$packages
  if (!is.null(p)) {
    lang = get_repo_language()
    msg_error("Old style pkg config detected. Please remove", padding = TRUE)
    msg_error("Instead use:", padding = TRUE)
    message(glue::glue("  {lang}_packages:"))
    message("    - package1")
    message("    - package2")
    config_issue = TRUE
  }

  if (isFALSE(config_issue)) {
    msg_success("Config looks good!")
  }
  return(invisible(NULL))
}
