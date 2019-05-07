check_pdftk = function() {
  is_pdftk = suppressWarnings(system2("which", "pdftk", stdout = TRUE, stderr = FALSE))
  if (length(is_pdftk) == 0L) {
    stop("Need pdftk to combine practicals - pdfhacks.com/pdftk/",
         call. = FALSE)
  }
}

get_git_url = function() {
  git_config = file("../.git/config")
  on.exit(close(git_config))
  l = readLines(git_config)
  l[grep(pattern = "\turl", l) ]
}

create_final_dir = function(note_name, pracs) {

  dir.create("final", showWarnings = FALSE)
  # add attendance sheet
  sheet = system.file("attendance/attendance.pdf", package = "jrNotes")
  fs::file_copy(sheet, glue("final/attendance_{note_name}.pdf"), overwrite = TRUE)
  fs::file_copy("main.pdf", glue("final/notes_{note_name}.pdf"), overwrite = TRUE)

  cmd = glue("pdftk {pracs} cat output final/practicals_{note_name}.pdf")
  system(cmd)
}

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
  check_pdftk()
  git_url = get_git_url()

  pkg = stringr::str_match(git_url, "course_notes/(.*)/(.*)_notes.git")
  pkg = pkg[, length(pkg)]

  pkg_loc = system.file(package = pkg)
  pracs = fs::dir_ls(path = glue("{pkg_loc}/doc"), regexp = ".*practical.*\\.pdf$")
  pracs = glue_collapse(pracs, sep = " ")
  create_final_dir(note_name = stringr::str_sub(pkg, 3), pracs = pracs)
}

#' @rdname create_final
#' @export
create_final_python = function() {
  check_pdftk()
  git_url = get_git_url()

  pkg = stringr::str_match(git_url, "course_notes/(.*)/jr(.*)_python_notes.git")
  pkg = paste0("jrpy", tolower(pkg[,length(pkg)]))

  ## locate vignettes in package
  dirs = list.dirs(full.names = TRUE)
  dirs = dirs[grepl(pkg, dirs)]
  dirs = dirs[grepl('vignettes', dirs)]
  pracs = fs::dir_ls(path = dirs, regexp = ".*practical.*\\.pdf$")
  pracs = glue_collapse(pracs, sep = " ")
  create_final_dir(note_name = stringr::str_sub(pkg, 5), pracs = pracs)
}
