#!/usr/bin/env racket


;; This file is part of racket-mike.

;; racket-mike is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, version 3.

;; racket-mike is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with racket-mike.  If not, see <https://www.gnu.org/licenses/>.

;; Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>
;; Licensed under the GNU GPL v3 License
;; SPDX-License-Identifier: GPL-3.0-only


#lang racket/base

(require
 racket/file
 racket/string
 racket/system
 "variables.rkt"
 )

(provide
 (all-defined-out)
 variables
 set-variable
 display-variables
 )


(define (recursively-delete dirname start-path)
  (for
      ([dir (reverse (find-files directory-exists? start-path))])
    (when (equal? (basename dir) dirname)
      (delete-directory/files dir))
    )
  )


;; Rules

(define rules (make-hash))

(define-syntax-rule (define-rule name body ...)
  (begin
    (define (name) body ...)
    (hash-set! rules (symbol->string 'name) name)
    )
  )

(define (display-rules)
  (displayln "+ Rules:")
  (displayln (string-join (sort (hash-keys rules) string<?) "\n"))
  )


(define (execute #:verbose [verbose #t] . vs)
  (let
      ([command (string-join vs)])
    (when verbose
      (displayln (string-append "M-> " command)))
    (when (not
           (system command))
      (error 'failed command)
      )
    )
  )


;; Main
(define-rule all  (install) (setup) (test))
(define-rule compile
  (execute (RACO) "make" (COMPILE_FLAGS) (ENTRYPOINT))
  )
(define-rule run
  (execute (RACKET) (RUN_FLAGS) (ENTRYPOINT))
  )
(define-rule install
  (execute (RACO) "pkg install" (INSTALL_FLAGS) "--name" (PACKAGE_NAME))
  )

;; Doumentation
(define-rule docs-dir
  (make-directory* (PACKAGE_DOC_DIR))
  )
(define-rule docs-html  (docs-dir)
  (execute (SCRBL) "--html" (SCRBL_FLAGS) (PACKAGE_SCRBL))
  (execute (LN)
           (string-append "../" (PACKAGE_DOC_DIR) "/" (PACKAGE_NAME) ".html")
           (string-append (PACKAGE_DOC_DIR) "/" "index.html"))
  )
(define-rule docs-latex  (docs-dir)
  (execute (SCRBL) "--latex" (SCRBL_FLAGS) (PACKAGE_SCRBL))
  )
(define-rule docs-markdown  (docs-dir)
  (execute (SCRBL) "--markdown" (SCRBL_FLAGS) (PACKAGE_SCRBL))
  )
(define-rule docs-text  (docs-dir)
  (execute (SCRBL) "--text" (SCRBL_FLAGS) (PACKAGE_SCRBL))
  )
(define-rule docs  (docs-html) (docs-latex) (docs-markdown) (docs-text))

;; Distribution
(define-rule exe  (compile)
  (make-directory* "./bin")
  (execute (RACO) "exe" (EXE_FLAGS) (ENTRYPOINT))
  )
(define-rule pkg  (clean)
  (execute (RACO) "pkg create --source" (PWD))
  )

;; Removal
(define-rule distclean
  (when (directory-exists? (PACKAGE_BIN_DIR))
    (delete-directory/files (PACKAGE_BIN_DIR)))
  (when (file-exists? (PACKAGE_ZIP))
    (delete-file (PACKAGE_ZIP)))
  )
(define-rule clean  (distclean)
  (recursively-delete "compiled" (PWD))
  (recursively-delete "doc" (PWD))
  )
(define-rule remove
  (execute (RACO) "pkg rem" (DO_DOCS) (PACKAGE_NAME))
  )
(define-rule purge      (remove)    (clean))
(define-rule reinstall  (remove)    (install))
(define-rule resetup    (reinstall) (setup))

;; Tests
(define-rule setup
  (execute (RACO) "setup --tidy --avoid-main" (DEPS_FLAGS) "--pkgs" (PACKAGE_NAME))
  )
(define-rule check-deps
  (execute (RACO) "setup" (DO_DOCS) (DEPS_FLAGS) (PACKAGE_NAME))
  )
(define-rule test-local
  (execute (RACO) "test" (TEST_FLAGS) (string-append "./" (PACKAGE_NAME)))
  )
(define-rule test
  (execute (RACO) "test" (TEST_FLAGS) "--package" (PACKAGE_NAME))
  )

;; Everything
(define-rule show-rules  (display-rules))
(define-rule show-variables  (display-variables))
(define-rule show  (show-rules) (show-variables))
(define-rule everything-test  (clean) (compile) (install)
  (setup) (check-deps) (test) (purge))
(define-rule everything-dist  (pkg) (exe))