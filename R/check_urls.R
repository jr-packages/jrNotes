globalVariables(c("X1", "X2", "X3"))
#' @importFrom httr GET
#' @importFrom crayon yellow red green blue
check_urls = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  # Hack to detect internet connection on laptops
  if (httr::GET("www.google.com")$status != 200) {
    msg_info("No internet connection - skipping URL check")
    return(invisible(NULL))
  }
  msg_start("Checking URLS...check_urls()")
  tokens = read_tokens()
  urls = dplyr::filter(tokens, X1 == "url")$X3 #nolint

  # Old fashioned URL grep
  # No URLs gives a warning
  grepped_url = suppressWarnings(system2("grep",
                                         c('-Eo "(http|https)://[a-zA-Z0-9./?=_-]*"', "main.tex"), #nolint
                                         stdout = TRUE))
  urls = c(urls,  grepped_url)
  urls = unique(urls)

  bad_urls = FALSE
  for (url in urls) {
    msg_info(paste("Checking ", url), padding = 2)
    ping = try(httr::GET(url), silent = TRUE)

    if (class(ping) == "try-error") {
      msg_info(glue("{url}: {ping}"), padding = 2)
    } else {
      if (ping$status != 200) {
        msg_error(glue("status: {ping$status}"), padding = 2)
      }
      if (ping$status == 404) {
        bad_urls = TRUE
      }
    }
    if (str_detect(url, "index\\.html")) {
      msg = glue("You can probably delete index.html from the URL")
      msg_info(msg, padding = 2)
    }
  }
  if (bad_urls) {
    msg_error("Fix broken URLS")
    .jrnotes$error = TRUE
  } else {
    msg_ok("URLs look good")
  }
  return(invisible(NULL))
}
