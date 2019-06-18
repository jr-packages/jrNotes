# Only knit the document if the hash has changed
#' @importFrom stringr str_replace
knit_rmd = function(fname, hashes) {
  if (fs::file_exists("jrnotes_cache/hashes.rds")) {
    old_hashes = readRDS("jrnotes_cache/hashes.rds")
  } else{
    old_hashes = paste0(hashes, "-")
    names(old_hashes) = names(hashes)
  }
  # Changed X.Rmd X.rds #nolint
  md_fname = stringr::str_replace(string = fname,
                                  pattern = "\\.Rmd$",
                                  replacement = "\\.rds")
  md_fname = file.path("jrnotes_cache", md_fname)

  # is.na needed when new chapters are added
  if (!is.na(hashes[fname]) &&
      !is.na(old_hashes[fname]) &&
      hashes[fname] == old_hashes[fname] &&
      fs::file_exists(md_fname)) { # Very conservative #nolint
    out = readRDS(md_fname)
  } else {
    out = try(knitr::knit_child(fname, envir = globalenv()))
    if (class(out) != "try-error") saveRDS(out, md_fname) # Store .md
  }
  return(out)
}

#' Generate build script
#'
#' Scans for chaptersX.Rmd and appendix.Rmd and builds main.pdf
#' @param fnames If \code{NULL} scans for chaptersX.Rmd and appendix.Rmd.
#' Otherwise, just uses the names passed.
#' @param advert Should the advert be included. Default \code{TRUE}.
#' @importFrom digest digest
#' @export
create_notes = function(fnames = NULL, advert = TRUE) {

  if (is.null(fnames)) {
    fnames = c(
      list.files(path = ".", pattern = "^chapter[0-9]\\.Rmd$"),
      list.files(path = ".", pattern = "^appendix\\.Rmd$")
    )
  }
  fs::dir_create("jrnotes_cache")
  if (length(fnames) == 0L) return(NULL)

  hashes = vapply(fnames,
                  function(i) digest::digest(readLines(i)),
                  FUN.VALUE = character(1))

  create_title_page()
  create_jrStyle()
  create_advert()
  set_knitr_options()
  set_options()

  cores = config::get("cores")
  # Parallel doesn't seem to work well with knit_child
  # If something is wrong, errors, don't really work
  if (is.null(cores) || cores == 1L) {
    out = lapply(fnames, knit_rmd, hashes = hashes)
  } else {
    out = parallel::mclapply(fnames, knit_rmd,
                             hashes = hashes,
                             mc.cores = cores,
                             mc.cleanup = TRUE)
  }
  is_error = unlist(lapply(out, class))
  hashes = hashes[is_error != "try-error"]
  saveRDS(hashes, "jrnotes_cache/hashes.rds")

  for (i in seq_along(fnames)) {
    if (is_error[i] == "try-error") {
      err_message = glue(
        "\n\n{fnames[i]} did not knit correctly.
       {out[[i]]}")
      stop(err_message, call. = FALSE)
    }
  }
  last_page = out[[length(out)]]
  out[[length(out)]] = paste(last_page, create_version(), collapse = "\n")

  ## Move chapters up one and add in the advert & quote
  if (file.exists("quote.tex")) {
    out[seq_along(out) + 1] = out
    out[[1]] = "\\include{quote}\n"
  }
  if (isTRUE(advert)) {
    out[seq_along(out) + 1] = out
    out[[1]] = "\\include{advert}\n"
  }
  out
}
