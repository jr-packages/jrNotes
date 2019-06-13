# check_pdftk = function() {
#   is_pdftk = suppressWarnings(system2("which", "pdftk",
#                                       stdout = TRUE, stderr = FALSE))
#   if (length(is_pdftk) == 0L) {
#     stop("Need pdftk to combine practicals - pdfhacks.com/pdftk/",
#          call. = FALSE)
#   }
# }

get_git_url = function(dir = ".") {
  fname = glue("{dir}/.git/config")
  if (!file.exists(fname)) {
    git_url = get_git_url(glue("../{dir}"))
    return(git_url)
  }
  git_config = file(fname)
  on.exit(close(git_config))
  l = readLines(git_config)
  l[grep(pattern = "\turl", l) ]
}

#' @importFrom qpdf pdf_combine
create_final_dir = function(note_name, pracs) {

  dir.create("final", showWarnings = FALSE)
  # add attendance sheet
  sheet = system.file("attendance/attendance.pdf", package = "jrNotes")
  fs::file_copy(sheet,
                glue("final/attendance_{note_name}.pdf"),
                overwrite = TRUE)
  # add notes
  fs::file_copy("main.pdf",
                glue("final/notes_{note_name}.pdf"),
                overwrite = TRUE)
  # combine practicals into single file
  qpdf::pdf_combine(pracs, glue("final/practicals_{note_name}.pdf"))
  return(invisible(NULL))
}

#' @export
#' @rdname create_final
get_r_pkg_name = function() {
  git_url = get_git_url()
  pkg = stringr::str_match(git_url, "course_notes_?2?/(.*)/(.*)_notes\\.git$")
  pkg[, length(pkg)]
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
  ## check_pdftk() #nolint
  pkg = get_r_pkg_name()
  pkg_loc = system.file(package = pkg) #nolint
  pracs = fs::dir_ls(path = glue("{pkg_loc}/doc"),
                     regexp = ".*practical.*\\.pdf$")
  #pracs = glue_collapse(pracs, sep = " ") #nolint
  create_final_dir(note_name = stringr::str_sub(pkg, 3), pracs = pracs)
}

#' @rdname create_final
#' @export
create_final_python = function() {
  # check_pdftk() # nolint
  git_url = get_git_url()

  pkg = stringr::str_match(git_url, "course_notes/(.*)/jr(.*)_python_notes.git")
  pkg = paste0("jrpy", tolower(pkg[, length(pkg)]))

  ## locate vignettes in package
  dirs = list.dirs(full.names = TRUE)
  dirs = dirs[grepl(pkg, dirs)]
  dirs = dirs[grepl("vignettes", dirs)]
  pracs = fs::dir_ls(path = dirs, regexp = ".*practical.*\\.pdf$")
  # pracs = glue_collapse(pracs, sep = " ") #nolint
  create_final_dir(note_name = stringr::str_sub(pkg, 5), pracs = pracs)
}
