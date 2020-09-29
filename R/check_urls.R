globalVariables(c("X1", "X2", "X3"))
#' @importFrom httr GET
#' @importFrom crayon yellow red green blue
#' @importFrom RCurl url.exists
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

  # Replace {-} with - for BASH formatted lines starting with git
  system2("sed",
          args = c("-i", shQuote("/^\\FunctionTok{git}.*/d ; s/{-}/-/g"),
                   "extractor-tmp.tex"))

  grepped_url = suppressWarnings(system2("grep",
                                         c('-Eo "(http|https)://[a-zA-Z0-9./?=_-]*"', "extractor-tmp.tex"), #nolint
                                         stdout = TRUE))
  urls = unique(c(urls,  grepped_url))
  url_statuses = RCurl::url.exists(urls)
  for (url in names(url_statuses)) {
    if (url_statuses[url]) {
      msg_success(url, padding = TRUE)
    } else {
      msg_error(url, padding = TRUE)
    }
  }

  # If any URL
  if (all(url_statuses)) {
    msg_success("URLs look good")
  } else {
    msg_error("Fix broken URLS")
  }
  return(invisible(NULL))
}
