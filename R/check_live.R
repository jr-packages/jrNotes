globalVariables(c("id", "is_chapter"))
get_section_tibble = function() {
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
    dplyr::mutate(text = dplyr::if_else(label,
                                 str_match(text, "(.*)\\W\\label .*")[, 2],
                                 text)) %>%
    dplyr::mutate(text = dplyr::if_else(footnote,
                                 str_match(text, "(.*)\\\\footnote.*")[, 2],
                                 text)) %>%
    dplyr::mutate(text = str_trim(text),
                  is_chapter = X1 == "chapter",
                  chap_num = cumsum(is_chapter)) %>%
    dplyr::group_by(chap_num) %>%
    dplyr::filter(X1 == "section") %>%
    dplyr::mutate(section = seq_len(length(X1))) %>%
    dplyr::select(-id, -label)

  sections
}


check_live_file_names = function(dir_name) {

  #if (!any(str_detect(dir_name, "/slides.Rmd$"))) {
  #  jrNotes:::msg_error("slides.Rmd file missing", padding = 2)
  #}
  fname = file.path(dir_name, "tutor.R")
  if (!file.exists(fname)) {
    msg_error("tutor.R file missing", padding = 2)
  } else {
    msg_info(file.path(dir_name, "tutor.R"), padding = 2)
    check_live_r_file(file.path(dir_name, "tutor.R"))
  }

  #if (!any(str_detect(dir_name, "/exercises.R$"))) {
  #  jrNotes:::msg_error("exercises.R file missing", padding = 2)
  #}

  return(invisible(NULL))
}

#' @title Check the live directory
#'
#' Run checks on the live/ directory
#' @export
check_live = function() {
  chapters = fs::dir_ls("live", regexp = "live/chapter")
  i = 4
  for (i in chapters) {
#    files = fs::dir_ls(chapters[i])
    msg_info(paste0("Checking ", chapters[i]))
    check_live_file_names(chapters[i])
  }
  return(invisible(NULL))
}

clean_title = function(title) {
  title = stringr::str_remove(title, "\\\\text(tt|it|bf) \\{")
  title = stringr::str_remove(title, "\\}")
  title = stringr::str_replace(title, "\\\\_", "_")
  title
}

check_live_r_file = function(fname) {
  r_code = readLines(fname)

  ## Check banner
  banner_line_numbers = which(str_detect(r_code, pattern = "^########"))
  banners = r_code[banner_line_numbers]
  check = banners == paste(rep("#", 79), collapse = "")
  if (!all(check)) {
    msg_info("Banner length should be 79#'s")
    msg_info(paste("See lines:", banner_line_numbers[!check]))
    stop(call. = FALSE)
  }
  ## Check Section
  section_hashes = r_code[str_detect(r_code, pattern = "^##### \\wec")]
  chap_num = str_extract(fname, "[0-9][0-9]?")

  ## Check chapter number
  pattern = glue::glue("^##### Section {chap_num}\\.\\d* - ")
  check = str_detect(section_hashes, pattern = pattern)
  if (!all(check)) {
    msg_error("Section should have the form: ##### Section X.X - ", padding = 2)
    stop(call. = FALSE)
  }

  sections = get_section_tibble()
  sections = sections[sections$chap_num == chap_num, ]
  pattern = glue::glue("{chap_num}\\.\\d*")
  section_numbers = str_extract(section_hashes, pattern)
  i = 1
  for (i in seq_along(section_numbers)) {
    sec_num = section_numbers[i]
    section = str_replace(sec_num, paste0(chap_num, "\\."), "")
    notes_title = sections[sections$section == section, ]$text
    notes_title = clean_title(notes_title)
    expected_title = glue::glue("##### Section {sec_num} - {notes_title}")
    actual_title = section_hashes[i]
    if (expected_title != actual_title) {
      msg_info(glue::glue("Chapter {sec_num}"))
      msg_error(glue::glue("{expected_title} vs {actual_title}"), padding = 2)
    }

  }
  return(invisible(NULL))
}



