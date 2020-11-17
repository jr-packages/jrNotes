check_captions = function() {
  tokens = read_tokens()
  tokens %>%
    dplyr::filter(X1 == "caption") %>%
    dplyr::distinct() %>%
    dplyr::filter(str_detect(X2, "@tufte@", negate = TRUE))
}
