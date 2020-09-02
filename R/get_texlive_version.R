#' @importFrom stringr str_extract
get_texlive_version = function() {
  ver = system2("xelatex", "--version", stdout = TRUE)
  as.numeric(stringr::str_extract(ver[1], "20[1|2][0-9]"))
}

required_texlive = function(version) {
  current = get_texlive_version()
  if (current < version) {
    msg_info("Old texlive version used. Skipping checks")
  }
  return(current >= version)
}
