#' Create scripts for online training
#'
#' Creates a vm_scripts folder
#' Creates exercises.R and solutions.R from master_exercises.R
#' Creates tutor.R and tutor_blank.R from master_tutor.R
#' Zips VM folder ready to be exposed as an artifact
#' @importFrom fs dir_ls file_copy
#' @importFrom zip zipr
#' @import stringr
#' @export

create_live_scripts = function() {

  if (!fs::dir_exists("../live")) return(invisible(NULL))

  msg_start("Creating scripts for VM...")

  # Create new folders and ensure empty
  chapters = list.files(path = "../live/", pattern = "chapter")

  dir.create("../live/vm_scripts", showWarnings = FALSE)
  unlink(list.files("../live/vm_scripts", full.names = TRUE, include.dirs = TRUE),
         recursive = TRUE)

  dir.create("../live/tutor_scripts", showWarnings = FALSE)
  unlink(list.files("../live/tutor_scripts", full.names = TRUE, include.dirs = TRUE),
         recursive = TRUE)

  for (chapter in chapters) {
    # Create folder
    dir.create(glue("../live/vm_scripts/{chapter}", showWarnings = FALSE))

    # Create tutor scripts
    if (file.exists(glue("../live/{chapter}/master_tutor.R"))) {

      # Create tutor_scripts/chapterX.R
      system2("sed",
              args = c(shQuote("/^#>.*/d"), glue("../live/{chapter}/master_tutor.R")),
              stdout = glue("../live/tutor_scripts/{chapter}.R"))

      # Create vm_scripts/chapterX/tutor.R
      system2("sed",
              args = c(shQuote("s/^#> //"), glue("../live/{chapter}/master_tutor.R")),
              stdout = glue("../live/vm_scripts/{chapter}/tutor.R"))
    }

    # Create exercises and solutions
    if (file.exists(glue("../live/{chapter}/master_exercises.R"))) {

      # Create exercises_original.R
      system2("sed",
              args = c(shQuote("/^#>.*/d"), glue("../live/{chapter}/master_exercises.R")),
              stdout = glue("../live/vm_scripts/{chapter}/exercises_original.R"))

      # Create excercises.R
      fs::file_copy(path = glue("../live/vm_scripts/{chapter}/exercises_original.R"),
                    new_path = glue("../live/vm_scripts/{chapter}/exercises.R"),
                    overwrite = TRUE)

      # Create solutions.R
      system2("sed",
              args = c(shQuote("s/^#> //"), glue("../live/{chapter}/master_exercises.R")),
              stdout = glue("../live/vm_scripts/{chapter}/solutions.R"))
    }
  }

  # Zip folder
  msg_start("Zipping scripts...")
  zip::zipr(zipfile = "../live/tutor_scripts.zip", files = "../live/tutor_scripts/")
  zip::zipr(zipfile = "../live/vm_scripts.zip", files = "../live/vm_scripts/")

  # Clean up
  unlink("../live/vm_scripts/", recursive = TRUE)
  unlink("../live/tutor_scripts/", recursive = TRUE)

  msg_ok("Live scripts created and zipped")
}
