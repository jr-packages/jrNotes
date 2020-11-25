get_config = function() {
  path = get_root_dir()
  config = yaml::read_yaml(file.path(path, "notes", "config.yml"),
                           eval.expr = TRUE)
  config = config$default

  ## If missing, then assume FALSE
  rss = config$rss
  config$rss = !is.null(rss) && (isTRUE(rss) || rss == "yes")

  ## If missing, assume TRUE
  lintr = config$lintr
  config$lintr = is.null(lintr) || (isTRUE(lintr) || lintr == "yes")

  vignettes = config$vignettes
  config$vignettes = is.null(vignettes) || (isTRUE(vignettes) || vignettes == "yes")

  cores = config$cores
  config$cores = ifelse(is.null(cores), 1, cores)

  advert = config$advert
  config$advert = ifelse(is.null(advert), "advert", advert)

  config
}
