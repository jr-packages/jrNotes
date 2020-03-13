tokenise = function() {
  fname = system.file("extdata", "extractor.tex",
                      package = "jrNotes", mustWork = TRUE)

  file.copy(fname, to = "extractor.tex", overwrite = TRUE)
  file.copy("main.tex", "extractor-tmp.tex", overwrite = TRUE)
  msg_info("Checking tokens", padding = 2)
  system2("xelatex",
          args = c("'\\input extractor \\input extractor-tmp.tex'"),
          stdout = FALSE)
  msg_ok("Tokens created", padding = 2)
}

globalVariables("text")
#' @importFrom utils read.delim
read_tokens = function() {
  tokens = read.delim("extractor.csv", sep = "|",
                      header = FALSE,
                      col.names = c("X1", "X2", "X3"),
                      stringsAsFactors = FALSE)

  tibble::as_tibble(tokens)
}
