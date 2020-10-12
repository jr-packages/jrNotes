# jrNotes 0.9.4 _2020-10-13_
  * Improvement: Allow captioning and cross-referencing of code chunks

# jrNotes 0.9.3 _2020-10-12_
  * Improvement: Improved styling of chapter section and subsections

# jrNotes 0.9.2 _2020-10-12_
  * Internal: Add extra LaTeX packages to `jrStyle` to support RStan course

# jrNotes 0.9.1 _2020-10-12_
  * Internal: tidy up `jrStyle.sty`

# jrNotes 0.9.0 _2020-10-06_
  * Bug: check title length incorrectly detected wrong line breaks
  * Internal: Remove {ggplot2} from Suggests
  * Internal: Move {rmarkdown} and {formatR} to Imports

# jrNotes 0.8.* _2020-10-05_
  * Feature: Add addin to collapse minor NEWS versions
  * Feature: Point version number shouldn't go past 9
  * Feature: Check title length
  * Improvement: Add the imports from the r_pkg to WORDLIST
  * Improvement: Output unstaged file names
  * Improvement: Record the error origin
  * Improvement: specify config_issue = TRUE in check_config.R
  * Improvement: `check_url()` prints problem URLs along with their status
  * Improvement: Add R, Python & deb_packages to spelling exceptions
  * Internal: Use `{cli}` instead of our own system
  * Internal: Set `depth` equal to 1 when cloning template
  * Bug: Don't lookup package version twice in get_logo_path()
  * Bug: check_pkgs shouldn't raise an error on CI
  * Bug: Fix `get_logo_path()` for python notes

# jrNotes 0.7.* _2020-09-24_
  * Improvement: Stop using generic `packages` in config.yml
  * Improvement: Don't add page numbers to advert and course-dependencies
  * Improvement: Number course contents from page 1
  * Improvement: Add `\usepackage{float}` to `jrStyle.sty` (previously
    specified in `header-includes` of `main.Rmd` in notes template)
  * Improvement: Improve readability of output of `check_spelling()`
  * Improvement: Order output of `check_spelling()` by chapter
  * Improvement: Improve readability of output of `check_spelling()`
  * Improvement: specify `config_issue = TRUE` in `check_config.R`

  * Feature: Include line number indicator in `check_section_headers()` error message
  * Feature: Add first test to `{jrNotes}` (`check_section_headers()`)
  * Feature: Force per course WORDLIST
  * Bug: Fix bug introduced in `get_logo_path.R` by changes to `config.yml`
  * Bug: Errors hit in `create_final()` should be printed in red (not green)
  * Bug: repos created with `jrNotes::clone_git_repo()` could not be pushed

  * Internal: Add code coverage badge

# jrNotes 0.6.* _2020-09-09_
  * Feature: Add links to advert page 
  * Bug: Return python package name in call to system
  * Feature: check that pkg name and title match for python notes
  * Feature: Page header now includes href to jr homepage
  * Bug: Update check_template() to use new naming standard
  * Internal: Ensure no package imports
  * Internal: Set global error via `set_error()`
  * Feature: Notes must now have an advert, or an error will be raised
  * Bug: Remove line breaks from course titles on `check_pkgtitle()`
  * Feature: check that pkg name and title match
  * Bug: output from check_news now standard
  * Bug fix: check condition for whether there is news
  * Feature: Remove support for legacy notes, i.e. ones without `config.yml`

# jrNotes 0.5.* _2020-07-27_
  * Feature: check_news()
  * Feature: Use markdown for `man` pages
  * Bug: Now detect flake8 files
  * Feature: Check live directory
  * Feature: Update knitr options, use cairo_pdf, set out.width
  * Check for rogue markdown in sidenotes #10
  * Reduce widths by 1 to 59
  * Add Git/git to section exceptions
  * Order inst/WORDLIST
  * Remove bookdown, jrPresentation from imports
  * Change clisymbols to cli and standardise
  * Setting width to code chunks (thanks to @theoroe3)
  * Standardise messages
  * Add CI and Travis to section headings
  * Export get_repo_language for jrPresentation
  * Add inline to jrStyle for inline images
  * Update missing packages and clean
  * Bug: Detect fullstops
  * Adding flake8 for Python
  * Add course dependencies graph to final page.
  * Adding ggplot2 to suggests - required for some notes

## Cleaners
  * Update cleaners for HTML books
  * Remove old files in final/ when make final

## Checks
  * Improve title checking
  * Move check_template & check_lint to create_final
  * Check margin notes & captions finish with a full stop
  * Ensure library calls use quotes
  * Check for correct texlive version
  * Check for empty notes/practical files
  * Check for markdown versions of tufte

## Misc
  * Try to detect programming lanaguage
  * Add the course package version to the final page
  * Update travis.yml
  * Extract latex tags using xparse from latex

# 0.4.*
  * More tweaks to section detection
  * Update spell check
  * Reorder checks: move check package near the top
  * Don't enforce version changes on RELEASE: FALSE
  * Automatically update config files
  * Attendance sheet now created by the office
  * Add watermark via config option
  * Check for title case
  * Add spell check
  * Update jrstyle for nicer newthought formatting
  * Initial stab at spell checker
  * Adding checkers: master, duplicated refs, package versions
  * Update create_final to deal with edge cases
  * Check for broken URLs
  * Check files against cannocial template - check_template()
  * Check that version has been updated if notes/c*.Rmd have changed.
  * Detect for multiply defined labels and raise error in make final
  * Get package from config.yml
  * Detect and add quote.tex
  * Remove pdftk dependency. Use __qpdf__ instead
  * New function: get_r_pkg_name().
  * Update Docker file
  * Adding rss label
  * Adding advert.tex (thanks to @trianglegirl)
  * Add `get_jr_packages()` function
  * Adding lintr
  * Refactor make final
  * Add namer as imports. Required for `make namer` 

# 0.3.*
  * Fix parallel build for create_notes - more error checking.
  * Adding generic build script
  * Use config for knitr and python
  * Move to config file for page title and version
  * Detect if pdftk is installed and raise nice error if not
  * Removing old knitr functions (commented out, delete when I'm sure).
  * Git hook now enforced!
  * Bug in create_final due to re-arranging of gitlab repos
  * Copy logo; fixes annoying bug involving spaces and directory names.
  * Normalise path for logo
  
# 0.1.*
  * Add to gitignore
  * Add to jrStyle.sty to correct fonts on section headings
  * Change jrStyle.sty to give numberings in notes (bug in titlesec)
  * Change pre-commit to pre-push
  * Add pre-commit hook function
  * Add my_palette function
  * Add NEWS file
  * Remove indents after code chunks via the .sty file
