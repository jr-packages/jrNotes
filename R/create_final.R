# Old notes don't have config. Quick helper function
is_legacy = function() !fs::file_exists("config.yml")


get_git_url = function(dir = ".") {
  fname = glue("{dir}/.git/config")
  if (!file.exists(fname)) {
    git_url = get_git_url(glue("../{dir}"))
    return(git_url)
  }
  git_config = file(fname)
  on.exit(close(git_config))
  l = readLines(git_config)
  l[grep(pattern = "\turl", l)]
}

# Don't allow duplicate labels
label_check = function() {
  if (!file.exists("main.log")) return()

  main_log = readLines("main.log")
  labels = str_detect(main_log,
                      pattern = "^LaTeX Warning: Label .* multiply defined\\.$")

  if (sum(labels) == 0) return()

  stop("Multiply defined labels: \n",
       paste(main_log[labels], collapse = "\n"),
       call. = FALSE)
}

#' @importFrom qpdf pdf_combine
create_final_dir = function(note_name, pracs) {
  label_check()

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
get_python_pkg_name = function() {
  con = config::get()
  pkgs = unlist(con$packages)
  names(pkgs) = NULL
  pkgs = paste(pkgs, collapse = "\n")
}


#' @export
#' @rdname create_final
get_r_pkg_name = function() {
  # New style - use the config file
  if (fs::file_exists("config.yml")) {
    con = config::get()
    if (!is.null(con$packages)) {
      pkgs = unlist(con$packages)
      names(pkgs) = NULL
      return(pkgs)
    }
  }
  # XXX: Legacy - grep gitlab url
  git_url = get_git_url()
  pkg = stringr::str_match(git_url, "course_notes/(.*)/(.*)_notes\\.git$")
  pkg[, length(pkg)]
}


# Replace spaces with -
get_concat_course_name = function() {
  if (!is_legacy()) {
    con = config::get()
    title = con$running
    title = gsub(" ", "-", title)
  } else {
    # XXX: Fall back for old notes
    title = get_r_pkg_name()
  }
  return(title)
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
  note_name = get_concat_course_name()

  if (!is_legacy() && isFALSE(config::get()$vignettes)) {
    pracs = NULL
  } else {
    pkg = get_r_pkg_name()
    pkg_loc = system.file(package = pkg) #nolint
    pracs = dir_ls(path = glue("{pkg_loc}/doc"),
                   regexp = ".*practical.*\\.pdf$")
  }
  if (is_legacy()) {
    note_name = stringr::str_sub(get_r_pkg_name(), 3)
  }

  create_final_dir(note_name = note_name, pracs = pracs)
}

#' @rdname create_final
#' @export
create_final_python = function() {
  # check_pdftk() # nolint

  if (fs::file_exists("config.yml"))  {
    pkg = get_python_pkg_name()
  } else {
    git_url = get_git_url()
    pkg = stringr::str_match(git_url, "course_notes/(.*)/jr(.*)_python_notes.git") #nolint
    pkg = paste0("jrpy", tolower(pkg[, length(pkg)]))
  }
  ## locate vignettes in package
  dirs = list.dirs(full.names = TRUE)
  dirs = dirs[grepl(pkg, dirs)]
  dirs = dirs[grepl("vignettes", dirs)]
  pracs = fs::dir_ls(path = dirs, regexp = ".*practical.*\\.pdf$")
  # pracs = glue_collapse(pracs, sep = " ") #nolint
  create_final_dir(note_name = stringr::str_sub(pkg, 5), pracs = pracs)
}
