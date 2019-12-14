check_r_style = function() {
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
    ## Check that library calls are correctly quoted
    ## library("XXX") not library(XXX) #nolint
    r = readLines(fnames[i])
    libraries = r[stringr::str_detect(r, "^library\\(.*\\)$")]
    is_quoted = stringr::str_detect(libraries, '"', negate = FALSE)
    if (any(!is_quoted)) {
      msg = paste0(symbol$cross, " Quote package names: ", libraries[!is_quoted], collapse = "\n")
      message(red(msg))
      bad_lints = TRUE
    }
  }
  return(bad_lints)
}


check_python_style = function() {
  message(yellow(symbol$circle_filled, "Checking lint...check_code_style()"))
  if (!fs::file_exists("flake8.ini")) {
    message("Missing flake8_config.ini file - creating a default")
    flake8_ini_sys = system.file("", "flake8_config_Rmd.ini", package = "jrNotes", mustWork = TRUE)
    file.copy(flake8_ini_sys, to = "flake8_config.ini", overwrite = TRUE)
  }
  message(yellow(symbol$circle_filled, "Checking lint...check_code_style()"))
  fnames = list.files(pattern = "^c.*Rmd$")
  bad_lints = FALSE
  for (i in seq_along(fnames)) {
    message("  ", yellow(symbol$circle_filled, "Checking ", fnames[i]))
    jrpytests = reticulate::import("jrpytests")
    reticulate::jrpytests$runflake8rmdpychunks(filename = fnames[i])

  }
  return(bad_lints)

}

check_code_style = function() {
  language = get_repo_language()
  if (language == "python") {
    bad_lints = check_python_style()
  } else {
    bad_lints = check_r_style()
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
