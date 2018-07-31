#' Set Standard options
#'
#' Set consistent options for notes / check pandoc version
#' @param digits 3
#' @param dplyr.print_min 4
#' @param dplyr.print_max 4
#' @param htmltools.dir.version FALSE
#' @param min_pandoc_version 2.2
#' @export
set_options = function(digits = 3,
                       dplyr.print_min = 4,
                       dplyr.print_max = 4,
                       htmltools.dir.version = FALSE,
                       min_pandoc_version = 2.2
) {
  min_pandoc_version = as.numeric_version(min_pandoc_version)
  pandoc_version = system2("pandoc", args = "-v", stdout = TRUE)
  pandoc_version = as.numeric_version(strsplit(pandoc_version[1], "pandoc ")[[1]][2])

  if(pandoc_version < min_pandoc_version){
    stop(paste0("Rstudio pandoc version must be ", min_pandoc_version,  " or higher"))
  }

  options(digits = digits,
          dplyr.print_min = dplyr.print_max,
          dplyr.print_max = dplyr.print_min,
          htmltools.dir.version = htmltools.dir.version
  )
}


#' Set consistent knitr options
#'
#' Set consistent knitr options
#' @param tidy FALSE
#' @param echo TRUE
#' @param highlight TRUE
#' @param comment #>
#' @param collapse TRUE
#' @param cache TRUE
#' @param fig.align center
#' @param fig.width 4
#' @param fig.height 4
#' @export
#' @import knitr
set_knitr_options = function(tidy = FALSE,
                             echo = TRUE,
                             highlight = TRUE,
                             comment = "#>",
                             collapse = TRUE,
                             cache = TRUE,
                             fig.align = "center",
                             fig.width = 4,
                             fig.height = 4
) {
  knitr::opts_chunk$set(
    tidy =tidy,
    echo=echo,
    highlight = highlight,
    comment = comment,
    collapse = collapse,
    cache = cache,
    fig.align=fig.align,
    fig.width = fig.width,
    fig.height = fig.height)
}

