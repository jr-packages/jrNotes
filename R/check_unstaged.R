check_unstaged = function() {
  msg_start("Checking for uncommitted files...check_unstaged()")

  output = system2("git",
                   args = c("diff", "--name-only"),
                   stdout = TRUE)
  if (length(output) > 0L) {
    msg_info("You have some unstaged files. It's worth commiting, then rerunning make final",
             padding = 2)
  } else {
    msg_ok("Everything committed!")
  }
  return(invisible(TRUE))
}
