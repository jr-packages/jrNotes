check_python = function() {
  con = config::get()
  if (!isTRUE(con$python3)) return(invisible(NULL))
  msg_start("Checking python version")

  if (!isTRUE(nchar(con$knitr$engine.path) > 2)) {
    msg_error("knitr Python engine path fail")
    stop()
  }
  msg_success("Python version looks good")
}
