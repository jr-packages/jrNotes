#' Create scripts for online training
#'
#' Creates a vm_scripts folder
#' Creates exercises.R and solutions.R from master_exercises.R
#' Creates tutor.R and tutor_blank.R from master_tutor.R
#' Zips VM folder ready to be exposed as an artifact
#' @importFrom fs dir_ls file_copy
#' @importFrom stringr str_to_lower str_subset str_replace
#' @param live_path The path to the live directory
#' @export
create_live_scripts = function(live_path = "../live") {
  if (get_repo_language() == "python") {
    create_live_python(live_path = live_path)
  } else {
    if (!fs::dir_exists(live_path)) return(invisible(NULL))

    msg_start("Creating scripts for VM...")

    # Create new folders and ensure empty
    chapters = list.files(path = live_path, pattern = "chapter")

    dir.create(glue("{live_path}/vm_scripts"), showWarnings = FALSE)
    unlink(list.files(glue("{live_path}/vm_scripts"), full.names = TRUE, include.dirs = TRUE),
           recursive = TRUE)

    dir.create(glue("{live_path}/tutor_scripts"), showWarnings = FALSE)
    unlink(list.files(glue("{live_path}/tutor_scripts"), full.names = TRUE, include.dirs = TRUE),
           recursive = TRUE)

    # Set up file extension
    course = str_to_lower(get_project_name())
    if (course == "jrrmarkdown") {
      ext = "Rmd"
    } else{
      ext = "R"
    }

    for (chapter in chapters) {
      # Create folder
      dir.create(glue("{live_path}/vm_scripts/{chapter}", showWarnings = FALSE))

      # Check for images
      files = list.files(glue("{live_path}/{chapter}"), full.names = TRUE)
      imgs = str_subset(files, "\\.png$")

      # Copy images
      if (length(imgs) > 0) {
        fs::file_copy(
          path = imgs,
          new_path = str_replace(imgs, live_path, glue("{live_path}/vm_scripts")),
          overwrite = TRUE
        )
      }

      # Create tutor scripts
      if (file.exists(glue("{live_path}/{chapter}/master_tutor.{ext}"))) {

        # Create tutor_scripts/chapterX.{ext}
        system2("sed",
                args = c(shQuote("/^#>.*/d"), glue("{live_path}/{chapter}/master_tutor.{ext}")),
                stdout = glue("{live_path}/tutor_scripts/{chapter}.{ext}"))

        # Create vm_scripts/chapterX/tutor.{ext}
        system2("sed",
                args = c(shQuote("s/^#> //"), glue("{live_path}/{chapter}/master_tutor.{ext}")),
                stdout = glue("{live_path}/vm_scripts/{chapter}/tutor.{ext}"))
      }

      # Create exercises and solutions
      if (file.exists(glue("{live_path}/{chapter}/master_exercises.{ext}"))) {

        # Create exercises_original.{ext}
        ## Delete lines starting with #>
        ## Keep lines starting with #<
        system2("sed",
                args = c(shQuote("/^#>.*/d ; s/^#< //"),
                         glue("{live_path}/{chapter}/master_exercises.{ext}")),
                stdout = glue("{live_path}/vm_scripts/{chapter}/exercises_original.{ext}"))

        # Create exercises.{ext}
        fs::file_copy(path = glue("{live_path}/vm_scripts/{chapter}/exercises_original.{ext}"),
                      new_path = glue("{live_path}/vm_scripts/{chapter}/exercises.{ext}"),
                      overwrite = TRUE)

        # Create solutions.{ext}
        ## Delete lines starting with #<
        ## Keep lines starting with #>
        system2("sed",
                args = c(shQuote("/^#<.*/d ; s/^#> //"),
                         glue("{live_path}/{chapter}/master_exercises.{ext}")),
                stdout = glue("{live_path}/vm_scripts/{chapter}/solutions.{ext}"))
      }
    }

    # Zip folder
    msg_info("Zipping scripts...", padding = TRUE)
    # Copy notes into vm_scripts.zip
    fs::file_copy("main.pdf", glue("{live_path}/vm_scripts/notes.pdf"), overwrite = TRUE)

    zip::zipr(zipfile = glue("{live_path}/tutor_scripts.zip"),
              files = glue("{live_path}/tutor_scripts/"))
    zip::zipr(zipfile = glue("{live_path}/vm_scripts.zip"),
              files = glue("{live_path}/vm_scripts/"))

    # Clean up
    unlink(glue("{live_path}/vm_scripts/"), recursive = TRUE)
    unlink(glue("{live_path}/tutor_scripts/"), recursive = TRUE)

    msg_success("Live scripts created and zipped")
  }
}



