#' @title Call latexmk
#'
#' @param fname Latex file
#' Detects if the references.bib file contains entries and calls
#' bibtex appropriately.
#' @export
latexmk = function(fname) {
  if (!file.exists(fname)) return(invisible(NULL))

  refs = readLines("references.bib")
  if (length(refs) > 2) {
    system2("latexmk", args = c("--xelatex", fname))
  } else {
    system2("latexmk", args = c("--xelatex", "-bibtex-", fname))

  }
  return(invisible(TRUE))
}
