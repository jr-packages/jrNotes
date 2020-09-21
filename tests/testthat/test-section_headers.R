# Defining a dummy chapter number
chapter = "2"
# Correct headers
code = c("## ===============================================",
         "## Section 2.1: A simple R session",
         "",
         "## ===============================================",
         "## Section 2.2: Assignment operations")
right_headers = code[stringr::str_detect(code, pattern = "^## \\wec")]

# Test Correct headers
test_that("Check section headings (correct)", {
  expect_true(check_section_headers(code, right_headers, chapter))
  expect_false(.jrnotes$error)
})

# Make bad headers
incorrect_code = c(code[-5], "## Section 2.2 - Assignment operations")
wrong_headers = incorrect_code[stringr::str_detect(incorrect_code, pattern = "^## \\wec")]

# Test bad headers
test_that("Check section headings (bad)", {
  expect_equal(check_section_headers(incorrect_code, wrong_headers, chapter), FALSE)
  expect_message(check_section_headers(incorrect_code, wrong_headers, chapter))
  expect_true(.jrnotes$error)
  .jrnotes$error = FALSE
})
