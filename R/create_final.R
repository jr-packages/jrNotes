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

#' @importFrom praise praise
#' @importFrom qpdf pdf_combine
create_final_dir = function(note_name, pracs) {
  check_master()
  check_template()
  check_pkgs()
  # #
  check_spelling()
  tokenise()
  check_chapter_titles()
  check_section_titles()
  check_fullstops()
  # # Latex checks
  check_latex()
  # Check urls
  check_urls()
  # Check lint
  check_code_style() # nolint
  # Check version number
  check_version()
  check_unstaged()

  if (isTRUE(.jrnotes$error)) {
    stop("Please fix errors", call. = FALSE)
  }
  dir.create("final", showWarnings = FALSE)
  # Remove old notes/practicals
  file.remove(list.files("final", full.names = TRUE))
  # add notes
  notes_loc = glue("final/notes_{note_name}_{Sys.Date()}.pdf")
  fs::file_copy("main.pdf", notes_loc, overwrite = TRUE)
  msg = glue_col("{yellow}{symbol$tick} Created {notes_loc}")
  message(msg)

  if (fs::file_size(notes_loc) < 50) {
    msg = glue_col("{yellow}{symbol$tick} The notes look suspiciously small!")
  }

  # combine practicals into single file
  prac_loc = glue("final/practicals_{note_name}_{Sys.Date()}.pdf")
  qpdf::pdf_combine(pracs, prac_loc)
  msg = glue_col("{yellow}{symbol$tick} Created {prac_loc}")
  message(msg)
  if (fs::file_size(prac_loc) < 50) {
    msg = glue_col("{blue}{symbol$tick} The practicals look suspiciously small!")
  }

  message(green(symbol$star, symbol$star, praise::praise(),
                symbol$star, symbol$star))
  return(invisible(NULL))
}

#' @export
#' @rdname create_final
get_python_pkg_name = function() {
  con = config::get()
  pkgs = unlist(con$packages)
  names(pkgs) = NULL
  pkgs
}

#' @export
#' @rdname create_final
get_r_pkg_name = function() {
  # New style - use the config file
  if (!is_legacy()) {
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

check_pkg_vignettes = function(pkg, pkg_loc) {
  if (fs::dir_exists(file.path(pkg_loc, "doc"))) return(invisible(NULL))
  msg = glue::glue("{symbol$cross} The package {pkg} doesn't seem to have vignettes.
                   Try building and installing the package from source. Or
                   use install.packages and install from the repo.
                   Note: Standard build and install doesn't create vignettes.")
  message(red(msg))
  stop(call. = FALSE)
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
  note_name = get_concat_course_name()
  if (!is_legacy() && isFALSE(config::get()$vignettes)) {
    pracs = NULL
  } else {
    pkg = get_r_pkg_name()
    pkg_loc = system.file(package = pkg) #nolint
    check_pkg_vignettes(pkg, pkg_loc)
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
