#' Config test
#'
#' When the notes are updated, the version should be updated as well.
#' This function looks at the commit log to check if the notes have been
#' updated, the config.yml should also be updated.
#'
#' This function is used in the .gitlab runner
#' @export
has_version_been_updated = function() {
  ## See what files have been changed
  output = system2("git",
                   args = c("show", "master..", "--stat", "--oneline"),
                   stdout = TRUE)

  ## Have any notes been changed
  chapters_changed = sum(str_detect(output, "notes/chapter.*\\.Rmd"))
  # Has the config been updated
  config_changed = sum(str_detect(output, "notes/config\\.yml"))

  if (chapters_changed > 0 && config_changed == 0) {
    stop("Please update version number.", call. = FALSE)
  }
  return(invisible(TRUE))
}
