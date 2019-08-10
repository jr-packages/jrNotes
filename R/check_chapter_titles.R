# nolint start
# Example chapter strings
#\\chapter{\\texorpdfstring{Graphics with \\textbf{ggplot2}}{Graphics with ggplot2}}\\label{graphics-with-ggplot2}}
#\\chapter{Introduction}\\label{introduction}}
# nolint end

check_chapter_titles = function() {

  if (!file.exists("main.tex")) return()
  message(yellow(symbol$circle_filled, "Checking chapters for title case"))

  main_tex = readLines("main.tex")

  ## First extract chapters
  chapters = stringr::str_extract(main_tex, "^\\\\chapter\\{")
  main_tex = main_tex[which(!is.na(chapters))]
  error = FALSE
  for (i in seq_along(main_tex)) {
    ## Extract location of first { # nolint
    ## Then match it to corresponding } # nolint
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

    title_case = tools::toTitleCase(title)
    if (title_case != title) {
      msg = glue::glue("\t{symbol$cross} Chapter {i}: {title_case} vs {title}")
      message(red(msg))
      error = TRUE
    } else {
      msg = glue::glue("\t{symbol$tick} Chapter {i}: {title_case}")
      message(yellow(msg))
    }
  }
  if (isTRUE(error)) {
    stop(red("Please correct chapter titles"), call. = FALSE)
  } else {
    message(yellow(symbol$tick, "Titles look good"))
  }
  return(invisible(NULL))
}

check_section_titles = function() {

  if (!file.exists("main.tex")) return()
  message(yellow(symbol$circle_filled, "Checking section for title case"))

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
      msg = glue::glue("\t{symbol$circle_filled} Chapter: {next_chapter}")
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

    title_case = tools::toTitleCase(title)
    if (title_case != title) {
      msg = glue::glue("\t  {symbol$cross} Section: {title_case} vs {title}")
      message(red(msg))
      error = TRUE
    } else {
      msg = glue::glue("\t  {symbol$tick} Section: {title_case}")
      message(yellow(msg))
    }
  }
  if (isTRUE(error)) {
    msg = glue("{symbol$fancy_question_mark} Please check headings. Note, some
               of the warnings may be incorrect.")
    message(red(msg))
  } else {
    message(yellow(symbol$tick, "Section titles look good"))
  }
  return(invisible(NULL))
}
