check_r_style = function() {
  msg_start("Checking lint...check_code_style()")
  if (isFALSE(config::get("lintr"))) {
    return(invisible(NULL))
  }
  fnames = list.files(pattern = "^c.*Rmd$")
  bad_lints = FALSE
  for (i in seq_along(fnames)) {
    file_lint = FALSE
    l = lintr::lint(fnames[i])
    if (length(l) > 0) {
      msg_error(fnames[i], padding = TRUE)
      print(l)
      bad_lints = file_lint = TRUE
    }
    ## Check that library calls are correctly quoted
    ## library("XXX") not library(XXX) #nolint
    r = readLines(fnames[i])
    libraries = r[stringr::str_detect(r, "^library\\(.*\\)$")]
    is_quoted = stringr::str_detect(libraries, '"', negate = FALSE)
    if (any(!is_quoted)) {
      msg = paste0(cross, " Quote package names: ", libraries[!is_quoted], collapse = "\n")
      message(red(msg))
      bad_lints = file_lint = TRUE
    }

    if (isFALSE(file_lint)) {
      msg_success(fnames[i], padding = TRUE)
    }
  }
  return(bad_lints)
}

check_python_style = function() {
  msg_start("Checking lint...check_code_style()")
  if (!fs::file_exists("flake8_config_Rmd.ini")) {
    msg_info("Missing flake8_config_Rmd.ini file - creating a default", padding = TRUE)
    flake8_ini_sys = system.file("", "flake8_config_Rmd.ini", package = "jrNotes", mustWork = TRUE)
    file.copy(flake8_ini_sys, to = "flake8_config_Rmd.ini", overwrite = TRUE)
  }
  fnames = list.files(pattern = "^c.*Rmd$")
  bad_lints = FALSE
  for (i in seq_along(fnames)) {
    msg_info(paste("Checking", fnames[i]), padding = TRUE)
    jrpytests = reticulate::import("jrpytests")
    jrpytests$runflake8rmdpychunks(filename = fnames[i])
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

  if (is.null(bad_lints)) {
    msg_info("Skipping lint check")
  } else if (bad_lints) {
    msg_error("Fix styling")
  } else {
    msg_success("Styling looks good")
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
