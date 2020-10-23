#' @importFrom praise praise
#' @importFrom qpdf pdf_combine
create_final_dir = function(note_name, pracs) {
  # This will start our cli theme.
  # Will auto-close at the end of this function
  cli::start_app(theme = get_cli_theme())

  cli::cli_rule("jrNotes v{packageVersion('jrNotes')}")
  cli::cli_h2("Checking Core files")
  check_master()
  check_template()
  check_pkgs()

  cli::cli_h2("Checking Notes")
  check_spelling()
  tokenise()
  check_chapter_titles()
  check_section_titles()
  check_fullstops()
  check_urls()
  check_latex()
  check_code_style()

  cli::cli_h2("Checking live")
  check_live()
  create_live_scripts()

  cli::cli_h2("Checking meta files")
  check_news()
  check_pkgtitle()
  check_config()
  check_version()
  check_unstaged()

  if (isTRUE(.jrnotes$error)) {
    msg_error("Please fix errors")
    msg_error(.jrnotes$error_funs)
    stop()
  }
  msg_start("Creating pdf outputs...")
  dir.create("final", showWarnings = FALSE)
  # Remove old notes/practicals
  file.remove(list.files("final", full.names = TRUE))
  # add notes
  notes_loc = glue("final/notes_{note_name}_{Sys.Date()}.pdf")
  fs::file_copy("main.pdf", notes_loc, overwrite = TRUE)
  msg_success(glue("Created {notes_loc}"), padding = TRUE)

  if (fs::file_size(notes_loc) < 50) {
    msg_warning("The notes look suspiciously small!", padding = TRUE)
  }

  # combine practicals into single file
  prac_loc = glue("final/practicals_{note_name}_{Sys.Date()}.pdf")
  qpdf::pdf_combine(pracs, prac_loc)
  msg_success(glue("Created {prac_loc}"), padding = TRUE)
  if (fs::file_size(prac_loc) < 50) {
    msg_warning("The practicals look suspiciously small!", padding = TRUE)
  }
  msg_success("PDF outputs created in final/")

  message(green("\n\n", star, star, praise::praise(), star, star))
  return(invisible(NULL))
}


#' @export
#' @rdname create_final
get_deb_pkgs = function() {
  con = config::get()
  pkgs = unlist(con$deb_packages)
  return(pkgs)
}

#' @export
#' @rdname create_final
get_python_pkg_name = function() {
  con = config::get()
  pkgs = unlist(con$python_packages)
  return(pkgs)
}

#' @export
#' @rdname create_final
get_r_pkg_name = function() {
  con = config::get()
  pkgs = unlist(con$r_packages)
  return(pkgs)
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
#' @importFrom stringr str_sub
#' @importFrom glue glue
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
