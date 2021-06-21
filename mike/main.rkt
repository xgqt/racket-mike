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
 racket/file
 racket/list
 racket/string
 racket/system
 syntax/parse/define
 )


;; Variables

;; Variables are procedures so that they can refer to other variables
;; when called, not when defined

(define Vs (make-hash))

(define-syntax-rule (define-V name body)
  (begin
    (define (name) (or (getenv (symbol->string 'name))
                      body))
    (hash-set! Vs (symbol->string 'name) name)
    )
  )

;; (define-syntax-rule (V name)
;;   (hash-ref Vs (symbol->string 'name))
;;   )

(define-syntax V
  (syntax-rules ()
    [(_ name)
     ((hash-ref Vs (symbol->string 'name)))
     ]
    [(_ name val)
     (hash-set! Vs (symbol->string 'name) (lambda () val))
     ]
    )
  )

(define (display-Vs)
  (displayln "+ Variables:")
  (displayln (string-join (sort (hash-keys Vs) string<?) "\n"))
  )


;; Rules

(define Rs (make-hash))

(define-syntax-parse-rule (define-R name:id body ...)
  (begin
    (define (name) body ...)
    (hash-set! Rs (symbol->string 'name) name)
    )
  )

(define (display-Rs)
  (displayln "+ Rules:")
  (displayln (string-join (sort (hash-keys Rs) string<?) "\n"))
  )


(define (execute #:verbose [verbose #t] . vs)
  (let
      ([command (string-join vs)])
    (when verbose
      (displayln (string-append "M-> " command)))
    (system command)
    )
  )

(define (basename path)
  (path->string (last (explode-path path)))
  )

(define (recursively-delete dirname start-path)
  (for
      ([dir (reverse (find-files directory-exists? start-path))])
    (when (equal? (basename dir) dirname)
      (delete-directory/files dir))
    )
  )


(module+ main
  ;; --- SYSTEM ---
  (define-V PWD
    (current-directory))
  (define-V LN
    "ln -fs")
  (define-V RACKET
    "racket")
  (define-V RACO
    "raco")
  (define-V SCRBL
    (string-append (V RACO) "scribble"))
  ;; --- PACKAGE ---
  (define-V PACKAGE_NAME
    (basename (V PWD)))
  (define-V PACKAGE_EXE
    (V PACKAGE_NAME))
  (define-V PACKAGE_BIN_DIR
    "./bin")
  (define-V PACKAGE_DOC_DIR
    "./doc")
  (define-V PACKAGE_SCRBL
    (string-append (V PACKAGE_NAME) "/scribblings" (V PACKAGE_NAME) ".scrbl"))
  (define-V PACKAGE_BIN
    (string-append (V PACKAGE_BIN_DIR) "/" (V PACKAGE_EXE)))
  (define-V PACKAGE_ZIP
    (string-append (V PACKAGE_NAME) ".zip"))
  ;; --- ARGUMENTS ---
  (define-V ENTRYPOINT
    (string-append (V PACKAGE_NAME) "/main.rkt"))
  (define-V COMPILE_FLAGS
    "-v")
  (define-V RUN_FLAGS
    "")
  (define-V SCRBL_FLAGS
    (string-append "--dest " (V PACKAGE_DOC_DIR) " ++main-xref-in"))
  (define-V EXE_FLAGS
    (string-append "--orig-exe -v -o " (V PACKAGE_BIN)))
  (define-V DO_DOCS
    "--no-docs")
  (define-V INSTALL_FLAGS
    (string-append "--auto " (V DO_DOCS)))
  (define-V DEPS_FLAGS
    "--check-pkg-deps --unused-pkg-deps")
  (define-V TEST_FLAGS
    "--heartbeat --no-run-if-absent --submodule test --table")

  ;; --- Main ---
  (define-R all  (install) (setup) (test))
  (define-R compile
    (execute (V RACO) "make" (V COMPILE_FLAGS) (V ENTRYPOINT))
    )
  (define-R run
    (execute (V RACKET) (V RUN_FLAGS) (V ENTRYPOINT))
    )
  (define-R install
    (execute (V RACO) "pkg install" (V INSTALL_FLAGS) "--name" (V PACKAGE_NAME))
    )
  ;; --- Doumentation ---
  (define-R docs-dir
    (make-directory* (V PACKAGE_DOC_DIR))
    )
  (define-R docs-html  (docs-dir)
    (execute (V SCRBL) "--html" (V SCRBL_FLAGS) (V PACKAGE_SCRBL))
    (execute (V LN)
             (string-append "../" (V PACKAGE_DOC_DIR) "/" (V PACKAGE_NAME) ".html")
             (string-append (V PACKAGE_DOC_DIR) "/" "index.html"))
    )
  (define-R docs-latex  (docs-dir)
    (execute (V SCRBL) "--latex" (V SCRBL_FLAGS) (V PACKAGE_SCRBL))
    )
  (define-R docs-markdown  (docs-dir)
    (execute (V SCRBL) "--markdown" (V SCRBL_FLAGS) (V PACKAGE_SCRBL))
    )
  (define-R docs-text  (docs-dir)
    (execute (V SCRBL) "--text" (V SCRBL_FLAGS) (V PACKAGE_SCRBL))
    )
  (define-R docs  (docs-html) (docs-latex) (docs-markdown) (docs-text))
  ;; --- Distribution ---
  (define-R exe  (compile)
    (make-directory* "./bin")
    (execute (V RACO) "exe" (V EXE_FLAGS) (V ENTRYPOINT))
    )
  (define-R pkg  (clean)
    (execute (V RACO) "pkg create --source" (V PWD))
    )
  ;; --- Removal ---
  (define-R distclean
    (when (directory-exists? (V PACKAGE_BIN_DIR))
      (delete-directory/files (V PACKAGE_BIN_DIR)))
    (when (file-exists? (V PACKAGE_ZIP))
      (delete-file (V PACKAGE_ZIP)))
    )
  (define-R clean  (distclean)
    (recursively-delete "compiled" (V PWD))
    (recursively-delete "doc" (V PWD))
    )
  (define-R remove
    (execute (V RACO) "pkg rem" (V DO_DOCS) (V PACKAGE_NAME))
    )
  (define-R purge      (remove)    (clean))
  (define-R reinstall  (remove)    (install))
  (define-R resetup    (reinstall) (setup))
  ;; --- Tests ---
  (define-R setup
    (execute (V RACO) "setup --tidy --avoid-main" (V DEPS_FLAGS) "--pkgs" (V PACKAGE_NAME))
    )
  (define-R check-deps
    (execute (V RACO) "setup" (V DO_DOCS) (V DEPS_FLAGS) (V PACKAGE_NAME))
    )
  (define-R test-local
    (execute (V RACO) "test" (V TEST_FLAGS) (string-append "./" (V PACKAGE_NAME)))
    )
  (define-R test
    (execute (V RACO) "test" (V TEST_FLAGS) "--package" (V PACKAGE_NAME))
    )
  ;; --- Everything ---
  (define-R everything-test  (clean) (compile) (install)
    (setup) (check-deps) (test) (purge))
  (define-R everything-dist  (pkg) (exe))


  (command-line
   #:program "mike"
   #:ps
   "Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>"
   "Licensed under the GNU GPL v3 License"
   #:multi
   [("-R" "--rules")     "Display the defined rules"     (display-Rs)]
   [("-V" "--variables") "Display the defined variables" (display-Vs)]
   #:args targets
   (for ([target targets])
     (
      (hash-ref Rs target
                (lambda () (error 'oops "No rule for target: ~a" target)))
      )
     )
   )
  )
