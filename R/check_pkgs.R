# Check packages up to date
# Hack to detect internet connection on laptops
#' @importFrom utils available.packages installed.packages
#' @importFrom dplyr left_join
#' @importFrom tibble as_tibble
#' @importFrom utils install.packages
check_pkgs = function() {
  if (httr::GET("www.google.com")$status != 200) {
    message(blue("No internet connection - skipping PKG check"))
    return(invisible(NULL))
  }
  message(yellow(circle_filled, "Checking package versions...check_pkgs()"))
  r = getOption("repos")
  jr_pkgs = "https://jr-packages.github.io/drat/"
  if (!(jr_pkgs %in% r)) {
    r["jrpackages"] = jr_pkgs
    options(repos = r)
  }
  if (!is_legacy()) {
    language = get_repo_language()
    if (language == "r") {
      pkgs = get_r_pkg_name()
    } else {
      pkgs = "reticulate"
    }
  }

  pkgs_to_update = c(pkgs, "jrNotes", "jrPresentation",
                     "knitr", "rmarkdown", "lintr", "tufte",
                     "ggplot2", "dplyr")

  av_p =  available.packages()[, c("Package", "Version")]
  av_p = tibble::as_tibble(av_p)
  av_p = av_p[av_p$Package %in% pkgs_to_update, ]

  in_p = installed.packages()
  in_p = tibble::as_tibble(in_p)[, c("Package", "Version")]
  in_p = in_p[in_p$Package %in% pkgs_to_update, ]

  pkgs = dplyr::left_join(av_p, in_p, by = "Package")
  pkgs$Version.y[is.na(pkgs$Version.y)] = "0.0.0"
  for (i in seq_len(nrow(pkgs))) {
    if (package_version(pkgs$Version.x[i]) > package_version(pkgs$Version.y[i])) {
      msg = glue("  {cross} Update {pkgs$Package[i]}: {pkgs$Version.x[i]} > {pkgs$Version.y[i]}") #nolint
      message(red(msg))
    } else {
      msg = glue("  {tick} {pkgs$Package[i]} (v{pkgs$Version.x[i]}) is up to date")
      message(yellow(msg))
    }
  }

  to_update = package_version(pkgs$Version.x) > package_version(pkgs$Version.y)
  if (sum(to_update) == 0 || nchar(Sys.getenv("GITLAB_CI")) != 0) {
    return(invisible(NULL))
  }
  m = glue("{info} Automatically updating packages")
  message(red(m))
  install.packages(pkgs$Package[to_update])
  clean()

  stop(red("Packages have been updated. Please run make final again"), call. = FALSE)
}
