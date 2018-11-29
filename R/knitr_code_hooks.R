#' #' knitr code hooks
#' #'
#' #' These functions were hacked by Jamie. No-one really know what they do, or how
#' #' they work. In fact, I'm not convinced that knitr_formatting is correct. What's
#' #' color1 and color2????
#' #' @export
#' knitr_colours = function() {
#'   knitr::knit_hooks$set(
#'     warning = knitr:::.color.block('\\color{warningcolor}{', '}'),
#'     message = knitr:::.color.block('\\itshape\\color{messagecolor}{', '}'),
#'     error = knitr:::.color.block('\\bfseries\\color{errorcolor}{', '}')
#'   )
#'
#' }
#'
#'
#' #' @export
#' #' @rdname  knitr_colours
#' knitr_formatting = function() {
#'   knitr::knit_hooks$set(
#'     structure(
#'       list(
#'         source = function (x, options){
#'           x = knitr:::hilight_source(x, "latex", options)
#'           if (options$highlight) {
#'             if (options$engine == "R" || x[1] != "\\noindent") {
#'               paste(c("\\begin{alltt}", x, "\\end{alltt}", ""),
#'                     collapse = "\n")
#'             }
#'             else {
#'               if ((n <- length(x)) > 4)
#'                 x[n - 2] = sub("\\\\\\\\$", "", x[n - 2])
#'               paste(c(x, ""), collapse = "\n")
#'             }
#'           }
#'           else knitr:::.verb.hook(x)
#'         },
#'         output = function (x, options){
#'           if (knitr:::output_asis(x, options)) {
#'             paste0("\\end{kframe}", x, "\\begin{kframe}")}
#'           else knitr:::.verb.hook(x)
#'         },
#'         warning = function (x, options){
#'           x = gsub("\n*$", "", x)
#'           x = knitr:::escape_latex(x, newlines = TRUE, spaces = TRUE)
#'           x = gsub("\"", "\"{}", x)
#'           sprintf("\n\n{\\ttfamily\\noindent%s%s%s}", color1, x, color2)
#'         },
#'         message = function (x, options){
#'
#'           x = gsub("\n*$", "", x)
#'           x = knitr:::escape_latex(x, newlines = TRUE, spaces = TRUE)
#'           x = gsub("\"", "\"{}", x)
#'           sprintf("\nXXXXXXX\n{\\ttfamily\\noindent%s%s%s}", color1, x, color2)
#'         },
#'         error = function (x, options){
#'           x = gsub("\n*$", "", x)
#'           x = knitr:::escape_latex(x, newlines = TRUE, spaces = TRUE)
#'           x = gsub("\"", "\"{}", x)
#'           sprintf("\n\n{\\ttfamily\\noindent%s%s%s}", color1, x, color2)
#'         },
#'         plot = function (x, options)
#'         {
#'           if (isTRUE(options$fig.margin)) {
#'             options$fig.env = "marginfigure"
#'             if (is.null(options$fig.cap))
#'               options$fig.cap = ""
#'           }
#'           else if (isTRUE(options$fig.fullwidth)) {
#'             options$fig.env = "figure*"
#'             if (is.null(options$fig.cap))
#'               options$fig.cap = ""
#'           }
#'           paste0("\\end{kframe}", knitr:::hook_plot_tex(x, options), "\n\\begin{kframe}")
#'         },
#'         inline = function (x){
#'           if (is.numeric(x)) {
#'             x = knitr:::format_sci(x, "latex")
#'             i = grep("[^-0-9.,]", x)
#'             x[i] = sprintf("\\ensuremath{%s}", x[i])
#'             if (getOption("OutDec") != ".")
#'               x = sprintf("\\text{%s}", x)
#'           }
#'           knitr:::.inline.hook(x)
#'         },
#'         chunk = function (x, options){
#'           ai = knitr:::output_asis(x, options)
#'           col = if (!ai)
#'             paste0(knitr:::color_def(options$background), if (!knitr:::is_tikz_dev(options))
#'               "\\color{fgcolor}")
#'           k1 = paste0(col, "\\begin{kframe}\n")
#'           k2 = "\\end{kframe}"
#'           x = knitr:::.rm.empty.envir(paste0(k1, x, k2))
#'           size = if (options$size == "normalsize")
#'             ""
#'           else sprintf("\\%s", options$size)
#'           if (!ai)
#'             x = sprintf("\\begin{knitrout}%s\n%s\n\\end{knitrout}",
#'                         size, x)
#'           if (options$split) {
#'             name = knitr:::fig_path(".tex", options, NULL)
#'             if (!file.exists(dirname(name)))
#'               dir.create(dirname(name))
#'             cat(x, file = name)
#'             sprintf("\\input{%s}", name)
#'           }
#'           else x
#'         },
#'         text = function (x)
#'           if(length(grep("^\\s[a-zA-Z]", x)) == 0L) x else  paste("\\noindent", x),
#'         document = function (x)
#'           x
#'       ),
#'       .Names = c("source", "output", "warning", "message", "error",
#'                  "plot", "inline", "chunk", "text",
#'                  #"evaluate",
#'                  "document")
#'     )
#'   )
#' }
