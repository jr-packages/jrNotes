#' Create copy of notes and practicals
#'
#' Renames main.pdf to notes_pkg.pdf. Also retrieves
#' the practials from the package and combines them.
#' @importFrom fs dir_ls file_copy
#' @importFrom utils vignette
#' @import stringr
#' @export
create_final = function() {
  git_config = file("../.git/config")
  on.exit(close(git_config))
  l = readLines(git_config)
  git_url = l[grep(pattern = "\turl", l) ]

  pkg = stringr::str_match(git_url, "course_notes/(.*)_notes.git")[,2]
  x = vignette(package = pkg)
  dir.create("final", showWarnings = FALSE)
  pkg_loc = system.file(package = pkg)
  pracs = fs::dir_ls(path = glue("{pkg_loc}/doc"), regexp = ".*practical.*\\.pdf$")
  pracs = glue_collapse(pracs, sep = " ")

  notes_name = stringr::str_sub(pkg, 3)
  fs::file_copy("main.pdf", glue("final/notes_{notes_name}.pdf"), overwrite = TRUE)
  cmd = glue("pdftk {pracs} cat output final/practicals_{notes_name}.pdf")
  system(cmd)
}
