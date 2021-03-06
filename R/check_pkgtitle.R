#' @title Check PKG and Notes title
#' @description Package title should start with "Jumping Rivers: ".
#' Notes and Package titles should then be the same (excluding "Jumping Rivers: ").
#' @importFrom stringr str_remove_all str_squish str_starts str_remove
#' @export
check_pkgtitle = function() {
  msg_start("Checking PKG title matches course title...check_pkgtitle()")

  language = get_repo_language()
  if (language == "r") {
    r_pkg = get_r_pkg_name()
    pkg_title = utils::packageDescription(r_pkg)$Title
  } else if (language == "python") {
    python_pkg = get_python_pkg_name()
    pkg_title = system2("pip", args = c("show", python_pkg,
                                        "|", "sed", "-n", "-e", "'s/Summary: //p'"),
                        stdout = TRUE)
  } else {
    cli::cli_alert_info("Checking PKG titles not implemented for {language}.")
    return(NULL)
  }

  con = get_config()
  # Remove line breaks
  notes_title = stringr::str_remove_all(con$front, pattern = "\\\\")
  notes_title = stringr::str_squish(notes_title)
  # Check PKG title starts with "Jumping Rivers: "
  if (stringr::str_starts(pkg_title, pattern = "Jumping Rivers: ", negate = TRUE)) {
    msg_error("PKG title should start with 'Jumping Rivers: '")
    return(invisible(NULL))
  }

  # Check pkg titles match
  pkg_title = stringr::str_remove(pkg_title, "Jumping Rivers: ")
  if (pkg_title != notes_title) {
    msg = glue::glue("PKG title should be 'Jumping Rivers: {notes_title}' \\
                     instead of 'Jumping Rivers: {pkg_title}'")
    msg_error(msg)
    return(invisible(NULL))
  }

  msg_success("PKG titles look good!")
  return(invisible(NULL))
}
