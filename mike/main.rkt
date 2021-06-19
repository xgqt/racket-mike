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
 racket/cmdline
 racket/string
 racket/system
 syntax/parse/define
 racket/list
 )


(define-syntax-rule (define-var name body)
  (define name (make-parameter (if (getenv (symbol->string 'name))
                                   (getenv (symbol->string 'name))
                                   body
                                   )))
    )


(define (execute #:verbose [verbose #t] . vs)
  (let
      ([command (string-join vs)])
    (when verbose
      (displayln (string-append "M-> " command)))
    (system command)
    )
  )


(define rules (make-hash))

(define-syntax-parse-rule (define-rule name:id body ...)
  (begin
    (define (name) body ...)
    (hash-set! rules (symbol->string 'name) name)
    )
  )


(module+ main
  ;; --- SYSTEM ---
  (define-var PWD
    (current-directory))
  (define-var LN
    "ln -fs")
  (define-var MKDIR
    "mkdir -p")
  (define-var RACKET
    "racket")
  (define-var RACO
    "raco")
  (define-var SCRBL
    (string-append (RACO) "scribble"))
  ;; --- PACKAGE ---
  (define-var PACKAGE_NAME
    (path->string (last (explode-path (PWD)))))
  (define-var PACKAGE_EXE
    (PACKAGE_NAME))
  (define-var PACKAGE_BIN_DIR
    "./bin")
  (define-var PACKAGE_DOC_DIR
    "./doc")
  (define-var PACKAGE_SCRBL
    (string-append (PACKAGE_NAME) "/scribblings" (PACKAGE_NAME) ".scrbl"))
  (define-var PACKAGE_BIN
    (string-append (PACKAGE_BIN_DIR) "/" (PACKAGE_EXE)))
  (define-var PACKAGE_ZIP
    (string-append (PACKAGE_NAME) ".zip"))
  ;; --- ARGUMENTS ---
  (define-var ENTRYPOINT
    (string-append (PACKAGE_NAME) "/main.rkt"))
  (define-var COMPILE_FLAGS
    "-v")
  (define-var RUN_FLAGS
    "")
  (define-var SCRBL_FLAGS
    (string-append "--dest " (PACKAGE_DOC_DIR) " ++main-xref-in"))
  (define-var EXE_FLAGS
    (string-append "--orig-exe -v -o " (PACKAGE_BIN)))
  (define-var DO_DOCS
    "--no-docs")
  (define-var INSTALL_FLAGS
    (string-append "--auto " (DO_DOCS)))
  (define-var DEPS_FLAGS
    "--check-pkg-deps --unused-pkg-deps")
  (define-var TEST_FLAGS
    "--heartbeat --no-run-if-absent --submodule test --table")

  ;; --- Main ---
  (define-rule all  (install) (setup) (test))
  (define-rule compile
    (execute (RACO) "make" (COMPILE_FLAGS) (ENTRYPOINT))
    )
  (define-rule run
    (execute (RACKET) (RUN_FLAGS) (ENTRYPOINT))
    )
  (define-rule install
    (execute (RACO) "pkg install" (INSTALL_FLAGS) "__name" (PACKAGE_NAME))
    )
  ;; --- Doumentation ---
  (define-rule docs-dir
    (execute (MKDIR) (PACKAGE_DOC_DIR))
    )
  (define-rule docs-html  (docs-dir)
    (execute (SCRBL) "-_html" (SCRBL_FLAGS) (PACKAGE_SCRBL))
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
  ;; --- Distribution ---
  (define-rule exe  (compile)
    (execute (MKDIR) "./bin")
    (execute (RACO) "exe" (EXE_FLAGS) (ENTRYPOINT))
    )
  (define-rule pkg  (clean)
    (execute (RACO) "pkg create --source" (PWD))
    )
  ;; --- Removal ---
  (define-rule distclean
    (system "if [ -d $(PACKAGE-BIN-DIR) ] ; then rm -r $(PACKAGE-BIN-DIR) ; fi")
    (system "if [ -f $(PACKAGE-ZIP) ] ; then rm $(PACKAGE-ZIP)* ; fi")
    )
  (define-rule clean  (distclean)
    (system "find . -depth -type d -name 'compiled' -exec rm -r {}")
    (system "find . -depth -type d -name 'doc'      -exec rm -r {}")
    )
  (define-rule rem
    (execute (RACO) "pkg rem" (DO_DOCS) (PACKAGE_NAME))
    )
  (define-rule purge      (rem)       (clean))
  (define-rule reinstall  (rem)       (install))
  (define-rule resetup    (reinstall) (setup))
  ;; --- Tests ---
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
  ;; --- Everything ---
  (define-rule everything-test  (clean) (compile) (install)
    (setup) (check-deps) (test) (purge))
  (define-rule everything-dist  (pkg) (exe))


  (command-line
   #:program "mike"
   #:ps
   "Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>"
   "Licensed under the GNU GPL v3 License"
   #:args targets
   (for ([target targets])
     (
      (hash-ref rules target
                (lambda () (error 'oops "No rule for target: ~a" target)))
      )
     )
   )
  )
