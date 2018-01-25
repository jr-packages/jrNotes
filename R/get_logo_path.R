#' Latex style and title pages
#'
#' Returns path to logo
#' @export
get_logo_path = function() {
  system.file("extdata", "logo.png", package = "jrNotes", mustWork = TRUE)
}

#' @param main Front page title
#' @param running Running title
#' @rdname  get_logo_path
#' @export
create_title_page = function(main, running) {

  logo_path = get_logo_path()
  title_str = paste0("
\\newsavebox{\\titleimage}
\\savebox{\\titleimage}{\\includegraphics[width=1.2\\textwidth]{", logo_path, "}}
\\title[", running, "]{%
  \\setlength{\\parindent}{0pt}%
  ", main, " \\par \\vspace{4cm}
  \\usebox{\\titleimage}}
\\author[jumpingrivers.com]{}
\\publisher{jumpingrivers.com}")
  cat(title_str,file="titlepage.tex")
}

#' @export
#' @rdname  get_logo_path
create_jrStyle = function() {
  fname = system.file("extdata", "jrStyle.sty", package = "jrNotes", mustWork = TRUE)
  file.copy(fname, to = "jrStyle.sty", overwrite = TRUE)
}

#' @export
#' @rdname  get_logo_path
create_version = function() {
  version_str = paste0("
\\begin{table}[!b]
Version ", readLines("VERSION"), "
  \\end{table}")
  version_str
}

