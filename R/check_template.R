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

# Compare gitlab-ci files
get_runner_hash = function(fname) {
  line_break = "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"
  lines = readLines(fname)

  start = which(lines == line_break)[1]
  end = which(lines == line_break)[2]

  digest::digest(lines[start:end])
}

# Update gitlab runner
update_gitlab_ci = function(fname, template_fname) {
  line_break = "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"

  ## Extract template CI part
  lines = readLines(template_fname)

  start = which(lines == line_break)[1]
  end = which(lines == line_break)[2]
  template_lines = lines[start:end]

  ## Remove template part from current gitlab
  lines = readLines(fname)
  start = which(lines == line_break)[1]
  end = which(lines == line_break)[2]
  template_lines = c(template_lines, lines[end + 1])

  lines = lines[-(start:length(lines))] #nolint
  lines = c(lines, template_lines)
  f = file(fname, "w")
  on.exit(close(f))
  cat(lines, file = f, sep = "\n")
}


check_gitlab_runner = function(fname, template) {
  msg_info("Checking gitlab-ci.yml", padding = 2)
  if (!file.exists(fname)) {
    msg_info("Checking gitlab-ci.yml", padding = 4)
    fs::file_copy(template, fname)
    msg_ok("Updating gitlab-ci", padding = 4)
  }

  if (get_runner_hash(fname) != get_runner_hash(template)) {
    if (is_gitlab()) {
      msg_error("gitlab-ci.yml has changed", padding = 4)
      return(FALSE)
    }
    msg_info("gitlab-ci.yml has changed", padding = 4)
    update_gitlab_ci(fname, template)
    msg_ok("gitlab-ci.yml has been updated", padding = 4)

  }
  return(TRUE)
}

get_r_template_fnames = function(template_repo_loc) {
  file.path(template_repo_loc,
            c("notes/notes_template.Rproj", "slides/slides_template.Rproj",
              "Makefile", ".gitignore",
              "notes/Makefile", "notes/main.Rmd",
              "slides/Makefile"))
}

get_python_template_fnames = function(template_repo_loc) {
  file.path(template_repo_loc,
            c("notes/notes.Rproj", "slides/slides.Rproj",
              "Makefile", ".gitignore",
              "notes/Makefile-python", "notes/main.Rmd",
              "slides/Makefile-python"))
}

#' @title Checks notes files are the same as template
#'
#' Ensures that certain notes files are the same as the notes template.
#' These cannonical files are identical for all notes, e.g. Makefiles,
#' main.Rmd.
#'
#' Typically this used by the gitlab-ci runner. The programming
#' language is inferred via \code{get_repo_language}.
#' @export
check_template = function() {
  if (Sys.getenv("CI_PROJECT_NAME") == "template") {
    # Feedback loop if we test template on it's on master
    return(invisible(NULL))
  }
  type = get_repo_language()
  msg_start("Checking template files...check_template()")

  if (".gitlab-ci.yml" %in% list.files("../", all.files = TRUE)) {
    dir = "../"
  } else {
    dir = "./"
  }
  msg_info("Cloning template repo", padding = 2)
  tmp_dir = tempdir()
  on.exit(unlink(tmp_dir))
  template_repo_loc = file.path(tmp_dir, "template")
  system2("git", args = c("clone",
                          "--depth",
                          "1",
                          "git@gitlab.com:jumpingrivers-notes/template.git", #nolint
                          template_repo_loc))

  proj_name = get_project_name()
  # Ensure Rproj are given sensible names - not just notes.Rproj
  fnames = c(glue("notes/notes_{proj_name}.Rproj"),
             glue("slides/slides_{proj_name}.Rproj"),
             "Makefile", ".gitignore",
             "notes/Makefile", "notes/main.Rmd",
             "slides/Makefile")
  fnames = file.path(dir, fnames)

  if (type == "r") {
    template_fnames = get_r_template_fnames(template_repo_loc)
    runner_check = check_gitlab_runner(file.path(dir, ".gitlab-ci.yml"),
                                       file.path(template_repo_loc, ".gitlab-ci.yml"))
  } else if (type == "python") {
    template_fnames = get_python_template_fnames(template_repo_loc)
    runner_check = check_gitlab_runner(file.path(dir, ".gitlab-ci.yml"),
                                       file.path(template_repo_loc, "python-gitlab-ci.yml"))
  }

  # Compare files to template
  # Keep track of any differences
  changed = logical(length(fnames))
  for (i in seq_along(fnames)) {
    msg_info(glue("Checking {fnames[i]}"), padding = 2)

    if (!file.exists(fnames[i]) && !is_gitlab()) {
      msg_info(glue("{fnames[i]} is missing"), padding = 4)
      fs::file_copy(template_fnames[i], fnames[i])
      msg_ok(glue("Updating {fnames[i]}"), padding = 4)
    }
    changed[i] = has_changed(fnames[i], template_fnames[i])

    if (isTRUE(changed[i])) {
      msg_info(glue("File {fnames[i]} does not match"), padding = 4)
      if (!is_gitlab()) {
        msg_ok(glue("Updating {fnames[i]}"), padding = 4)
        fs::file_copy(template_fnames[i], fnames[i], overwrite = TRUE)
      }
    }
  }

  refs_path = file.path(dir, "notes/references.bib")
  if (!file.exists(refs_path)) {
    msg_info("notes/references.bib is missing", padding = 2)
    fs::file_copy(file.path(template_repo_loc, "notes/references.bib"), refs_path)
    msg_ok("Updating references.bib", padding = 4)
  }

  if ((any(changed) || isFALSE(runner_check)) &&
      nchar(Sys.getenv("GITLAB_CI")) != 0) {
    msg = glue::glue("Files differs from template repo. \\
          Either revert your changes or update the template. \\
          If you think you want to update the template, make a merge \\
          request and ask for feedback.")
    msg_error(msg)
  }

  if (length(list.files(pattern = "*\\.Rproj$", path = dir)) > 0L) {
    msg_error("Don't add Rproj files to the base directory.", stop = TRUE)
  }

  if (length(list.files(pattern = "*\\.Rproj$", path = file.path(dir, "notes"))) != 1L) {
    msg_error("There should only be a single Rproj file in notes/", stop = TRUE)
  }

  if (length(list.files(pattern = "*\\.Rproj$", path = file.path(dir, "slides"))) != 1L) {
    msg_error("There should only be a single Rproj file in slides/", stop = TRUE)
  }

  msg_ok("Template files look good")
  return(invisible(NULL))
}
