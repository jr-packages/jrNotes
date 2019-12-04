check_tufte = function() {
  message(yellow(symbol$circle_filled, "Checking tufte latex...check_tufte()"))

  fnames = list.files(pattern = "^c.*\\.Rmd$", full.names = TRUE)
  msgs = c()
  for (fname in fnames) {
    out = readLines(fname)
    is_in = stringr::str_detect(out, pattern = "(margin_note|newthought\\()")
    if (sum(is_in) > 0) {
      line_numbers = which(is_in)
      msgs = c(msgs, glue_col("{red} {symbol$cross} {fname}, Line {line_numbers}: {out[is_in]}"))
    }
  }
  if (length(msgs) == 0L) {
    message(yellow(symbol$tick, "Tufte latex looks good"))
    return(invisible(NULL))
  }

  for (msg in msgs) {
    message(msg)
  }
  stop("Change markdown to latex, e.g. margin_note to \\marginnote", call. = FALSE)

}
