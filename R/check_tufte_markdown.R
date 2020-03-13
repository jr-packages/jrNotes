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
  return(invisible(NULL))
}
