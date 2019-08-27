check_citations = function() {
  if (!file.exists("main.log")) return()
  message(yellow(symbol$circle_filled, "Checking for undefined citations"))
  main_log = readLines("main.log")
  labels = stringr::str_detect(main_log,
                      pattern = "Warning: There were undefined citations\\.$")

  if (sum(labels) == 0) {
    message(yellow(symbol$tick, "Citations look good"))
  } else {
    message(red("Undefined citations"))
    .jrnotes$error = TRUE
  }
  return(invisible(NULL))

}

# Don't allow duplicate labels
check_labels = function() {
  if (!file.exists("main.log")) return()
  message(yellow(symbol$circle_filled, "Checking for duplicate labels"))

  main_log = readLines("main.log")
  labels = str_detect(main_log,
                      pattern = "^LaTeX Warning: Label .* multiply defined\\.$")

  if (sum(labels) == 0) {
    message(yellow(symbol$tick, "Labels look good"))
  } else {
    message(red("Multiply defined labels: \n"),
            paste(main_log[labels], collapse = "\n"))
    .jrnotes$error = TRUE
  }
  return(invisible(NULL))
}


# Don't undefined references
# e.g. Reference `fig:row-layout' on page 25 undefined on input line 1509
check_references = function() {

  if (!file.exists("main.log")) return()
  message(yellow(symbol$circle_filled, "Checking for undefined refs"))

  main_log = readLines("main.log")
  refs = stringr::str_detect(main_log,
                             pattern = "undefined on input line")

  if (sum(refs) == 0) {
    message(yellow(symbol$tick, "Refs look good"))
  } else {
    message("\n", red(glue("{symbol$cross} Underfined refs")), "\n",
            red(paste(main_log[refs], collapse = "\n")))
    .jrnotes$error = TRUE
  }
  return(invisible(NULL))
}
