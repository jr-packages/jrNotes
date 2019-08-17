
standard_exceptions = function(title) {
  from = c("r", "shiny", "dt", "rstudio", "anova", "uk", "usa",
           "html", "yaml")
  to = c("R", "Shiny", "DT", "RStudio", "ANOVA", "UK", "USA",
         "HTML", "YAML")
  title_case = stringr::str_to_sentence(title)

  for (i in seq_along(from)) {
    # One word
    (new_title = str_replace(title_case,
                             paste0("^", str_to_title(from[i]), "$"),
                             to[i]))
    if (title == new_title) return(title)


    # Space either side
    (new_title = str_replace(title_case,
                             paste0(" ", from[i], " "),
                             paste0(" ", to[i], " ")))
    if (title == new_title) return(title)

    # End of heading
    (new_title = str_replace(title_case,
                             paste0(" ", from[i], "$"),
                             paste0(" ", to[i])))
    if (title == new_title) return(title)

    #start of heading
    (new_title = str_replace(title_case,
                             paste0("^", str_to_title(from[i]), " "),
                             paste0(to[i], " ")))
    if (title == new_title) return(title)
    # QUestion marks
    (new_title = str_replace(title_case,
                             paste0(" ", from[i], "\\?"),
                             paste0(" ", to[i], "\\?")))
    if (title == new_title) return(title)
  }

  if (str_detect(string = title, "\\\\texttt \\{.*\\}")) { # nolint
    locs = str_locate(string = title, "\\\\texttt \\{.*\\}")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
    return(title_case)
  }
  if (str_detect(string = title, "\\\\textbf \\{.*\\}")) { # nolint
    locs = str_locate(string = title, "\\\\textbf \\{.*\\}")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
    return(title_case)
  }

  return(title_case)
}

check_section_titles = function() {

  message(yellow(symbol$circle_filled, "Checking section for sentence case"))
  if (!file.exists("extractor.csv")) return()

  tokens = read_tokens()
  section_nums = which(tokens$X1 == "section" | tokens$X1 == "subsection")

  sections = tokens %>%
    dplyr::filter(X1 == "section" | tokens$X1 == "subsection") %>%
    dplyr::mutate(texorpdf = str_detect(X3, "\\\\texorpdf")) %>%
    dplyr::mutate(text = X3) %>%
    dplyr::mutate(text = if_else(texorpdf,
                                 str_match(X3, "^\\\\texorpdfstring \\{(.*)\\}\\{.*\\}$")[,2],
                                 text)) %>%
    dplyr::mutate(text = str_trim(text))

  section_text = sections %>%
    dplyr::select(text) %>%
    dplyr::pull()

  error = FALSE
  next_chapter = 1
  for (i in seq_along(section_text)) {
    title = section_text[i]
    title_case = stringr::str_to_sentence(title)
    if (title_case != title) {
      title_case = standard_exceptions(title)
    }
    if (title_case != title) {
      msg = glue::glue("  {symbol$info} {sections[i, 1]}: {title_case} vs {title}")
      message(blue(msg))
      error = TRUE
    } else {
      msg = glue::glue("  {symbol$tick} {sections[i, 1]}: {title_case}")
      message(yellow(msg))
    }
  }
  if (isTRUE(error)) {
    msg = glue::glue("{symbol$info} Please check sections. \\
                Note: some of the warnings may be incorrect. \\
                If so, ask Colin to add an exception.

                If a word is wrapped in \\texttt it isn't checked.")
    message(blue(msg))
  } else {
    message(yellow(symbol$tick, "Section titles look good"))
  }
  return(invisible(NULL))
}
