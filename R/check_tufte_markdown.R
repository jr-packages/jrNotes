globalVariables(c("is_star", "is_backtick"))
check_rogue_markdown = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  if (!file.exists("extractor.csv")) return()
  msg_start("Checking for rogue markdown...check_rogue_markdown()")
  # Don't check for underscores - this would break latex anyway
  tokens = read_tokens()
  issues = tokens %>%
    dplyr::mutate(chap_num = cumsum(X1 == "chapter")) %>%
    dplyr::filter(X1 == "marginnote" | X1 == "sidenote") %>%
    dplyr::filter(!str_detect(X3, "flushright")) %>% # Remove include graphics
    dplyr::mutate(is_star = str_detect(X3, "\\*"),
                  is_backtick = str_detect(X3, "`")) %>%
    dplyr::filter(is_star | is_backtick)
  i = 1
  for (i in seq_len(nrow(issues))) {
    row = issues[i, ]
    msg = glue::glue("Chapter {row$chap_num} - {row$X1}: {row$X3}", padding = 2)
    msg_info(msg, padding = 2)
  }

  if ((sum(issues$is_backtick) + sum(issues$is_star)) == 0L) {
    msg_ok("Markdown looks good")
  }
  return(invisible(NULL))
}

#' @importFrom glue glue_col
#' @importFrom stringr str_detect
check_tufte = function() {
  msg_start("Checking tufte latex...check_tufte()")

  fnames = list.files(pattern = "^c.*\\.Rmd$", full.names = TRUE)
  msgs = c()
  for (fname in fnames) {
    out = readLines(fname)
    is_in = stringr::str_detect(out, pattern = "(margin_note|newthought\\(|\\^\\[)")
    if (sum(is_in) > 0) {
      line_numbers = which(is_in)
      msgs = c(msgs, glue_col("{fname}, Line {line_numbers}: {out[is_in]}"))
      .jrnotes$error = TRUE
    }
  }
  if (length(msgs) == 0L) {
    msg_ok("Tufte latex looks good")
  }

  for (msg in msgs) {
    msg_error(msg, padding = 2)
  }
  check_rogue_markdown()
  return(invisible(NULL))
}
