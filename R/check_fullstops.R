globalVariables("chap_num")
check_fullstops = function() {
  message(yellow(symbol$circle_filled,
                 "Checking for full stops...check_fullstops()"))
  if (!required_texlive(2017)) return(invisible(NULL))
  if (!file.exists("extractor.csv")) return()
  tokens = read_tokens() %>%
    tibble::as_tibble()

  issues = tokens %>%
    mutate(chap_num = cumsum(X1 == "chapter")) %>%
    dplyr::filter(X1 %in% c("marginnote", "sidenote", "caption", "footnote")) %>%
    dplyr::filter(str_detect(X3, "\\\\begin \\{flush", negate = TRUE)) %>% #nolint
    dplyr::select(X1, X3, chap_num) %>%
    dplyr::filter(str_count(X3, " ") > 1) %>%
    dplyr::filter(str_ends(X3, "[\\?|\\.|!|/]", negate = TRUE))

  if (nrow(issues) == 0) {
    message(yellow(symbol$tick, "Captions and friends look good look good"))
    return(invisible(TRUE))
  }

  message(red(symbol$cross, "Sentences should end with a full stop."))
  for (i in seq_len(nrow(issues))) {
    msg = glue::glue("  {symbol$cross} Chapter {issues[i, 3]} ({issues[i, 1]}): {issues[i, 2]}")
    message(red(msg))
  }
  .jrnotes$error = TRUE
  return(invisible(FALSE))
}
