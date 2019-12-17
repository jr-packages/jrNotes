bash_rm = function(args) {
  system2("rm", args = c("-fvr", args))
}

#' Functions for cleaning after notes and slides
#'
#' Use in the Makefile
#' @export
clean = function() {
  latex_gen = c("*.aux", "*.dvi", "*.log", "*.toc",
                "*.bak", "*~", "*.blg", "*.bbl", "*.lot",
                "*.lof", "*.nav", "*.snm", "*.out", "*.pyc",
                "*.vrb", "*.fdb_latexmk", "*.fls", "*.xwm")
  bash_rm(latex_gen)
  r_gen = c("Rplots.pdf", "*.RData", "main.pdf", "*_files", "*_cache",
            "final/", "main.tex", "*.html", "_figure/",
            "_*\\.knit\\.md", "_*\\.utf8\\.md", "_book")
  bash_rm(r_gen)
  left_over = c("\\#*\\#")
  bash_rm(left_over)
  python_gen = c("venv/", "requirements.txt")
  bash_rm(python_gen)
}

#' @rdname clean
#' @export
cleaner = function() {
  ## jrNotes generated
  jr_notes_generated = c("logo.png", "jrStyle.sty", "titlepage.tex",
                         "advert.tex", "robot.jpg", "rstudio_logo.png",
                         "knitr.sty", "style.css", "libs/",
                         "feedback.Rmd", "feedback.html",
                         "feedback_link.txt", "WORDLIST",
                         "extractor-tmp.tex", "extractor.csv",
                         "extractor.pdf", "extractor.tex",
                         "course-dependencies.tex", "dependencies.png")
  jr_notes_generated = jr_notes_generated[file.exists(jr_notes_generated)]
  bash_rm(jr_notes_generated)
}
