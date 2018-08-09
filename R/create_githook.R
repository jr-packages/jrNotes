#' @export
#' @rdname  get_logo_path
create_githook = function() {
  fname = system.file("extdata", "pre-push", package = "jrNotes", mustWork = TRUE)
  file.copy(fname, to = ".git/hooks/pre-push", overwrite = TRUE)
  Sys.chmod(".git/hooks/pre-push", mode = "0700", use_umask = FALSE)
  message("Added pre-push, now removing pre-commit")
  file.remove(".git/hooks/pre-commit")
}
