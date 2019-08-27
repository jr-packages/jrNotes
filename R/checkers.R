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
