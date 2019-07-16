#' @importFrom spelling spell_check_files
update_wordlist = function(words, file_name = NULL) {
  if (is.null(file_name)) {
    f = file("WORDLIST", "w")
  } else {
    old_words = readLines(file_name)
    f = file(file_name, "w")
  }
  on.exit(close(f))
  words = glue::glue_collapse(c(old_words, words), sep = "\n")
  cat(words, file = f, append = TRUE)
}
get_words = function() {
  fname = system.file("WORDLIST", package = "jrNotes")
  words = readLines(fname, warn = FALSE)

  if (file.exists("WORDLIST")) {
    words = c(words, readLines("WORDLIST", warn = FALSE))
  }
  words
}

#' @rdname check_spelling
#' @export
make_wordlist = function(spelling_results) {
  f = file("WORDLIST", "w")
  on.exit(close(f))
  words = glue::glue_collapse(spelling_results$word, sep = "\n")
  cat(words, file = f, append = TRUE)
}

#' Spell checkers
#'
#' \code{check_spelling} runs a spell check on all c*.Rmd files.
#'
#' \code{make_wordlist} takes the output of \code{check_spelling} and
#' creates a local \code{WORDLIST} file with exceptions. This should be
#' added to jrNotes.
#' @param spelling_results A data frame - output of check spelling
#'
#' @export
check_spelling = function() {
  fnames = list.files(pattern = "^c.*\\.Rmd$")
  words =  get_words()
  if (file.exists("WORDLIST")) {
    words = c(words, readLines("WORDLIST", warn = FALSE))
  }
  spelling::spell_check_files(fnames, lang = "en_GB", ignore = words)
}
