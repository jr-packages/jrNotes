check_code_style = function() {
  language = get_repo_language()
  if (language == "python") return (invisible(NULL))

    message(yellow(symbol$circle_filled, "Checking lint...check_code_style()"))
  if (isFALSE(config::get("lintr"))) {
    return(invisible(NULL))
  }
  fnames = list.files(pattern = "^c.*Rmd$")
  bad_lints = FALSE
  for (i in seq_along(fnames)) {
    message("  ", yellow(symbol$circle_filled, "Checking ", fnames[i]))
    l = lintr::lint(fnames[i])
    if (length(l) > 0) {
      message(red(symbol$cross, fnames[i]))
      print(l)
      bad_lints = TRUE
    }
  }

  if (bad_lints) {
    message(red(symbol$cross, "Fix styling"))
    .jrnotes$error = TRUE
  } else {
    message(yellow(symbol$tick, "Styling looks good"))
  }
}
#' Lintr functions
#'
#' Run lintr on a vector of files. If \code{fnames} is \code{NULL}
#' then use the regular expression \code{^c.*Rmd$}. If
#' \code{config::get("lintr")} is \code{FALSE}, no lint used.
#' @param fnames An optional vector of filenames
#' @export
lint_notes = function(fnames = NULL) {
  if (isFALSE(config::get("lintr"))) {
    return(invisible(NULL))
  }
  if (is.null(fnames)) {
    fnames = list.files(pattern = "^c.*Rmd$")
  }
  sapply(fnames, lintr::lint)
}
