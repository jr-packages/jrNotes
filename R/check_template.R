has_changed = function(i, fnames, templates) {
  fname1 = fnames[i]; template_file = templates[i]
  if (!file.exists(fname1) && !is_gitlab()) {
    fs::file_copy(template_file, fname1)
    msg_info(glue("Updating {fname1}"), padding = TRUE)
    return(invisible(TRUE))
  }

  d1 = digest::digest(readLines(fname1))
  d2 = digest::digest(readLines(template_file))
  if (d1 != d2) {
    if (!is_gitlab()) {
      msg_info(glue("Updating {fname1}"), padding = TRUE)
      fs::file_copy(template_file, fname1, overwrite = TRUE)
    }
    return(invisible(TRUE))
  }
  msg_success(fname1, padding = TRUE)
  return(invisible(FALSE))
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
  if (!file.exists(fname)) {
    fs::file_copy(template, fname)
    msg_info("Updating gitlab-ci", padding = TRUE)
  } else if (get_runner_hash(fname) != get_runner_hash(template)) {
    if (is_gitlab()) {
      msg_error("gitlab-ci.yml has changed", padding = TRUE)
      return(FALSE)
    }
    update_gitlab_ci(fname, template)
    msg_info("gitlab-ci.yml has been updated", padding = TRUE)
  } else {
    msg_success(fname, padding = TRUE)
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
            c("notes/notes_template.Rproj", "slides/slides_template.Rproj",
              "Makefile", ".gitignore",
              "notes/Makefile-python", "notes/main.Rmd",
              "slides/Makefile-python"))
}

get_root_dir = function() {
  if (".git" %in% list.files("../", all.files = TRUE)) {
    dir = ".."
  } else {
    dir = "./"
  }
  dir
}

#' Checks notes files are the same as template
#'
#' Ensures that certain notes files are the same as the notes template.
#' These canonical files are identical for all notes, e.g. Makefiles,
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
  dir = get_root_dir()

  msg_info("Cloning template repo", padding = TRUE)
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
  changed = vapply(seq_along(fnames), has_changed,
                   fnames, template_fnames, FUN.VALUE = logical(1))
  changed = any(changed)

  refs_path = file.path(dir, "notes/references.bib")
  if (file.exists(refs_path)) {
    msg_success("notes/references.bib", padding = TRUE)
  } else {
    msg_info("notes/references.bib is missing", padding = TRUE)
    fs::file_copy(file.path(template_repo_loc, "notes/references.bib"), refs_path)
    msg_success("Updating references.bib", padding = TRUE)
  }

  if ((changed || isFALSE(runner_check)) &&
      nchar(Sys.getenv("GITLAB_CI")) != 0) {
    msg = glue::glue("Files differs from template repo. \\
          Either revert your changes or update the template. \\
          If you think you want to update the template, make a merge \\
          request and ask for feedback.")
    msg_error(msg)
  }

  if (length(list.files(pattern = "*\\.Rproj$", path = dir)) > 0L) {
    msg_error("Don't add Rproj files to the base directory.")
    changed = TRUE
  }

  if (length(list.files(pattern = "*\\.Rproj$", path = file.path(dir, "notes"))) != 1L) {
    msg_error("There should only be a single Rproj file in notes/")
    changed = TRUE
  }

  if (length(list.files(pattern = "*\\.Rproj$", path = file.path(dir, "slides"))) != 1L) {
    msg_error("There should only be a single Rproj file in slides/")
    changed = TRUE
  }

  if (isFALSE(changed)) msg_success("Template files look good")
  return(invisible(NULL))
}
