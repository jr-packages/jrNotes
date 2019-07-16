#' Config test
#'
#' When the notes are updated, the version should be updated as well.
#' This function looks at the commit log to check if the notes have been
#' updated, the config.yml should also be updated.
#'
#' This function is used in the .gitlab runner
#' @export
check_version = function() {
  if (Sys.getenv("CI_PROJECT_NAME") == "template") {
    # Don't update version on template
    return(invisible(TRUE))
  }
  message(yellow(symbol$circle_filled, "Checking version in config.yml"))
  ## Needed for runner
  system2("git", args = c("fetch", "origin"))
  ## See what files have been changed
  output = system2("git",
                   args = c("show", "origin/master..", "--stat", "--oneline"),
                   stdout = TRUE)

  ## Have any notes been changed
  chapters_changed = sum(str_detect(output, "notes/chapter.*\\.Rmd"))
  # Has the config been updated
  config_changed = sum(str_detect(output, "notes/config\\.yml"))

  if (chapters_changed > 0 && config_changed == 0) {
    message(red(symbol$cross,
                   "Chapters.Rmd have been updated, but version is unchanged!"))
    stop(red(symbol$cross, "Please update version number."), call. = FALSE)
  }
  message(yellow(symbol$tick, "Config looks good!"))
  return(invisible(TRUE))
}
