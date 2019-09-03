globalVariables("chap_num")
check_fullstops = function() {
  message(yellow(symbol$circle_filled,
                 "Checking for full stops...check_fullstops()"))
  if (!file.exists("extractor.csv")) return()
  tokens = read_tokens()
  tokens = tibble::as_tibble(tokens)

  issues = tokens %>%
    mutate(chap_num = cumsum(X1 == "chapter")) %>%
    dplyr::filter(X1 %in% c("marginnote", "sidenote", "caption")) %>%
    dplyr::filter(str_detect(X3, "\\\\begin \\{flush", negate = TRUE)) %>% #nolint
    dplyr::select(X1, X3, chap_num) %>%
    dplyr::filter(str_count(X3, " ") > 3) %>%
    dplyr::filter(str_ends(X3, "[\\?|\\.|!|/]", negate = TRUE))

  if (nrow(issues) == 0) {
    message(yellow(symbol$tick, "Captions and friends look good look good"))
    return(invisible(TRUE))
  }

  message(red(symbol$cross, "Sentences should end with a full stop."))
  for (i in seq_len(nrow(issues))) {
    msg = glue::glue("  {symbol$cross} Chap {issues[i, 3]} ({issues[i, 1]}): {issues[i, 2]}")
    message(red(msg))
  }
  .jrnotes$error = TRUE
  return(invisible(FALSE))
}