#' Create live python
#'
#' Creates a vm_scripts folder
#' Creates exercises.ipynb and solutions.ipynb from master_exercises.Rmd
#' Creates tutor.ipynb and a blank one from master_tutor.Rmd
#' Zips VM folder ready to be exposed as an artifact
#'
#' @importFrom fs dir_ls file_copy
#' @importFrom glue glue
#' @param live_path The location to the live directory
create_live_python = function(live_path) {

  if (!fs::dir_exists(live_path)) return(invisible(NULL))

  msg_start("Creating scripts for VM...")

  chapters = list.files(path = live_path, pattern = "chapter")

  dir.create(glue("{live_path}/vm_scripts"), showWarnings = FALSE)
  unlink(list.files(glue("{live_path}/vm_scripts"), full.names = TRUE, include.dirs = TRUE),
         recursive = TRUE)

  dir.create(glue("{live_path}/tutor_scripts"), showWarnings = FALSE)
  unlink(list.files(glue("{live_path}/tutor_scripts"), full.names = TRUE, include.dirs = TRUE),
         recursive = TRUE)

  for (chapter in chapters) {
    # Create folder
    dir.create(glue::glue("{live_path}/vm_scripts/{chapter}", showWarnings = FALSE))

    # Create tutor scripts
    if (file.exists(glue::glue("{live_path}/{chapter}/master_tutor.Rmd"))) {

      # Create tutor_scripts/chapterX.py
      system2("sed",
              args = c(shQuote("/^#>.*/d"), glue::glue("{live_path}/{chapter}/master_tutor.Rmd")),
              stdout = glue::glue("{live_path}/tutor_scripts/{chapter}.Rmd"))
      # convert tutor scripts to notebooks
      system2("jupytext", c("--to", "notebook",
                            glue::glue("{live_path}/tutor_scripts/{chapter}.Rmd")))

      # Create vm_scripts/chapterX/tutor.R
      system2("sed",
              args = c(shQuote("s/^#> //"), glue::glue("{live_path}/{chapter}/master_tutor.Rmd")),
              stdout = glue::glue("{live_path}/vm_scripts/{chapter}/tutor.Rmd"))

      # convert student scripts to notebooks
      system2(
        "jupytext",
        c(
          "--to", "notebook",
          glue::glue("{live_path}/vm_scripts/{chapter}/tutor.Rmd")
        )
      )
    }

    # Create exercises and solutions
    if (file.exists(glue::glue("{live_path}/{chapter}/master_exercises.Rmd"))) {

      # Create exercises_original.R
      system2("sed",
              args = c(shQuote("/^#>.*/d"),
                       glue::glue("{live_path}/{chapter}/master_exercises.Rmd")),
              stdout = glue::glue("{live_path}/vm_scripts/{chapter}/exercises_original.Rmd"))
      system2(
        "jupytext",
        c(
          "--to", "notebook",
          glue::glue("{live_path}/vm_scripts/{chapter}/exercises_original.Rmd")
        )
      )

      # Create excercises.R
      fs::file_copy(path = glue::glue("{live_path}/vm_scripts/{chapter}/exercises_original.ipynb"),
                    new_path = glue::glue("{live_path}/vm_scripts/{chapter}/exercises.ipynb"),
                    overwrite = TRUE)

      # Create solutions.R
      system2("sed",
              args = c(shQuote("s/^#> //"),
                       glue::glue("{live_path}/{chapter}/master_exercises.Rmd")),
              stdout = glue::glue("{live_path}/vm_scripts/{chapter}/solutions.Rmd"))

      system2(
        "jupytext",
        c(
          "--to", "notebook",
          glue::glue("{live_path}/vm_scripts/{chapter}/solutions.Rmd")
        )
      )

    }
  }

  # Zip folder
  msg_start("Zipping scripts...")
  # clear out the Rmd files first
  unlink(list.files(glue("{live_path}/tutor_scripts"),
                    "Rmd$", full.names = TRUE, recursive =  TRUE))
  unlink(list.files(glue("{live_path}/vm_scripts"),
                    "Rmd$", full.names = TRUE, recursive =  TRUE))

  # Copy notes into vm_scripts.zip
  fs::file_copy("main.pdf", glue("{live_path}/vm_scripts/notes.pdf"), overwrite = TRUE)

  zip::zipr(zipfile = glue("{live_path}/tutor_scripts.zip"),
            files = glue("{live_path}/tutor_scripts"))
  zip::zipr(zipfile = glue("{live_path}/vm_scripts.zip"),
            files = glue("{live_path}/vm_scripts"))

  # Clean up
  unlink(glue("{live_path}/vm_scripts/"), recursive = TRUE)
  unlink(glue("{live_path}/tutor_scripts/"), recursive = TRUE)

  msg_success("Live scripts created and zipped")
}
