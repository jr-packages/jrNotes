check_python = function() {
  if (fs::file_exists("config.yml")) {
    con = config::get()
    if (isTRUE(con$python3)) {
      stopifnot(isTRUE(nchar(con$knitr$engine.path) > 2)) # Simple error check
    }
  }
}
