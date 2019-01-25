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
  tex_fname = stringr::str_replace(string = fname,
                                   pattern = "\\.Rmd$",
                                   replacement = "\\.rds")
  tex_fname = file.path("jrnotes_cache", tex_fname)
  message(tex_fname)
  if (hashes[fname] == old_hashes[fname]) {
    out = readRDS(tex_fname)
  } else {
    out = knitr::knit_child(fname, ...)
    saveRDS(out, tex_fname) # Store .tex
  }
  return(out)
}

#' Generate build script
#'
#' Scans for chaptersX.Rmd and appendix.Rmd and builds main.pdf
#' @importFrom digest digest
#' @export
create_notes = function() {
  chapters = c(
    list.files(path = ".", pattern = "^chapter[0-9]\\.Rmd$"),
    list.files(path = ".", pattern = "^appendix\\.Rmd$")
  )
  fs::dir_create("jrnotes_cache")
  if (length(chapters) == 0) return(NULL)

  hashes = vapply(chapters,
                  function(i) digest::digest(readLines(i)),
                  FUN.VALUE = character(1))

  create_title_page()
  create_jrStyle()
  set_knitr_options()
  set_options()

  cores = config::get("cores")
  if (is.null(cores) || cores == 1L) {
    out = lapply(chapters, knit_rmd, hashes = hashes)
  } else {
    out = parallel::mclapply(chapters, knit_rmd,
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
