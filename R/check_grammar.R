check_grammar = function() {
  words = get_words
  fnames = list.files(pattern = "^c.*\\.Rmd$")
  main_words = spelling::spell_check_files("main.tex", lang = "en_GB", ignore = words)
  spelling_errors_removed = lapply(fnames, function(file) {
    text = readLines(file)
    grammar_errors = LanguageToolR::languagetool(text)

  })
  msg_start("Chapter {i} grammar check...check_grammar()")
}
