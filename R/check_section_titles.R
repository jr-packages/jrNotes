
standard_exceptions = function(title) {
  from = c("r", "shiny", "dt", "rstudio")
  to = c("R", "Shiny", "DT", "RStudio")
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

  if (str_detect(string = title, "\\\\texttt\\{.*\\}")) { # nolint
    locs = str_locate(string = title, "\\\\texttt\\{.*\\}")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
    return(title_case)
  }
  if (str_detect(string = title, "\\\\textbf\\{.*\\}")) { # nolint
    locs = str_locate(string = title, "\\\\textbf\\{.*\\}")[1, ] # nolint
    str_sub(title_case, locs[1], locs[2]) = str_sub(title, locs[1], locs[2])
    return(title_case)
  }

  return(title_case)
}

check_section_titles = function() {

  if (!file.exists("main.tex")) return()
  message(yellow(symbol$circle_filled, "Checking section for sentence case"))

  main_tex = readLines("main.tex")
  chapters = stringr::str_extract(main_tex, "^\\\\chapter\\{")
  chapter_locs = c(which(!is.na(chapters)), Inf)

  ## First extract sections
  sections = stringr::str_extract(main_tex, "^\\\\section\\{")
  sections_locs =  which(!is.na(sections))
  main_tex = main_tex[which(!is.na(sections))]

  error = FALSE
  next_chapter = 1
  for (i in seq_along(main_tex)) {
    if (sections_locs[i] > chapter_locs[next_chapter]) {
      msg = glue::glue("  {symbol$circle_filled} Chapter: {next_chapter}")
      message(yellow(msg))
      next_chapter = next_chapter + 1
    }
    ## Extract location of first { #nolintr
    ## Then match it to corresponding } #nolintr
    start_bracket = str_locate_all(main_tex[i], "\\{")[[1]][, 1]
    end_bracket = str_locate_all(main_tex[i], "\\}")[[1]][, 1]
    start_loc = start_bracket[1]
    end_loc = which(start_bracket < end_bracket[1])
    end_loc = end_bracket[end_loc[length(end_loc)]]
    title = str_sub(main_tex[i], start_loc + 1, end_loc - 1)

    ## Take account of textorpdfstring brackets
    if (str_detect(title, "texorpdfstring")) {
      start_bracket = str_locate_all(title, "\\{")[[1]][, 1]
      end_bracket = str_locate_all(title, "\\}")[[1]][, 1]
      start_loc = start_bracket[1]
      end_loc = which(start_bracket < end_bracket[1])
      end_loc = end_bracket[end_loc[length(end_loc)]]
      title = str_sub(title, start_loc + 1, end_loc - 1)
    }

    title_case = stringr::str_to_sentence(title)
    if (title_case != title) {
      title_case = standard_exceptions(title)
    }
    if (title_case != title) {
      msg = glue::glue("    {symbol$info} Section: {title_case} vs {title}")
      message(red(msg))
      error = TRUE
    } else {
      msg = glue::glue("    {symbol$tick} Section: {title_case}")
      message(yellow(msg))
    }
  }
  if (isTRUE(error)) {
    msg = glue("{symbol$fancy_question_mark} Please check sections. Note, some \\
               of the warnings may be incorrect. If so, ask Colin to add an exception")
    message(red(msg))
  } else {
    message(yellow(symbol$tick, "Section titles look good"))
  }
  return(invisible(NULL))
}
