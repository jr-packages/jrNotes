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
