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
  message(yellow(symbol$circle_filled, "Spell check (experimental)"))


  in_words = spelling::spell_check_files(fnames, lang = "en_GB", ignore = words)
  if (nrow(in_words) == 0) {
    message(yellow(symbol$tick, "Spell check passed"))
    return(invisible(NULL))
  }
  msg = glue("{symbol$circle_filled} Any false warnings, please add the word to \\
              inst/WORDLIST in jrNotes and bump the third digit of the version.")
  message(yellow(msg))

  for (i in 1:nrow(in_words)) {
    msg = glue("\t {symbol$fancy_question_mark} {in_words[i, 1]}  {in_words[i, 2]}")
    message(red(msg))
  }

  return(invisible(NULL))
}
