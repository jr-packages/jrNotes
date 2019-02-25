# Only knit the document if the hash has changed
#' @importFrom stringr str_replace
knit_rmd = function(fname, hashes, ...) {
  if (fs::file_exists("jrnotes_cache/hashes.rds")) {
    old_hashes = readRDS("jrnotes_cache/hashes.rds")
  } else{
    old_hashes = paste0(hashes, "-")
    names(old_hashes) = names(hashes)
  }

  # XXX.Rmd -> XXX.rds
  md_fname = stringr::str_replace(string = fname,
                                   pattern = "\\.Rmd$",
                                   replacement = "\\.rds")
  md_fname = file.path("jrnotes_cache", md_fname)
  # is.na needed when new chapters are added
  if (is.na(hashes[fname]) && hashes[fname] == old_hashes[fname]) {
    out = readRDS(md_fname)
  } else {
    out = knitr::knit_child(fname, ...)
    saveRDS(out, md_fname) # Store .md
  }
  return(out)
}

#' Generate build script
#'
#' Scans for chaptersX.Rmd and appendix.Rmd and builds main.pdf
#' @param fnames If \code{NULL} scans for chaptersX.Rmd and appendix.Rmd
#' @importFrom digest digest
#' @export
create_notes = function(fnames = NULL) {
  if(is.null(fnames)) {
    fnames = c(
      list.files(path = ".", pattern = "^chapter[0-9]\\.Rmd$"),
      list.files(path = ".", pattern = "^appendix\\.Rmd$")
    )
  }
  fs::dir_create("jrnotes_cache")
  if (length(fnames) == 0) return(NULL)

  hashes = vapply(fnames,
                  function(i) digest::digest(readLines(i)),
                  FUN.VALUE = character(1))

  create_title_page()
  create_jrStyle()
  set_knitr_options()
  set_options()

  cores = config::get("cores")
  if (is.null(cores) || cores == 1L) {
    out = lapply(fnames, knit_rmd, hashes = hashes)
  } else {
    out = parallel::mclapply(fnames, knit_rmd,
                             hashes = hashes, envir = parent.frame(),
                             mc.cores = cores)
  }
  if (length(out) > 1) {
    last_page = out[[length(out)]]
    out[[length(out)]] = paste(last_page, create_version(), collapse = "\n")
  }
  saveRDS(hashes, "jrnotes_cache/hashes.rds")
  out
}
