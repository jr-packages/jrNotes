pkgs_output = function(pkgs, i) {
  if (package_version(pkgs$Version.x[i]) > package_version(pkgs$Version.y[i])) {
    msg = glue("Update {pkgs$Package[i]}: {pkgs$Version.x[i]} > {pkgs$Version.y[i]}") #nolint
    if (is_gitlab()) {
      msg_info(msg, padding = TRUE)
    } else {
      msg_error(msg, padding = TRUE)
    }
  } else {
    msg = glue("{pkgs$Package[i]} (v{pkgs$Version.x[i]}) is up to date")
    msg_success(msg, padding = TRUE)
  }
  return(invisible(NULL))
}

# Check packages up to date
# Hack to detect internet connection on laptops
#' @importFrom utils available.packages installed.packages
#' @importFrom dplyr left_join
#' @importFrom tibble as_tibble
#' @importFrom utils install.packages
check_pkgs = function() {
  msg_start("Checking package versions...check_pkgs()")
  if (httr::GET("www.google.com")$status != 200) {
    msg_info("No internet connection - skipping PKG check")
    return(invisible(NULL))
  }
  r = getOption("repos")
  jr_pkgs = "https://jr-packages.github.io/drat/"
  if (!(jr_pkgs %in% r)) {
    r["jrpackages"] = jr_pkgs
    options(repos = r)
  }
  language = get_repo_language()
  if (language == "r") {
    pkgs = get_r_pkg_name()
  } else {
    pkgs = "reticulate"
  }

  pkgs_to_update = sort(c(pkgs, "jrNotes", "jrPresentation",
                     "knitr", "rmarkdown", "lintr", "tufte",
                     "ggplot2", "dplyr"))

  av_p = available.packages()[, c("Package", "Version")]
  av_p = tibble::as_tibble(av_p)
  av_p = av_p[av_p$Package %in% pkgs_to_update, ]

  in_p = installed.packages()
  in_p = tibble::as_tibble(in_p)[, c("Package", "Version")]
  in_p = in_p[in_p$Package %in% pkgs_to_update, ]

  pkgs = dplyr::left_join(av_p, in_p, by = "Package")
  pkgs$Version.y[is.na(pkgs$Version.y)] = "0.0.0"
  for (i in seq_len(nrow(pkgs))) {
    pkgs_output(pkgs, i)
  }

  to_update = package_version(pkgs$Version.x) > package_version(pkgs$Version.y)
  if (sum(to_update) == 0L || is_gitlab()) {
    msg_success("Package versions look good")
    return(invisible(NULL))
  }
  msg_info("Automatically updating packages", padding = TRUE)
  install.packages(pkgs$Package[to_update])
  msg_info("Packages have been updated")

  # Remove cached latex file
  if (file.exists("jrnotes_cache")) fs::dir_delete("jrnotes_cache/")
  return(invisible(NULL))
}
