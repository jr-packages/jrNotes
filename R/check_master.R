check_master = function() {
  if (httr::GET("www.google.com")$status != 200) {
    msg_info("No internet connection - skipping URL check")
    return(invisible(NULL))
  }
  ## Needed for runner
  system2("git", args = c("fetch", "origin"))
  msg_start("Comparing to master")
  g = system2("git",
              args = c("rev-list --left-right --count origin/master...@"),
              stdout = TRUE)

  master_commits = strsplit(g, split = "\t")[[1]][1]

  if (master_commits > 0) {
    msg_error("Master ahead; git pull")
    stop()
  }
  msg_success("Up to date with master")
  return(invisible(NULL))
}
