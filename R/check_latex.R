check_latex = function() {
  check_citations()
  check_labels()
  check_references()
  check_tufte()
}

check_citations = function() {
  if (!file.exists("main.log")) return()
  msg_start("Checking for undefined citations...check_citations()")
  main_log = readLines("main.log")
  labels = stringr::str_detect(main_log,
                               pattern = "Warning: There were undefined citations\\.$")

  if (sum(labels) == 0) {
    msg_success("Citations look good")
  } else {
    msg_error("Undefined citations")
  }
  return(invisible(NULL))
}

# Don't allow duplicate labels
check_labels = function() {
  if (!file.exists("main.log")) return()
  msg_start("Checking for duplicate labels...check_labels()")

  main_log = readLines("main.log")
  labels = str_detect(main_log,
                      pattern = "^LaTeX Warning: Label .* multiply defined\\.$")

  if (sum(labels) == 0) {
    msg_success("Labels look good")
  } else {
    msg_error("Multiply defined labels:", padding = TRUE)
    sapply(main_log[labels], msg_error, padding = TRUE)
  }
  return(invisible(NULL))
}

# Don't undefined references
# e.g. Reference `fig:row-layout' on page 25 undefined on input line 1509
check_references = function() {

  if (!file.exists("main.log")) return()
  msg_start("Checking for undefined refs...check_references()")

  main_log = readLines("main.log")
  refs = stringr::str_detect(main_log, pattern = "undefined on input line")
  if (sum(refs) == 0L) {
    msg_success("Refs look good")
  } else {
    msg_error("Underfined refs", padding = TRUE)
    sapply(main_log[refs], msg_error, padding = TRUE)
  }
  return(invisible(NULL))
}
