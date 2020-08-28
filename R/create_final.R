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
  check_config()
  # Check lint
  check_code_style() # nolint
  # Check live
  check_live()
  create_live_scripts()
  # Check version number
  check_version()
  check_unstaged()

  check_news()
  check_pkgtitle()

  if (isTRUE(.jrnotes$error)) {
    stop("Please fix errors", call. = FALSE)
  }
  msg_start("Creating pdf outputs...")
  dir.create("final", showWarnings = FALSE)
  # Remove old notes/practicals
  file.remove(list.files("final", full.names = TRUE))
  # add notes
  notes_loc = glue("final/notes_{note_name}_{Sys.Date()}.pdf")
  fs::file_copy("main.pdf", notes_loc, overwrite = TRUE)
  msg_ok(glue("Created {notes_loc}"), padding = 2)

  if (fs::file_size(notes_loc) < 50) {
    msg_info("The notes look suspiciously small!", padding = 2)
  }

  # combine practicals into single file
  prac_loc = glue("final/practicals_{note_name}_{Sys.Date()}.pdf")
  qpdf::pdf_combine(pracs, prac_loc)
  msg_ok(glue("Created {prac_loc}"), padding = 2)
  if (fs::file_size(prac_loc) < 50) {
    msg_info("The practicals look suspiciously small!", padding = 2)
  }
  msg_ok("PDF outputs created in final/")

  message(green("\n\n", star, star, praise::praise(), star, star))
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
  con = config::get()
  if (!is.null(con$packages)) {
    pkgs = unlist(con$packages)
    names(pkgs) = NULL
    return(pkgs)
  }
}

# Replace spaces with -
get_concat_course_name = function() {
  con = config::get()
  title = con$running
  title = gsub(" ", "-", title)
  return(title)
}

check_pkg_vignettes = function(pkg, pkg_loc) {
  if (fs::dir_exists(file.path(pkg_loc, "doc"))) return(invisible(NULL))
  msg = glue::glue("{cross} The package {pkg} doesn't seem to have vignettes.
                   Try building and installing the package from source. Or
                   use install.packages and install from the repo.
                   Note: Standard build and install doesn't create vignettes.")
  msg_error(msg)
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
  if (isFALSE(config::get()$vignettes)) {
    pracs = NULL
  } else {
    pkg = get_r_pkg_name()
    pkg_loc = system.file(package = pkg) #nolint
    check_pkg_vignettes(pkg, pkg_loc)
    pracs = dir_ls(path = glue("{pkg_loc}/doc"),
                   regexp = ".*practical.*\\.pdf$")
  }
  create_final_dir(note_name = note_name, pracs = pracs)
}

#' @rdname create_final
#' @export
create_final_python = function() {

  pkg = get_python_pkg_name()
  ## locate vignettes in package
  dirs = list.dirs(full.names = TRUE)
  dirs = dirs[grepl(pkg, dirs)]
  dirs = dirs[grepl("vignettes", dirs)]
  pracs = fs::dir_ls(path = dirs, regexp = ".*practical.*\\.pdf$")
  # pracs = glue_collapse(pracs, sep = " ") #nolint
  create_final_dir(note_name = stringr::str_sub(pkg, 5), pracs = pracs)
}
