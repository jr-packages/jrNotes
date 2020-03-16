# Taken from knitr split_lines
split_lines = function(x) {
  if (length(grep("\n", x)) == 0L)
    return(x)
  x = gsub("\n$", "\n\n", x)
  x[x == ""] = "\n"
  unlist(strsplit(x, "\n"))
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
#' @param linewidth Code chunk line width - default 59
#' @param ... Additional arguments passed to opt_chunk
#' @export
#' @import knitr
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
                             ...
) {
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
  if (fs::file_exists("config.yml")) {
    con = config::get()
    if (!is.null(con$knitr)) {
      do.call(knitr::opts_chunk$set, con$knitr)
    }
  }
  check_python()
}
