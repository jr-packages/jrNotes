has_changed = function(fname1, fname2) {
  if (!file.exists(fname1)) return(TRUE)

  d1 = digest::digest(readLines(fname1))
  d2 = digest::digest(readLines(fname2))
  if (d1 != d2) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

get_project_name = function() {
  proj_name = system("git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\\///' | sed 's/\\.git//'", #nolint
                     intern = TRUE) #nolint

  gsub("_notes", "", proj_name)
}

get_runner_hash = function(fname) {
  line_break = "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"
  lines = readLines(fname)

  start = which(lines == line_break)[1]
  end = which(lines == line_break)[2]

  digest::digest(lines[start:end])
}

check_gitlab_runner = function(fname1, fname2) {
  msg = yellow(glue("{symbol$circle_filled} Checking gitlab-ci.yml"))
  message(msg)
  if (get_runner_hash(fname1) !=  get_runner_hash(fname2)) {
    msg = red(glue("{symbol$cross} gitlab-ci.yml has changed."))
    message(msg)
    return(FALSE)
  }
  return(TRUE)
}

get_r_template_fnames = function(template_repo_loc) {
  file.path(template_repo_loc,
            c("notes/notes.Rproj", "slides/slides.Rproj",
              "Makefile", ".gitignore",
              "notes/Makefile", "notes/main.Rmd",
              "slides/Makefile"))
}

get_python_template_fnames = function(template_repo_loc) {
  file.path(template_repo_loc,
            c("notes/notes.Rproj", "slides/slides.Rproj",
              "Makefile-python", ".gitignore",
              "notes/Makefile-python", "notes/main.Rmd",
              "slides/Makefile-python"))
}

#' @title Checks notes files are the same as template
#'
#' Ensures that certain notes files are the same as the notes template.
#' These cannonical files are identical for all notes, e.g. Makefiles,
#' main.Rmd.
#'
#' Typically this used by the gitlab-ci runner.
#' @param type Which template to use. Default \code{r}. Could also be \code{python}
#' @export
check_template = function(type = "r") {
  if (Sys.getenv("CI_PROJECT_NAME") == "template") {
    # Feedback loop if we test template on it's on master
    return(invisible(NULL))
  }

  message(yellow(symbol$circle_filled, "Cloning template repo"))
  tmp_dir = tempdir()
  on.exit(unlink(tmp_dir))
  template_repo_loc = file.path(tmp_dir, "template")
  system2("git", args = c("clone",
                          "--depth",
                          "1",
                          "git@gitlab.com:jumpingrivers-notes/template.git", #nolint
                          template_repo_loc))

  message(yellow(symbol$circle_filled, "Checking template files"))
  proj_name = get_project_name() #nolint
  # Ensure Rproj are given sensible names - not just notes.Rproj
  fnames = c(glue("notes/notes_{proj_name}.Rproj"),
             glue("slides/slides_{proj_name}.Rproj"),
             "Makefile", ".gitignore",
             "notes/Makefile", "notes/main.Rmd",
             "slides/Makefile")

  if (type == "r") {
    template_fnames = get_r_template_fnames(template_repo_loc)
    runner_check = check_gitlab_runner(".gitlab-ci.yml",
                        file.path(template_repo_loc, ".gitlab-ci.yml"))
  } else if (type == "python") {
    template_fnames = get_python_template_fnames(template_repo_loc)
    runner_check = check_gitlab_runner(".gitlab-ci.yml",
                        file.path(template_repo_loc, "python-gitlab-ci.yml"))
  }

  # Compare files to template
  # Keep track of any differences
  changed = logical(length(fnames))
  for (i in seq_along(fnames)) {
    changed[i] = has_changed(fnames[i], template_fnames[i])
    msg = yellow(glue("{symbol$circle_filled} Checking {fnames[i]}"))
    message(msg)

        if (isTRUE(changed[i])) {
      msg = glue("{symbol$cross} File {fnames[i]} does not match")
      message(red(msg))
    }
  }
  if (any(changed) || isFALSE(runner_check)) {
    stop(red("Files differs from template repo.
         Either revert your changes or update the template.
         If you think you want to update the template, make a merge
         request and ask for feedback."), call. = FALSE)
  }

  if (length(list.files(pattern = "*\\.Rproj")) > 0L) {
    msg = glue("{symbol$cross} Don't add Rproj files to the base directory.")
    stop(red(msg), call. = FALSE)
  }
  message(yellow(symbol$tick, "Template files look good"))
}