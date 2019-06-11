#' Build python vignettes in the package
#'
#' @import fs
#' @import stringr
#' @importFrom purrr walk
#' @export
build_python_vignettes = function(){
  # find vignette sources
  f = fs::dir_ls("./vignette_src/")
  src = f[stringr::str_detect(f, "vignette_src/(.*)[0-9].Rmd$")]
  # build vignettes
  purrr::walk(src, rmarkdown::render)
  # move to relevant directory in package
  f = fs::dir_ls("./vignette_src/")
  pdfs = f[stringr::str_detect(f, "vignette_src/(.*)[0-9].pdf$")]
  target = list.dirs()
  pkg_root = target[stringr::str_detect(basename(target), "jr(.*)")]
  target = target[stringr::str_detect(target, "vignettes")]
  if (length(target) == 0){
    fs::dir_create(pkg_root, "vignettes")
    target = fs::path(pkg_root, "vignettes")
  }


  # strip out the path from the dist/tar
  target = target[!stringr::str_detect(target, "dist")]
  targets = gsub("./vignette_src", target, pdfs)
  fs::file_copy(pdfs, targets, overwrite = TRUE)
}
