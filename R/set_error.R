# .jrnotes is a hidden environment
# Setting error to be TRUE allows the check_* function to delay
# the stop() call to the end of all checks
set_error = function(origin = NULL) {
  .jrnotes$error = TRUE
  .jrnotes$error_funs = c(.jrnotes$error_funs, origin)
  .jrnotes$error_funs = unique(.jrnotes$error_funs)
  return(invisible(NULL))
}
