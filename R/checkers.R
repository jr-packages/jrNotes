check_master = function() {
  if (httr::GET("www.google.com")$status != 200) {
    message(yellow("No internet connection - skipping URL check"))
    return(invisible(NULL))
  }
  ## Needed for runner
  system2("git", args = c("fetch", "origin"))

  message(yellow(symbol$circle_filled, "Comparing to master"))
  g = system2("git",
              args = c("rev-list --left-right --count origin/master...@"),
              stdout = TRUE)

  master_commits = strsplit(g, split = "\t")[[1]][1]

  if (master_commits > 0) {
    msg = red(glue("{symbol$cross} Master ahead; git pull"))
    stop(msg, call. = FALSE)
  }
  message(yellow(symbol$tick, "Update to date with master"))
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
            paste(main_log[labels], collapse = "\n"),
            call. = FALSE)
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
            red(paste(main_log[refs], collapse = "\n")),
            call. = FALSE)
    .jrnotes$error = TRUE
  }
  return(invisible(NULL))
}

check_python = function() {
  if (is_legacy()) return(invisible(NULL))
  con = config::get()
  if (!isTRUE(con$python3)) return(invisible(NULL))
  message(yellow(symbol$circle_filled, "Checking python version"))

  if (!isTRUE(nchar(con$knitr$engine.path) > 2)) {
    stop(red("knitr Python engine path fail"), call. = FALSE)

  }
  message(yellow(symbol$tick, "Python version looks good"))
}
