#' @export
#' @importFrom fs file_exists file_delete file_copy
#' @rdname  create_logo
create_githook = function() {
  fname = system.file("extdata", "pre-push", package = "jrNotes", mustWork = TRUE)
  if (!file_exists("../.git/hooks/")) return()

  file_copy(fname, new_path = "../.git/hooks/pre-push", overwrite = TRUE)
  Sys.chmod("../.git/hooks/pre-push", mode = "0700", use_umask = FALSE)
  message("Added pre-push, now removing pre-commit")
  if (file_exists("../.git/hooks/pre-commit")) file_delete("../.git/hooks/pre-commit")
}
