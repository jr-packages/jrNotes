#' @title Check PKG and Notes title
#' @description Package title should start with "Jumping Rivers: ".
#' Notes and Package titles should then be the same (excluding "Jumping Rivers : ").
#' @importFrom utils packageDescription 
#' @importFrom stringr str_remove_all str_squish str_starts str_remove
#' @export
check_pkgtitle = function() {
  language = get_repo_language()
  if (language == "r") {
    r_pkg = get_r_pkg_name()
    pkg_title = packageDescription(r_pkg)$Title
  } else {
    cli::cli_alert_info("Checking PKG titles only implemented for R")
    return(NULL)
  }

  msg_start("Checking PKG title matches course title...check_pkgtitle()")
  con = config::get()
  # Remove line breaks
  notes_title = stringr::str_remove_all(con$front, pattern = "\\\\")
  notes_title = stringr::str_squish(notes_title)
  # Check PKG title starts with "Jumping Rivers: "
  if (stringr::str_starts(pkg_title, pattern = "Jumping Rivers: ", negate = TRUE)) {
    msg_error("PKG title should start with 'Jumping Rivers: '", stop = FALSE)
    set_error()
    return(invisible(NULL))
  }

  # Check pkg titles match
  pkg_title = stringr::str_remove(pkg_title, "Jumping Rivers: ")
  if (pkg_title != notes_title) {
    msg = glue::glue("PKG title should be 'Jumping Rivers: {notes_title}' \\
                     instead of 'Jumping Rivers: {pkg_title}'")
    msg_error(msg, stop = FALSE)
    set_error()
    return(invisible(NULL))
  }

  msg_ok("PKG titles look good!")
  return(invisible(NULL))
}
