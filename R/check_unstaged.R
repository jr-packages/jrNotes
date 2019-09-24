check_unstaged = function() {
  message(yellow(symbol$circle_filled, "Checking for uncommitted files...check_unstaged()"))

  output = system2("git",
                   args = c("diff", "--name-only"),
                   stdout = TRUE)
  if (length(output) > 0L) {
    message(blue(symbol$info,
                 "You have some unstaged files. It's worth commiting, then rerunning make final"))
  } else {
    message(yellow(symbol$tick, "Everything committed!"))
  }
  return(invisible(TRUE))


}
