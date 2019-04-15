#' Create copy of notes and practicals
#'
#' Renames main.pdf to notes_pkg.pdf. Also retrieves
#' the practials from the package and combines them.
#' @importFrom fs dir_ls file_copy
#' @importFrom utils vignette
#' @import stringr
#' @import glue
#' @export
create_final = function() {
  is_pdftk = suppressWarnings(system2("which", "pdftk", stdout = TRUE, stderr = FALSE))
  if(length(is_pdftk) == 0L) {
    stop("Need pdftk to combine practicals - pdfhacks.com/pdftk/",
         call. = FALSE)
  }
  git_config = file("../.git/config")
  on.exit(close(git_config))
  l = readLines(git_config)
  git_url = l[grep(pattern = "\turl", l) ]

  pkg = stringr::str_match(git_url, "course_notes/(.*)/(.*)_notes.git")
  pkg = pkg[,length(pkg)]
  x = vignette(package = pkg)
  dir.create("final", showWarnings = FALSE)
  pkg_loc = system.file(package = pkg)
  pracs = fs::dir_ls(path = glue("{pkg_loc}/doc"), regexp = ".*practical.*\\.pdf$")
  pracs = glue_collapse(pracs, sep = " ")

  # add attendance sheet
  sheet = system.file("attendance/attendance.pdf", package = "jrNotes")
  notes_name = stringr::str_sub(pkg, 3)
  fs::file_copy(sheet, glue("final/attendance_{notes_name}.pdf"), overwrite = TRUE)
  fs::file_copy("main.pdf", glue("final/notes_{notes_name}.pdf"), overwrite = TRUE)
  cmd = glue("pdftk {pracs} cat output final/practicals_{notes_name}.pdf")
  system(cmd)
}

#' Create copy of notes and practicals
#'
#' Renames main.pdf to notes_pkg.pdf. Also retrieves
#' the practials from the package and combines them.
#' @importFrom fs dir_ls file_copy
#' @importFrom utils vignette
#' @import glue
#' @import stringr
#' @export
create_final_python = function() {
  is_pdftk = suppressWarnings(system2("which", "pdftk", stdout = TRUE, stderr = FALSE))
  if(length(is_pdftk) == 0L) {
    stop("Need pdftk to combine practicals - pdfhacks.com/pdftk/",
         call. = FALSE)
  }
  git_config = file("../.git/config")
  on.exit(close(git_config))
  l = readLines(git_config)
  git_url = l[grep(pattern = "\turl", l) ]

  pkg = stringr::str_match(git_url, "course_notes/(.*)/jr(.*)_python_notes.git")
  pkg = paste0("jrpy",tolower(pkg[,length(pkg)]))
  # locate vignettes in package
  dirs = list.dirs(full.names = TRUE)
  dirs = dirs[grepl(pkg,dirs)]
  dirs = dirs[grepl('vignettes',dirs)]
  pracs = fs::dir_ls(path = dirs, regexp = ".*practical.*\\.pdf$")
  # x = vignette(package = pkg)
  dir.create("final", showWarnings = FALSE)
  # pkg_loc = system.file(package = pkg)
  # pracs = fs::dir_ls(path = glue("{pkg_loc}/doc"), regexp = ".*practical.*\\.pdf$")
  pracs = glue_collapse(pracs, sep = " ")

  # add attendance sheet
  sheet = system.file("attendance/attendance.pdf", package = "jrNotes")
  notes_name = stringr::str_sub(pkg, 5)
  fs::file_copy(sheet, glue("final/attendance_{notes_name}.pdf"), overwrite = TRUE)
  fs::file_copy("main.pdf", glue("final/notes_{notes_name}.pdf"), overwrite = TRUE)
  cmd = glue("pdftk {pracs} cat output final/practicals_{notes_name}.pdf")
  system(cmd)
}
