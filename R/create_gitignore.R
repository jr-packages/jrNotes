#' Create a default gitignore
#' @description Create a default gitignore
#' @export
create_gitignore = function() {
  example_dir = system.file("extdata/",  package = "jrNotes")
  from = file.path(example_dir, "gitignore")
  to = ".gitignore"
  file.copy(from, to)
  message(".gitignore created")
  invisible(from)
}





