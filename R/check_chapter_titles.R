# nolint start
# Example chapter strings
#\\chapter{\\texorpdfstring{Graphics with \\textbf{ggplot2}}{Graphics with ggplot2}}\\label{graphics-with-ggplot2}}
#\\chapter{Introduction}\\label{introduction}}
# nolint end
#' @importFrom dplyr mutate if_else pull select
check_chapter_titles = function() {
  if (!required_texlive(2017)) return(invisible(NULL))

  if (!file.exists("extractor.csv")) return()
  msg_start("Checking chapters for title case...check_chapter_titles()")
  tokens = read_tokens()
  chapters = tokens %>%
    dplyr::filter(X1 == "chapter") %>%
    dplyr::mutate(texorpdf = stringr::str_detect(X3, "\\\\texorpdf")) %>% #nolint
    dplyr::mutate(text = X3) %>%
    dplyr::mutate(text =
                    if_else(texorpdf,
                            stringr::str_match(X3, "^\\\\texorpdfstring \\{(.*)\\}\\{.*\\}$")[, 2],
                            text)) %>%
    dplyr::mutate(text = stringr::str_trim(text)) %>%
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
      msg = glue::glue("Chapter {i}: {title_case} vs {title}")
      msg_error(msg, padding = TRUE)
      error = TRUE
    } else {
      msg = glue::glue("Chapter {i}: {title_case}")
      msg_success(msg, padding = TRUE)
    }

  }
  if (isTRUE(error)) {
    msg_error("Please correct chapter titles")
  } else {
    msg_success("Titles look good")
  }
  return(invisible(NULL))
}
