globalVariables(c("id", "is_chapter"))
#' @importFrom stringr str_match str_trim
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

clean_title = function(title) {
  title = stringr::str_remove_all(title, "\\\\text(tt|it|bf)")
  title = stringr::str_remove_all(title, "(\\{|\\})")
  title = stringr::str_replace(title, "\\\\_", "_")
  title = stringr::str_remove_all(title, "\\\\")
  stringr::str_squish(title)
}

## Check banner length and formatting
check_live_banners = function(r_code) {
  banner_line_numbers = which(str_detect(r_code, pattern = "^## ==="))
  banners = r_code[banner_line_numbers]
  check = banners == paste0("## ", paste(rep("=", 47), collapse = ""))
  if (all(check)) return(invisible(TRUE))

  msg_error("Banner length should be ## ========, with 47 ='s")
  msg_error(paste("See lines:", banner_line_numbers[!check], "\n"))
  set_error()
  return(invisible(FALSE))
}

check_live_section_titles = function(r_code, sections, chap_num) {
  ## From the live script
  section_hashes = r_code[str_detect(r_code, pattern = "^## \\wec")]
  section_hashes_line_numbers = stringr::str_which(r_code, pattern = "^## \\wec")

  ## From the notes (extractor.csv)
  sections = sections[sections$chap_num == chap_num, ]
  pattern = glue::glue("{chap_num}\\.\\d*")
  section_numbers = str_extract(section_hashes, pattern)

  is_correct = TRUE
  for (i in seq_along(section_numbers)) {
    sec_num = section_numbers[i]
    section = str_replace(sec_num, paste0(chap_num, "\\."), "")
    notes_title = sections[sections$section == section, ]$text
    notes_title = clean_title(notes_title)
    expected_title = glue::glue("## Section {sec_num}: {notes_title}")
    actual_title = section_hashes[i]
    if (expected_title != actual_title) {
      line_num = section_hashes_line_numbers[i]
      msg_error(glue::glue("L{line_num}: {expected_title} vs {actual_title}"), padding = 4)
      set_error()
      is_correct = FALSE
    }
  }
  return(invisible(is_correct))
}

check_live_files = function(dir_name) {
  fname = file.path(dir_name, "master_tutor.R")
  if (!file.exists(fname)) {
    msg_info(paste0(fname, "file missing"), padding = 2)
    return(invisible(TRUE))
  }

  msg_info(file.path(dir_name, "master_tutor.R"), padding = 2)
  r_code = readLines(fname)
  chap_num = str_extract(fname, "[0-9][0-9]?")
  sections = get_section_tibble()

  correct = check_live_banners(r_code)
  correct = correct && check_live_section_titles(r_code, sections, chap_num)

  return(invisible(correct))
}

#' Run checks on the live directory
#' @title Check the live directory
#' @importFrom stringr str_extract
#' @export
check_live = function() {

  if (!fs::dir_exists("../live")) return(invisible(NULL))
  chapters = fs::dir_ls("../live", regexp = "../live/chapter")
  msg_start("Checking live scripts formatting")

  correct = vapply(chapters, check_live_files, FUN.VALUE = logical(1))
  if (all(correct)) msg_ok("Live script formatting looks good")

  return(invisible(all(correct)))
}
