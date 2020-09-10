get_words = function() {
  fname = system.file("WORDLIST", package = "jrNotes")
  words = readLines(fname, warn = FALSE)
  words
}

#' @importFrom glue glue_collapse
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
#' @importFrom tidyr unnest
#' @export
check_spelling = function() {
  fnames = list.files(pattern = "^c.*\\.Rmd$")
  words =  get_words()
  msg_start("Spell check (experimental)...check_spelling()")


  in_words = spelling::spell_check_files(fnames, lang = "en_GB", ignore = words)
  if (nrow(in_words) == 0) {
    msg_ok("Spell check passed")
    return(invisible(NULL))
  }
  msg = glue("{circle_filled} Any false warnings, please add the word to \\
              inst/WORDLIST in jrNotes and bump the third digit of the version. \\
              A file (WORDLIST) has been created in this directory. Just edit \\
              and append to inst/WORDLIST.")
  msg_info(msg, padding = 2)

  # Order spelling mistakes grouped by chapter
  in_words = unnest(in_words, cols=c(found))
  in_words = with(in_words, in_words[order(found, word) , ])

  for (i in seq_len(nrow(in_words))) {
    msg_info(glue("{in_words[i, 1]}\t\t{in_words[i, 2]}"), padding = 4)
  }
  make_wordlist(in_words)
  return(invisible(in_words))
}
