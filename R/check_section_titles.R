globalVariables(c("text", "texorpdf", "label", "footnote"))

latex_environments = function(title, title_case) {
  if (str_detect(string = title, "\\\\texttt \\{.*\\}")) { # nolint
    locs = str_locate(string = title, "\\\\texttt \\{.*\\}")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
  }
  if (str_detect(string = title, "\\\\textbf \\{.*\\}")) { # nolint
    locs = str_locate(string = title, "\\\\textbf \\{.*\\}")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
  }

  if (str_detect(string = title, ": [A-Z]")) { # nolint
    locs = str_locate(title[1], ": [A-Z]")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
  }
  if (title == title_case) return(title)
  else return(title_case)
}


#' @importFrom dplyr row_number
standard_exceptions = function(title, title_case) {
  from = c("r", "shiny", "dt", "rstudio", "anova", "uk", "usa",
           "html", "yaml", "csv", "python", "loocv", "oop", "esri",
           "geojson", "crs", "s3", "s4", "monte", "carlo", "ec2", "s3", "ram",
           "hdd", "ssd", "cpu", "starbucks", "james", "bond", "q-q",
           "ci", "travis", "git", "github", "gitlab", "i")
  to = c("R", "Shiny", "DT", "RStudio", "ANOVA", "UK", "USA",
         "HTML", "YAML", "CSV", "Python", "LOOCV", "OOP", "ESRI",
         "GeoJSON", "CRS", "S3", "S4", "Monte", "Carlo", "EC2", "S3", "RAM",
         "HDD", "SSD", "CPU", "Starbucks", "James", "Bond", "Q-Q", "CI", "Travis",
         "Git", "GitHub", "GitLab", "I")
  for (i in seq_along(from)) {
    # One word
    (title_case = str_replace(title_case,
                              paste0("^", str_to_title(from[i]), "$"),
                              to[i]))

    # Space either side
    (title_case = str_replace(title_case,
                              paste0(" ", from[i], " "),
                              paste0(" ", to[i], " ")))
    # End of heading
    (title_case = str_replace(title_case,
                              paste0(" ", from[i], "$"),
                              paste0(" ", to[i])))

    # Start of heading
    (title_case = str_replace(title_case,
                              paste0("^", str_to_title(from[i]), " "),
                              paste0(to[i], " ")))
    # Question marks
    (title_case = str_replace(title_case,
                              paste0(" ", from[i], "\\?"),
                              paste0(" ", to[i], "\\?")))

    # Ap marks
    (title_case = str_replace(title_case,
                              paste0(" ", from[i], "'"),
                              paste0(" ", to[i], "'")))

  }
  latex_environments(title, title_case)
}

check_section_titles = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  message(yellow(circle_filled,
                 "Checking section for sentence case...check_section_titles()"))
  if (!file.exists("extractor.csv")) return()

  tokens = read_tokens()
  tokens = tibble::as_tibble(tokens)
  sections = tokens %>%
    dplyr::filter(X1 %in% c("chapter", "section", "subsection")) %>%
    dplyr::mutate(id = row_number(),
                  texorpdf = str_detect(X3, "\\\\texorpdf"),
                  label = str_detect(X3, "\\\\label"),
                  footnote = str_detect(X3, "\\\\footnote")) %>% #nolint
    dplyr::mutate(text = X3) %>%
    dplyr::mutate(text = if_else(texorpdf,
                                 str_match(X3, "^\\\\texorpdfstring \\{(.*)\\}\\{.*\\}$")[, 2],
                                 text)) %>%
    dplyr::mutate(text = if_else(label,
                                 str_match(text, "(.*)\\W\\label .*")[, 2],
                                 text)) %>%
     dplyr::mutate(text = if_else(footnote,
                                  str_match(text, "(.*)\\\\footnote.*")[, 2],
                                  text)) %>%
    dplyr::mutate(text = str_trim(text))
  i = 1

  error = FALSE
  chapter_num = 1
  for (i in seq_len(nrow(sections))) {
    if (sections$X1[i] == "chapter") {
      msg = glue::glue("{circle_filled} Chapter {chapter_num}")
      message(yellow(msg))
      chapter_num = chapter_num + 1
    } else {
      title = sections$text[i]
      title_case = stringr::str_to_sentence(title)
      if (title_case != title) {
        title_case = standard_exceptions(title, title_case)
      }
      if (title_case != title) {
        msg = glue::glue("  {info} {sections[i, 1]}: {title_case} vs {title}")
        message(blue(msg))
        error = TRUE
      } else {
        msg = glue::glue("  {tick} {sections[i, 1]}: {title_case}")
        message(yellow(msg))
      }
    }
  }
  if (isTRUE(error)) {
    msg = glue::glue("{info} Please check sections. \\
                Note: some of the warnings may be incorrect. \\
                If so, ask Colin to add an exception.

                If a word is wrapped in \\texttt it isn't checked.")
    message(blue(msg))
  } else {
    message(yellow(tick, "Section titles look good"))
  }
  return(invisible(NULL))
}
