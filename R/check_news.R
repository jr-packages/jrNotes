#' @title Check NEWS format
#'
#' @description Checks that NEWS.md exists and title lines follow the correct format.
#' * If RELEASE: FALSE in the .github.yml, the test will be skipped. Useful when developing notes.
#' Otherwise
#' * NEWS.md should exist in the root directory
#' * Line 1 should be: # con$running
#' * Line 2 should be blank
#' * Line 3: ## Version con$version _20YY-MM-DD_
#' * Line 4:  `  *  `
#' The
#' @export
check_news = function() {
  msg_start("Checking NEWS.md...check_news()")
  r = readLines("../.gitlab-ci.yml")
  release = r[stringr::str_detect(r, "RELEASE:")]
  if (stringr::str_detect(release, '"FALSE"')) {
    msg_info("RELEASE is FALSE in .gitlab-ci.yml", padding = 2)
    msg_info("Skipping NEWS.md check", padding = 2)
    return(invisible(TRUE))
  }

  if (!file.exists("../NEWS.md")) {
    msg_error("NEWS.md is missing from the base directory", stop = FALSE)
    set_error()
    return(invisible(NULL))
  }

  news = readLines("../NEWS.md")
  con = config::get()

  # Check first line
  header_pattern  = glue::glue("^# {con$running}$")
  if (stringr::str_detect(news[1], pattern = header_pattern, negate = TRUE)) {
    msg = glue::glue("Top line of NEWS.md not have correct format. It should be
                       # {con$running}")
    msg_error(msg, stop = FALSE)
    set_error()
    return(invisible(NULL))
  }

  # Check line 2
  pattern = glue::glue("^$", .open = "<", .close = ">")
  if (length(news) < 2 || stringr::str_detect(news[2], pattern = "^$", negate = TRUE)) {
    msg = glue::glue("Second line of NEWS.md should be empty")
    msg_error(msg, stop = FALSE)
    set_error()
    return(invisible(NULL))
  }

  # Check line 3
  version = con$version
  pattern = glue::glue("^## Version <version> _20\\d{2}-\\d{2}-\\d{2}_$", .open = "<", .close = ">")
  if (length(news) < 3 || stringr::str_detect(news[3], pattern = pattern, negate = TRUE)) {
    msg = glue::glue("Second line of NEWS.md not have correct format. It should be
                       ## Version {version} _{Sys.Date()}_")
    msg_error(msg, stop = FALSE)
    set_error()
    return(invisible(NULL))
  }
  # Check line 4: Make sure there is news!
  if (length(news) < 4 || stringr::str_detect(news[4], pattern = "^  \\* ", negate = TRUE)) {
    msg = glue::glue("This entry seems to be not news worthy!
    Please add a little info of the form: '  * '")
    msg_error(msg, stop = FALSE)
    set_error()
    return(invisible(NULL))
  }

  msg_ok("NEWS.md looks good!")
  return(invisible(NULL))
}
