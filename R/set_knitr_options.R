# Taken from knitr split_lines
split_lines = function(x) {
  if (length(grep("\n", x)) == 0L)
    return(x)
  x = gsub("\n$", "\n\n", x)
  x[x == ""] = "\n"
  unlist(strsplit(x, "\n"))
}

#' @title Set consistent knitr options
#'
#' @description Set consistent knitr options
#' @param tidy FALSE
#' @param echo TRUE
#' @param highlight TRUE
#' @param comment #>
#' @param collapse TRUE
#' @param cache TRUE
#' @param fig.align center
#' @param fig.width 4
#' @param fig.height 4
#' @param linewidth Code chunk line width - default 59
#' @param fig.retina Default 1
#' @param out.width Output width default 100%
#' @param out.height Output height default 100%
#' @param dev If \code{NULL} & language R, then \code{cairo_pdf}. Otherwise, \code{pdf}.
#' @param dpi If changed to png, set to 192
#' @param dev.args If \code{dev} changed to \code{png}, use \code{cairo-png}
#' @param ... Additional arguments passed to opt_chunk
#' @export
#' @importFrom knitr opts_chunk knit_hooks
set_knitr_options = function(tidy = FALSE,
                             echo = TRUE,
                             highlight = TRUE,
                             comment = "#>",
                             collapse = TRUE,
                             cache = TRUE,
                             fig.align = "center", # nolint
                             fig.width = 4,        # nolint
                             fig.height = 4,       # nolint
                             linewidth = 59,
                             fig.retina = 1,       # nolint
                             out.width = "100%",   # nolint
                             out.height = "100%",  # nolint
                             dev = NULL,
                             dpi = 192,
                             dev.args = list(png = list(type = "cairo-png")), # nolint
                             ...) {

  if (is.null(dev)) {
    language = get_repo_language()
    if (language == "r") {
      dev = "cairo_pdf"
    } else {
      dev = "pdf"
    }
  }

  knitr::opts_chunk$set(
    tidy = tidy,
    echo = echo,
    highlight = highlight,
    comment = comment,
    collapse = collapse,
    cache = cache,
    fig.align = fig.align,
    fig.width = fig.width,
    fig.height = fig.height,
    linewidth = linewidth,
    fig.retina = fig.retina,
    out.width = out.width,
    out.height = out.height,
    dev = dev,
    dpi = dpi,
    dev.args = dev.args,
    ...)

  hook_output = knit_hooks$get("output")
  knit_hooks$set(output = function(x, options) {
    # use only when the linewidth option is not NULL
    if (!is.null(n <- options$linewidth)) {
      x = split_lines(x)
      # any lines wider than n should be wrapped
      if (any(nchar(x) > n)) x = strwrap(x, width = n)
      # which lines need a comment adding?
      need_comment = grep(pattern = comment, x, invert = TRUE)
      # don't add comment to ```
      need_comment = need_comment[-length(need_comment)]
      # add comment to lines
      x[need_comment] = paste(comment, x[need_comment])
      # paste back together
      x = paste(x, collapse = "\n")
    }
    hook_output(x, options)
  })
  con = config::get()
  if (!is.null(con$knitr)) {
    do.call(knitr::opts_chunk$set, con$knitr)
  }
  check_python()
}
