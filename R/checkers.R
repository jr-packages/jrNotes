#' @importFrom httr GET
#' @import crayon cli
check_urls = function() {

  if (!file.exists("main.tex")) stop("main.tex not found", call. = FALSE)
  # Hack to detect internet connection on laptops
  if (httr::GET("www.google.com")$status != 200) {
    message("No internet connection")
    return(invisible(NULL))
  }

  message(yellow(symbol$circle_filled, "Checking URLS"))
  main_tex = readLines("main.tex")

  urls = stringr::str_match_all(main_tex, "\\\\url\\{([\\w\\d\\.\\:/-]*)\\}") #nolint
  urls = unlist(urls)
  urls = urls[!stringr::str_detect(urls, "\\{")]

  bad_urls = FALSE
  for (url in urls) {
    message("  ", yellow(symbol$circle_filled, "Checking ", url))
    status = GET(url)$status
    if (status != 200) {
      msg = glue("  {symbol$cross} {url}  status: {status}")
      message(msg)
      bad_urls = TRUE
    }
  }
  if (bad_urls) stop(red("Fix broken URLS"), call. = FALSE)
  message(yellow(symbol$tick, "URLs look good"))

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
    return(invisible(NULL))
  }
  stop(red("Multiply defined labels: \n"),
       paste(main_log[labels], collapse = "\n"),
       call. = FALSE)
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
