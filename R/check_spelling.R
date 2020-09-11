get_words = function() {
  ## Get Global spelling file
  fname = system.file("WORDLIST", package = "jrNotes")
  words = readLines(fname, warn = FALSE)

  ## Check for local spelling file
  dir = get_root_dir()
  fname = file.path(dir, "WORDLIST")
  if (file.exists(fname)) {
    words = c(words, readLines(fname, warn = FALSE))
  } else {
    msg_info("WORDLIST file not found in the root directory", padding = 2)
  }

  # Remove comments & blank lines
  words = words[stringr::str_starts(words, pattern = "#", negate = TRUE)]
  words = words[nchar(words) > 0]
  words
}

#' @importFrom glue glue_collapse
make_wordlist = function(spelling_results) {
  # Creates a spelling_issues file with exceptions
  # Intentionally doesn't put it in the root - make the user look at it
  f = file("spelling_issues.txt", "w")
  on.exit(close(f))
  words = sort(unique(spelling_results$word))
  words = glue::glue_collapse(words, sep = "\n")
  cat(words, file = f, append = TRUE)
  msg_error("Spelling mistakes have been found in the notes", padding = 2)
  msg_error("The file spelling_issues contains a list of potential spelling mistakes", padding = 2)
  msg_error("Any words that are not errors should be added to ../WORDLIST", padding = 2)
  return(NULL)
}

#' @title Spell checkers
#'
#' @description check_spelling runs a spell check on all c*.Rmd files.
#' @importFrom spelling spell_check_files
#' @importFrom tidyr unnest
#' @importFrom rlang .data
#' @importFrom dplyr arrange
#' @export
check_spelling = function() {
  msg_start("Spell check...check_spelling()")
  words = get_words()

  fnames = list.files(pattern = "^c.*\\.Rmd$")
  in_words = spelling::spell_check_files(fnames, lang = "en_GB", ignore = words)
  if (nrow(in_words) == 0L) {
    msg_ok("Spell check passed")
    return(invisible(NULL))
  }
  set_error()
  make_wordlist(in_words)

  # Order spelling mistakes grouped by chapter
  in_words = tidyr::unnest(in_words, cols = .data$found)
  in_words = dplyr::arrange(in_words, .data$found, .data$word)
  # Work out the required amount of padding needed for _each_ word
  pad = 20 - nchar(in_words$word)
  pad = pad - min(pad) + 4
  for (i in seq_len(nrow(in_words))) {
    msg_error(glue("{in_words[i, 1]}{paste(character(pad[i]), collapse = ' ')}{in_words[i, 2]}"),
             padding = 4)
  }

  return(invisible(in_words))
}
