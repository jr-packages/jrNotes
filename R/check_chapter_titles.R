# nolint start
# Example chapter strings
#\\chapter{\\texorpdfstring{Graphics with \\textbf{ggplot2}}{Graphics with ggplot2}}\\label{graphics-with-ggplot2}}
#\\chapter{Introduction}\\label{introduction}}
# nolint end

#' @importFrom dplyr mutate if_else pull select
check_chapter_titles = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  if (!file.exists("extractor.csv")) return()
  message(yellow(circle_filled,
                 "Checking chapters for title case...check_chapter_titles()"))
  tokens = read_tokens()
  chapters = tokens %>%
    dplyr::filter(X1 == "chapter") %>%
    dplyr::mutate(texorpdf = str_detect(X3, "\\\\texorpdf")) %>% #nolint
    dplyr::mutate(text = X3) %>%
    dplyr::mutate(text = if_else(texorpdf,
                                 str_match(X3, "^\\\\texorpdfstring \\{(.*)\\}\\{.*\\}$")[, 2],
                                 text)) %>%
    dplyr::mutate(text = str_trim(text)) %>%
    dplyr::select(text) %>%
    dplyr::pull()

  error = FALSE
  for (i in seq_along(chapters)) {
    title = chapters[i]
    title_case = tools::toTitleCase(title)

    if (title_case != title) {
      title_case = standard_exceptions(title, title_case)
    }

    if (title_case != title) {
      msg = glue::glue("  {cross} Chapter {i}: {title_case} vs {title}")
      message(red(msg))
      error = TRUE
    } else {
      msg = glue::glue("  {tick} Chapter {i}: {title_case}")
      message(yellow(msg))
    }

  }
  if (isTRUE(error)) {
    msg = glue::glue("{cross} Please correct chapter titles")
    message(red(msg))
    .jrnotes$error = TRUE
  } else {
    message(yellow(tick, "Titles look good"))
  }
  return(invisible(NULL))
}
