# Correct headers
code = c("## ===============================================",
         "## Section 2.1: A simple R session",
         "",
         "## ===============================================",
         "## Section 2.2: Assignment operations")
right_headers = code[stringr::str_detect(code, pattern = "^## \\wec")]

# Incorrect headers
incorrect_code = c(code[-5], "## Section 2.2 - Assignment operations")
wrong_headers = incorrect_code[stringr::str_detect(incorrect_code, pattern = "^## \\wec")]

# Defining a dummy chapter number
chapter = "2"

# Tests
test_that("check_section_headers errors where appropriate", {
  expect_equal(check_section_headers(code, right_headers, chapter), NULL)
  expect_equal(check_section_headers(incorrect_code, wrong_headers, chapter), TRUE)
})
