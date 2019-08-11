check_master = function() {
  if (httr::GET("www.google.com")$status != 200) {
    message(yellow("No internet connection - skipping URL check"))
    return(invisible(NULL))
  }
  ## Needed for runner
  system2("git", args = c("fetch", "origin"))

  message(yellow(symbol$circle_filled, "Comparing to master"))
  g = system2("git",
              args = c("rev-list --left-right --count origin/master...@"),
              stdout = TRUE)

  master_commits = strsplit(g, split = "\t")[[1]][1]

  if (master_commits > 0) {
    msg = red(glue("{symbol$cross} Master ahead; git pull"))
    stop(msg, call. = FALSE)
  }
  message(yellow(symbol$tick, "Update to date with master"))
  return(invisible(NULL))
}

# Check packages up to date
# Hack to detect internet connection on laptops
#' @importFrom utils available.packages installed.packages
#' @importFrom dplyr left_join
#' @importFrom tibble as_tibble
check_pkgs = function() {
  if (httr::GET("www.google.com")$status != 200) {
    message(yellow("No internet connection - skipping URL check"))
    return(invisible(NULL))
  }
  message(yellow(symbol$circle_filled, "Checking package versions"))

  r = getOption("repos")
  jr_pkgs = "https://jr-packages.github.io/drat/"
  if (!(jr_pkgs %in% r)) {
    r["jrpackages"] = jr_pkgs
    options(repos = r)
  }
  if (!is_legacy()) {
    con = config::get()
    if (!isTRUE(con$python3)) {
      pkgs = get_r_pkg_name()
    } else {
      pkgs = "reticulate"
    }
  }

  pkgs_to_update = c(pkgs, "jrNotes", "jrPresentation",
                     "knitr", "rmarkdown", "lintr", "tufte",
                     "ggplot2")

  av_p =  available.packages()[, c("Package", "Version")]
  av_p = tibble::as_tibble(av_p)
  av_p = av_p[av_p$Package %in% pkgs_to_update, ]

  in_p = installed.packages()
  in_p = tibble::as_tibble(in_p)[, c("Package", "Version")]
  in_p = in_p[in_p$Package %in% pkgs_to_update, ]

  pkgs = dplyr::left_join(av_p, in_p, by = "Package")
  for (i in seq_len(nrow(pkgs))) {
    if (package_version(pkgs$Version.x[i]) > package_version(pkgs$Version.y[i])) {
      msg = glue("\t{symbol$cross} Update {pkgs$Package[i]}: {pkgs$Version.x[i]} > {pkgs$Version.y[i]}") #nolint
      message(red(msg))
    } else {
      msg = glue("\t{symbol$tick} {pkgs$Package[i]} (v{pkgs$Version.x[i]}) is up to date")
      message(yellow(msg))
    }
  }

  to_update = package_version(pkgs$Version.x) > package_version(pkgs$Version.y)
  if (sum(to_update) == 0 || nchar(Sys.getenv("GITLAB_CI")) != 0) {
    return(invisible(NULL))
  }
  stop(red("Please update packages"), call. = FALSE)
}

#' @importFrom httr GET
#' @import crayon cli
check_urls = function() {

  if (!file.exists("main.tex")) stop("main.tex not found", call. = FALSE)
  # Hack to detect internet connection on laptops
  if (httr::GET("www.google.com")$status != 200) {
    message(yellow("No internet connection - skipping URL check"))
    return(invisible(NULL))
  }
  message(yellow(symbol$circle_filled, "Checking URLS"))
  main_tex = readLines("main.tex")

  urls = stringr::str_match_all(main_tex, "\\\\url\\{([^\\}]*)\\}") #nolint
  urls = unlist(urls)
  urls = urls[!stringr::str_detect(urls, "\\{")]

  bad_urls = FALSE
  for (url in urls) {
    message("  ", yellow(symbol$circle_filled, "Checking ", url))
    status = GET(url)$status
    if (status != 200) {
      msg = glue("  {symbol$cross} {url}  status: {status}")
      message(red(msg))
    }
    if (status == 404) {
      bad_urls = TRUE
    }
  }
  if (bad_urls) stop(red("Fix broken URLS"), call. = FALSE)
  message(yellow(symbol$tick, "URLs look good"))
  return(invisible(NULL))
}

# Don't allow duplicate labels
check_labels = function() {
  if (!file.exists("main.log")) return()
  message(yellow(symbol$circle_filled, "Checking for duplicate labels"))

  main_log = readLines("main.log")
  labels = str_detect(main_log,
                      pattern = "^LaTeX Warning: Label .* multiply defined\\.$")

  if (sum(labels) == 0) {
    message(yellow(symbol$tick, "Labels look good"))
    return(invisible(NULL))
  }
  stop(red("Multiply defined labels: \n"),
       paste(main_log[labels], collapse = "\n"),
       call. = FALSE)
}

# Don't undefined references
# e.g. Reference `fig:row-layout' on page 25 undefined on input line 1509
check_references = function() {

  if (!file.exists("main.log")) return()
  message(yellow(symbol$circle_filled, "Checking for undefined refs"))

  main_log = readLines("main.log")
  refs = stringr::str_detect(main_log,
                             pattern = "undefined on input line")

  if (sum(refs) == 0) {
    message(yellow(symbol$tick, "Refs look good"))
    return(invisible(NULL))
  }
  stop("\n", red(glue("{symbol$cross} Underfined refs")), "\n",
       red(paste(main_log[refs], collapse = "\n")),
       call. = FALSE)
}

check_python = function() {
  if (is_legacy()) return(invisible(NULL))
  con = config::get()
  if (!isTRUE(con$python3)) return(invisible(NULL))
  message(yellow(symbol$circle_filled, "Checking python version"))

  if (!isTRUE(nchar(con$knitr$engine.path) > 2)) {
    stop(red("knitr Python engine path fail"), call. = FALSE)

  }
  message(yellow(symbol$tick, "Python version looks good"))

}
