get_texlive_version = function() {
  ver = system2("xelatex", "--version", stdout = TRUE)
  as.numeric(stringr::str_extract(ver[1], "20[1|2][0-9]"))
}

required_texlive = function(version) {
  current = get_texlive_version()
  if (current < version) {
    msg = "Old texlive version used. Skipping checks"
    message(blue(msg))
  }
  return(current >= version)
}
