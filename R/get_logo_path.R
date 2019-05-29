#' Create and get helper files
#'
#' Get logos, sty files and title pages
#' @export
get_logos = function() {
  fname = system.file("extdata",
                      c("robot.jpg", "logo.png", "rstudio_logo.png"),
                      package = "jrNotes",
                      mustWork = TRUE)
  file.copy(fname[1], to = "robot.jpg", overwrite = TRUE)
  file.copy(fname[2], to = "logo.png", overwrite = TRUE)
  file.copy(fname[3], to = "rstudio_logo.png", overwrite = TRUE)
}

#' @param main Front page title
#' @param running Running title
#' @param rss RSS boolean
#' @rdname get_logos
#' @export
create_title_page = function(main = NULL, running = NULL, rss = NULL) {
  if (is.null(main)) main = config::get("front")
  if (is.null(running)) running = config::get("running")
  if (is.null(rss)) rss = config::get("rss")
  rss = isTRUE(rss)

  if (rss) {
    rss = "Accredited by the Royal Statistical Society."
  } else {
    rss = ""
  }

  get_logos()
  client = Sys.getenv("CLIENT")
    title_str = paste0("
\\newsavebox{\\titleimage}
\\savebox{\\titleimage}{\\includegraphics[width=1.2\\textwidth]{logo.png}}
\\title[", running, "]{%
  \\setlength{\\parindent}{0pt}%
  ", main, " \\par \\vspace{4cm}
  \\usebox{\\titleimage}}
\\author[jumpingrivers.com]{", client, "}
\\publisher{\\href{http://www.jumpingrivers.com}{jumpingrivers.com} \\newline ", rss, "}") #nolint
  cat(title_str, file = "titlepage.tex")
}

#' @export
#' @rdname  get_logos
create_jrStyle = function() {
  fname = system.file("extdata", "jrStyle.sty",
                      package = "jrNotes", mustWork = TRUE)
  file.copy(fname, to = "jrStyle.sty", overwrite = TRUE)
}

create_advert = function() {
  fname = system.file("extdata",
                      "advert.tex",
                      package = "jrNotes",
                      mustWork = TRUE)
  file.copy(fname, to = "advert.tex", overwrite = TRUE)
}

#' @export
#' @rdname  get_logos
create_version = function() {
  create_githook()

  year = substr(Sys.Date(), 1, 4) #nolint
  if (fs::file_exists("config.yml")) {
    con = config::get()
    version = con$version
  } else {
    version = readLines("VERSION")
  }

  version_dots = strsplit(version, split = "\\.")[[1]]
  if (length(version_dots) != 3) {
    stop("Version should take the form of X.Y.Z", call. = FALSE)
  }
  version_str = glue("\\begin{table}[!b]
     Version <version>\\hfill \\textcopyright Jumping Rivers Ltd <year>
     \\end{table}", .open = "<", .close = ">")
  version_str
}
