# jrNotes 0.7.3 _2020-09-17_
  * Bug: Errors hit in `create_final` should be printed in red (not green)

# jrNotes 0.7.2 _2020-09-10_
  * Improvement: Improve readability of output of `check_spelling()`
  * Feature: Force per course WORDLIST

# jrNotes 0.7.1 _2020-09-10_
  * Improvement: Order output of `check_spelling()` by chapter
  * Improvement: Improve readability of output of `check_spelling()`

# jrNotes 0.7.0 _2020-09-10_
  * Internal: Add code coverage badge

# jrNotes 0.6.9 _2020-09-09_
  * Feature: Add links to advert page 

# jrNotes 0.6.8 _2020-09-03_
  * Bug: Return python package name in call to system

# jrNotes 0.6.7 _2020-09-03_
  * Feature: check that pkg name and title match for python notes

# jrNotes 0.6.6 _2020-09-02_
  * Feature: Page header now includes href to jr homepage
  
# jrNotes 0.6.5 _2020-09-02_
  * Bug: Update check_template() to use new naming standard
  * Internal: Ensure no package imports

# jrNotes 0.6.4 _2020-08-29_
  * Internal: Set global error via `set_error()`
  * Feature: Notes must now have an advert, or an error will be raised
  * Bug: Remove line breaks from course titles on `check_pkgtitle()`

# jrNotes 0.6.3 _2020-08-27_
  * Feature: check that pkg name and title match
  * Bug: output from check_news now standard

# jrNotes 0.6.2 _2020-08-10_
  * Bug fix: check condition for whether there is news

# jrNotes 0.6.1 _2020-08-05_
  * Bug fix: check condition for whether there is news

# jrNotes 0.6.0 _2020-08-01_
  * Feature: Remove support for legacy notes, i.e. ones without `config.yml`

# jrNotes 0.5.9 _2020-07-27_
  * Feature: check_news()
  * Feature: Use markdown for `man` pages

# 0.5.8
  * Bug: Now detect flake8 files
  * Feature: Check live directory
  * Feature: Update knitr options, use cairo_pdf, set out.width

# 0.5.7
  * Check for rogue markdown in sidenotes #10

# 0.5.6 
  * Reduce widths by 1 to 59

# 0.5.5
  * Add Git/git to section exceptions
  * Order inst/WORDLIST
  * Remove bookdown, jrPresentation from imports
  * Change clisymbols to cli and standardise
  * Setting width to code chunks (thanks to @theoroe3)
  * Standardise messages

# 0.5.4
  * Add CI and Travis to section headings
  * Export get_repo_language for jrPresentation
  * Add inline to jrStyle for inline images
  
# 0.5.3
  * Update missing packages and clean
  * Bug: Detect fullstops
  * Adding flake8 for Python

# 0.5.2
  * Add course dependencies graph to final page.
  * Adding ggplot2 to suggests - required for some notes

# 0.5.1
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

# 0.5.0
  * Extract latex tags using xparse from latex

# 0.4.23
  * More tweaks to section detection
  * Update spell check

# 0.4.22
  * Reorder checks: move check package near the top
  * Don't enforce version changes on RELEASE: FALSE

# 0.4.21
  * Automatically update config files

# 0.4.20
  * Attendance sheet now created by the office
  * Add watermark via config option

# 0.4.19
  * Check for title case
  * Add spell check

# 0.4.18
  * Update jrstyle for nicer newthought formatting

# 0.4.17
  * Initial stab at spell checker

# 0.4.16
  * Adding checkers: master, duplicated refs, package versions

# 0.4.15
  * Update create_final to deal with edge cases
  * Check for broken URLs

# 0.4.14
  * Check files against cannocial template - check_template()

# 0.4.13
  * Check that version has been updated if notes/c*.Rmd have changed.

# 0.4.12
  * Detect for multiply defined labels and raise error in make final

# 0.4.11
  * Get package from config.yml

# 0.4.10
  * Detect and add quote.tex

# 0.4.9
  * Remove pdftk dependency. Use __qpdf__ instead

# 0.4.8
  * New function: get_r_pkg_name().

# 0.4.6
  * Update Docker file

# 0.4.5
  * Adding rss label

# 0.4.4
  * Adding advert.tex (thanks to @trianglegirl)

# 0.4.3
  * Add `get_jr_packages()` function
  * Adding lintr

# 0.4.2
  * Refactor make final

# 0.4.1
  * Add namer as imports. Required for `make namer` 

# 0.3.10
  * Fix parallel build for create_notes - more error checking.

# 0.3.9
  * Adding generic build script

# 0.3.8
  * Use config for knitr and python

# 0.3.7
  * Move to config file for page title and version

# 0.3.6
  * Detect if pdftk is installed and raise nice error if not

# 0.3.5
  * Removing old knitr functions (commented out, delete when I'm sure).
  * Git hook now enforced!

# 0.3.4
  * Bug in create_final due to re-arranging of gitlab repos

# 0.3.2
  * Copy logo; fixes annoying bug involving spaces and directory names.

# 0.3.1
  * Normalise path for logo
  
# 0.1.9
  * Add to gitignore

# 0.1.8
  * Add to jrStyle.sty to correct fonts on section headings

# 0.1.7
  * Change jrStyle.sty to give numberings in notes (bug in titlesec)
  * Change pre-commit to pre-push
  
# 0.1.6
  * Add pre-commit hook function

# 0.1.4

  * Add my_palette function
  * Add NEWS file
  * Remove indents after code chunks via the .sty file
