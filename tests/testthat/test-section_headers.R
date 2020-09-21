# Defining a dummy chapter number
chap_num = "2"
sections = tibble::tibble(chap_num = c(2, 2), section = 1:2,
                          text = c("A simple R session", "Assignment operations"))

## Find example files
dir = system.file("testthat", package = "jrNotes")
r_code = readLines(file.path(dir, "live-code.Rmd"))

# Test Correct headers
test_that("Check section headings (correct)", {
  expect_true(check_live_section_titles(r_code, sections, chap_num))
  expect_false(.jrnotes$error)
})


# Test bad headers
r_code = readLines(file.path(dir, "live-code-bad.Rmd"))
test_that("Check section headings (bad)", {
  expect_equal(check_live_section_titles(r_code, sections, chap_num), FALSE)
  expect_message(check_live_section_titles(r_code, sections, chap_num))
  expect_true(.jrnotes$error)
  .jrnotes$error = FALSE
})
