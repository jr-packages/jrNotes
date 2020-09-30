globalVariables(c("X1", "X2", "X3"))
#' @importFrom httr GET
#' @importFrom crayon yellow red green blue
check_urls = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  # Hack to detect internet connection on laptops
  if (httr::http_error("www.google.com")) {
    msg_info("No internet connection - skipping URL check")
    return(invisible(NULL))
  } else {
    msg_start("Checking URLS...check_urls()")
  }

  tokens = read_tokens()
  # Get urls from extractor.csv
  urls = dplyr::filter(tokens, X1 == "url")$X3 #nolint

  df_status = t(data.frame(sapply(urls, url_exists, USE.NAMES = TRUE)))

  for (url in rownames(df_status)) {
    if (df_status[url,]$exists) {
      msg_success(url, padding = TRUE)
    } else {
      msg_error(glue::glue(url, df_status[url,]$message), padding = TRUE)
    }
  }

  # If any URL
  if (all(as.integer(df_status[,"exists"]))) {
    msg_success("URLs look good")
  } else {
    msg_error("Fix broken URLS")
  }
  return(invisible(NULL))
}

url_exists = function(url) {
  ping = try(httr::HEAD(url), silent = TRUE)
  if (class(ping) == "try-error") {
    exists = FALSE
    message = ping[1]
  } else {
    exists = ping$status %in% 200:205
    message = httr::http_status(ping$status)$message
  }
  list("exists" = exists, "message" = message)
}
