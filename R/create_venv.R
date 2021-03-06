#' @title Create and use a virtualenv with python packages listed in config.yml
#' installed
#'
#' @description Create and use a virtualenv with python packages listed in config.yml
#' @param venv_dir The directory in which to create the virtualenv (typically
#' "notes" or "slides")
#' installed
#' @export
provision_venv = function(venv_dir = "notes") {
  ## Get python packages listed in config.yml
  pkgs = get_python_pkg_name()

  ## If no python packages listed don't do anything
  if (length(pkgs) == 0L) return(invisible(NULL))
  msg_start("Creating a venv...provision_venv()")
  venv_path = file.path(get_root_dir(), venv_dir, "venv")
  ## If a virtualenv hasn't already been made, make it
  if (!dir.exists(venv_path)) {
    create_venv(pkgs, venv_dir)
  }

  ## Activate the virtualenv
  reticulate::use_virtualenv(venv_path)
  Sys.setenv("RETICULATE_PYTHON" = file.path(venv_path, "/bin/python"))
}

create_venv = function(pkgs, venv_dir) {
  ## Unique in case jrpytests or jupytext listed in config.yml
  pkgs = unique(c(pkgs, "jrpytests", "jupytext"))

  ## By default reticulate creates virtualenvs in ~/.virtualenv
  ## To change where the virtualenv is created we have to use
  ## the WORKON_HOME environment variable
  Sys.setenv(WORKON_HOME = file.path(get_root_dir(), venv_dir))

  ## Create the virtualenv
  reticulate::virtualenv_create(envname = "venv",
                                python = system2("which", "python3", stdout = TRUE),
                                packages = pkgs)
  return(invisible(NULL))
}
