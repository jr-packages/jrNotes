test_file = function(fname1, fname2) {
  d1 = digest::digest(readLines(fname1))
  d2 = digest::digest(readLines(fname2))
  if (d1 != d2) {
    stop("File differs from template.
         Either revert your changes or update the template.
         If you think you want to update the template, discuss it with the
         team in case you break something.", call. = FALSE)
  }
}

## TODO: Check gitlab-ci.yml #nolint
#' @title Checks notes files are the same as template
#'
#' Ensures that certain notes files are the same as the notes template.
#' These cannonical files are identical for all notes, e.g. Makefiles,
#' main.Rmd.
#'
#' Typically this used by the gitlab-ci runner.
#' @param template_repo_loc Path to gitlab template location. If \code{NULL}
#' clones repo in \code{tempdir()}.
#' @export
check_template = function(template_repo_loc = NULL) {
  if (is.null(template_repo_loc)) {
    tmp_dir = tempdir()
    on.exit(unlink(tmp_dir))
    template_repo_loc = file.path(tmp_dir, "template")
    system2("git", args = c("clone", "--depth", "1",
                            "git@gitlab.com:jumpingrivers-notes/template.git", #nolint
                            template_repo_loc))
  }

  fnames = c("Makefile", ".gitignore",
             "notes/Makefile", "notes/main.Rmd",
             "slides/Makefile", "slide/main.Rmd")
  template_fnames = file.path(template_repo_loc, fnames)

  for (i in seq_along(fnames)) {
    test_file(fnames[i], template_fnames[i])
  }
}
