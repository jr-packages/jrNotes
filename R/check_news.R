#' @title Check NEWS format
#'
#' @description Checks that NEWS.md exists and title lines follow the correct format.
#' If the \code{pattern} is \code{NULL}, then the expected format is either:
#' \code{# pkg_name Version _YYYY-MM-DD_} or \code{# pkg_name _(development version)_}
#' @export
check_news = function() {
  cli::cli_h3("Checking NEWS.md...check_news()")
  r = readLines("../.gitlab-ci.yml")
  release = r[stringr::str_detect(r, "RELEASE:")]
  if (stringr::str_detect(release, '"FALSE"')) {
    msg_info("RELEASE is FALSE in .gitlab-ci.yml", padding = 2)
    msg_info("Skipping NEWS.md check", padding = 2)
    return(invisible(TRUE))
  }

  if (!file.exists(file.path(path, "../NEWS.md"))) {
    msg_error("NEWS.md is missing from the base directory", stop = TRUE)
  }

  news = readLines(file.path(path, "../NEWS.md"))
  con = config::get()
  version = con$version
  pattern = glue::glue("^# <version> _20\\d{2}-\\d{2}-\\d{2}_$", .open = "<", .close = ">")
  if (stringr::str_detect(news[1], pattern = pattern, negate = TRUE)) {
      msg = glue::glue("Top line of NEWS.md not have correct format. It should be
                       # {version} _{Sys.Date()}_")
      msg_error(msg, stop = TRUE)
    }

  cli::cli_alert_success("NEWS.md looks good!")
  return(invisible(NULL))
}
