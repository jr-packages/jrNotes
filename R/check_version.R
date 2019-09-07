#' Config test
#'
#' When the notes are updated, the version should be updated as well.
#' This function looks at the commit log to check if the notes have been
#' updated, the config.yml should also be updated.
#'
#' This function is used in the .gitlab runner
#' @export
check_version = function() {
  # Don't update version on template
  if (Sys.getenv("CI_PROJECT_NAME") == "template") {
    return(invisible(TRUE))
  }

  message(yellow(symbol$circle_filled, "Checking version in config.yml...check_version()"))
  # Don't update on non-release
  r = readLines("../.gitlab-ci.yml")
  release = r[stringr::str_detect(r, "RELEASE:")]
  if (stringr::str_detect(release, '"FALSE"')) {
    message(yellow(symbol$info, "RELEASE is FALSE in .gitlab-ci.yml"))
    message(yellow(symbol$info, "Skipping version number check"))
    return(invisible(TRUE))
  }

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
