get_words = function() {
  fname = system.file("WORDLIST", package = "jrNotes")
  words = readLines(fname, warn = FALSE)
  words
}

make_wordlist = function(spelling_results) {
  f = file("WORDLIST", "w")
  on.exit(close(f))
  words = glue::glue_collapse(spelling_results$word, sep = "\n")
  cat(words, file = f, append = TRUE)
}

#' @title Spell checkers
#'
#' @description check_spelling runs a spell check on all c*.Rmd files.
#' @importFrom spelling spell_check_files
#' @export
check_spelling = function() {
  fnames = list.files(pattern = "^c.*\\.Rmd$")
  words =  get_words()
  message(yellow(circle_filled, "Spell check (experimental)...check_spelling()"))


  in_words = spelling::spell_check_files(fnames, lang = "en_GB", ignore = words)
  if (nrow(in_words) == 0) {
    message(yellow(tick, "Spell check passed"))
    return(invisible(NULL))
  }
  msg = glue("{circle_filled} Any false warnings, please add the word to \\
              inst/WORDLIST in jrNotes and bump the third digit of the version. \\
              A file (WORDLIST) has been created in this directory. Just edit \\
              and append to inst/WORDLIST.")
  message(blue(msg))

  for (i in seq_len(nrow(in_words))) {
    msg = glue("  {info} {in_words[i, 1]}  {in_words[i, 2]}")
    message(blue(msg))
  }
  make_wordlist(in_words)
  return(invisible(in_words))
}
