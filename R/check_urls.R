globalVariables(c("X1", "X2", "X3"))

#' @importFrom httr HEAD http_status
url_info = function(url) {
  ping = try(httr::HEAD(url), silent = TRUE)
  if (class(ping) == "try-error") {
    status = ping[1]
    url_exists = FALSE
  } else {
    status = httr::http_status(ping$status)$message
    url_exists = ping$status %in% 200:210
  }
  list(exists = url_exists, url = url, status = status)
}

#' @importFrom httr http_error
#' @importFrom crayon yellow red green blue
check_urls = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  # Hack to detect internet connection on laptops
  if (isTRUE(httr::http_error("https://www.google.com"))) {
    msg_info("No internet connection - skipping URL check")
    return(invisible(NULL))
  }
  msg_start("Checking URLS...check_urls()")
  tokens = read_tokens()
  urls = dplyr::filter(tokens, X1 == "url")$X3 #nolint

  msg_info("Checking explict urls...", padding = TRUE)
  urls_good = TRUE
  for (url in unique(urls)) {
    resp = url_info(url)
    if (resp$exists || is_gitlab()) {
      msg_success(glue::glue("{resp$status}: {resp$url}"), padding = TRUE)
    } else {
      msg_error(glue::glue("{resp$status}: {resp$url}"), padding = TRUE)
      urls_good = FALSE
    }
  }

  # Grab url's (allow {-} for URLs from bash chunks)
  grep_urls = suppressWarnings(system2("grep",
                                         c("-Eo", "'(http|https)://([a-zA-Z0-9./?=_-]|{-})*'",
                                           "main.tex"), #nolint
                                         stdout = TRUE))

  # Strip {} from bash chunk URLs ({} invalid URL characters)
  grep_urls = gsub("\\{|\\}", "", grep_urls)

  urls = grep_urls[!(grep_urls %in% urls)]
  msg_info("Checking other urls...", padding = TRUE)
  for (url in unique(urls)) {
    resp = url_info(url)
    if (resp$exists) {
      msg_success(glue::glue("{resp$status}: {resp$url}"), padding = TRUE)
    } else {
      msg_warning(glue::glue("{resp$status}: {resp$url}"), padding = TRUE)
    }
  }

  # If any URL
  if (urls_good || is_gitlab()) {
    msg_success("URLs look good")
  } else {
    msg_error("Fix broken URLS")
  }
  return(invisible(NULL))
}
