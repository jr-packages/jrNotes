globalVariables(c("X1", "X2", "X3"))
#' @importFrom httr GET
#' @import crayon cli
check_urls = function() {
  # Hack to detect internet connection on laptops
  if (httr::GET("www.google.com")$status != 200) {
    message(yellow("No internet connection - skipping URL check"))
    return(invisible(NULL))
  }
  message(yellow(symbol$circle_filled, "Checking URLS...check_urls()"))
  tokens = read_tokens()
  urls = dplyr::filter(tokens, X1 == "url")$X3 #nolint

  # Old fashioned URL grep
  # No URLs gives a warning
  grepped_url = suppressWarnings(system2("grep",
                                         c('-Eo "(http|https)://[a-zA-Z0-9./?=_-]*"', 'main.tex'), #nolint
                                         stdout = TRUE))
  urls = c(urls,  grepped_url)
  urls = unique(urls)


  bad_urls = FALSE
  for (url in urls) {
    message("  ", yellow(symbol$circle_filled, "Checking ", url))
    status = GET(url)$status
    if (status != 200) {
      msg = glue("  {symbol$cross} {url}  status: {status}")
      message(red(msg))
    }
    if (status == 404) {
      bad_urls = TRUE
    }
    if (str_detect(url, "index\\.html")) {
      msg = glue("  {symbol$info} {url}  You can probably delete index.html")
      message(blue(msg))
    }

  }
  if (bad_urls) {
    message(red("Fix broken URLS"))
    .jrnotes$error = TRUE
  } else {
    message(yellow(symbol$tick, "URLs look good"))
  }
  return(invisible(NULL))
}
