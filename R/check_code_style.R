
check_line_lengths = function(fname) {
  ## Extract code from code chunks
  contents = readLines(fname)
  ## purl doesn't knitr headers with python
  rcode = stringr::str_split(
    knitr::purl(text = contents, documentation = 1, quiet = TRUE),
    "\n")[[1]]

  ## Detect chunks and where echo/eval = FALSE
  chunks = stringr::str_starts(rcode, pattern = "## ---")
  echo_false = stringr::str_detect(rcode, "echo ?= ?FALSE")
  eval_false = stringr::str_detect(rcode, "eval ?= ?FALSE")

  ## Create a data frame: line_number, echo = TRUE | FALSE, eval
  echos = tibble::tibble(rcode = rcode,
                         line = seq_along(rcode),
                         echo = NA, eval = NA) %>%
    mutate(echo = ifelse(chunks, TRUE, .data$echo), ## Set to default knitr values
           eval = ifelse(chunks, TRUE, .data$eval),
           echo = ifelse(echo_false, FALSE, .data$echo),   ## Detect differences
           eval = ifelse(eval_false, FALSE, .data$eval)) %>%
    tidyr::fill(.data$echo, .direction = "down") %>%
    tidyr::fill(.data$eval, .direction = "down") %>%
    mutate(echo = ifelse(chunks, FALSE, .data$echo)) ## Reset chunk titles to FALSE

  ## Linewidth of current document
  ## linewidth = knitr::opts_chunk$get()$linewidth # nolint
  ## When eval = FALSE, purl adds "## " to the start
  linewidth = 59
  df = echos %>%
    dplyr::mutate(rcode = stringr::str_sub(rcode, 1 + 3 * !echos$eval),
                  linewidth = stringr::str_length(.data$rcode),
                  too_long = stringr::str_length(.data$rcode) > 59,
                  fname = fname) %>%
    dplyr::filter(.data$echo & .data$too_long) %>%
    dplyr::select(.data$line, .data$rcode)

  if (nrow(df) == 0) return(invisible(TRUE))
  msg = glue::glue("Some code lines are longer than {linewidth} characters!")
  msg_warning(msg, padding = TRUE)

  ## Display long lines and where to find them
  for (i in seq_len(nrow(df))) {
    msg = glue::glue("L{df[i, 1]}: {df[i, 2]}")
    msg_warning(msg, padding = TRUE)
  }
  return(FALSE)
}

check_r_style = function() {
  msg_start("Checking lint...check_code_style()")
  config = get_config()
  if (isFALSE(config$lintr)) {
    return(invisible(NULL))
  }
  fnames = list.files(pattern = "^c.*\\.Rmd$")
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
      msg = paste0("Quote package names: ", libraries[!is_quoted])
      sapply(msg, msg_error, padding = TRUE)
      bad_lints = file_lint = TRUE
    }

    if (isFALSE(file_lint)) {
      msg_success(fnames[i], padding = TRUE)
    }
    check_line_lengths(fnames[i])
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
  fnames = list.files(pattern = "^c.*\\.Rmd$")
  bad_lints = FALSE
  for (i in seq_along(fnames)) {
    msg_info(paste("Checking", fnames[i]), padding = TRUE)
    jrpytests = reticulate::import("jrpytests")
    jrpytests$runflake8rmdpychunks(filename = fnames[i])
    check_line_lengths(fnames[i])
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
#' then use the regular expression \code{^c.*\\.Rmd$}. If
#' lintr is \code{no} in the config file, no lint used.
#' @param fnames An optional vector of filenames
#' @export
lint_notes = function(fnames = NULL) {
  config = get_config()
  if (isFALSE(config$lintr)) {
    return(invisible(NULL))
  }
  if (is.null(fnames)) {
    fnames = list.files(pattern = "^c.*\\.Rmd$")
  }
  sapply(fnames, lintr::lint)
}
