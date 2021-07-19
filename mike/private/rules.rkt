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
 (only-in racket/string string-join)
 (only-in racket/system system)
 (only-in racket/contract
          -> ->*
          define/contract
          listof
          or/c
          )
 (only-in racket/file
          delete-directory/files
          find-files
          make-directory*
          )
 "helpers/compile.rkt"
 "helpers/index.rkt"
 "variables.rkt"
 )

(provide
 (all-defined-out)
 (all-from-out "variables.rkt")
 )


(define/contract (recursively-delete dirname start-path)
  (-> string? path-string? void)
  (for ([dir (reverse (find-files directory-exists? start-path))])
    (when (equal? (basename dir) dirname)
      (delete-directory/files dir))
    )
  )


;; Rules

(define rules (make-hash))

(define-syntax-rule (define-rule name body ...)
  (begin
    (hash-set! rules (symbol->string 'name)
               (lambda () body ...))
    (define/contract (name)
      (-> void)
      ((hash-ref rules (symbol->string 'name))))
    )
  )

(define (display-rules)
  (displayln "+ Rules:")
  (displayln (string-join (sort (hash-keys rules) string<?) "\n"))
  )


(define announcer (make-parameter "M-> "))

(define/contract (announce . strs)
  (->* () #:rest (listof string?) void)
  (displayln (string-append (announcer) (string-join strs)))
  )

(define/contract (execute #:verbose [verbose #t] . vs)
  (->* () (#:verbose boolean?) #:rest (listof string?) void)
  (let
      ([command (string-join vs)])
    (when verbose  (announce command))
    (when (not
           (system command))
      (error 'failed command)
      )
    )
  )


;; Main
(define-rule all  (install) (setup) (test))
(define-rule compile
  (announce "compiling" (PWD))
  (compile-directory (PWD))
  )
(define-rule run
  (execute (RACKET) (RACKET_RUN_FLAGS) (ENTRYPOINT) (RUN_FLAGS))
  )
(define-rule install
  (execute (RACO) "pkg install" (INSTALL_FLAGS) "--name" (PACKAGE_NAME))
  )

;; Documentation
(define-rule docs-dir
  (announce "creating" (PACKAGE_DOC_DIR))
  (make-directory* (PACKAGE_DOC_DIR))
  )
(define-rule docs-html  (docs-dir)
  (execute (SCRBL) "--htmls" (SCRBL_FLAGS) (PACKAGE_SCRBL))
  (make-index-redirect (PACKAGE_DOC_DIR) (PACKAGE_NAME))
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
(define-rule redocs  (clean-doc) (docs))

;; Distribution
(define-rule exe  (compile)
  (make-directory* "./bin")
  (execute (RACO) "exe" (EXE_FLAGS) (ENTRYPOINT))
  )
(define-rule pkg  (clean)
  (execute (RACO) "pkg create --source" (PWD))
  )
(define-rule git-archive
  (execute (GIT) "archive --output" (PACKAGE_TAR) "--format=tar HEAD" )
  )

;; Removal
(define-rule distclean
  (announce "removing" (PACKAGE_BIN_DIR) "and" (PACKAGE_TAR) "/" (PACKAGE_ZIP))
  (when (directory-exists? (PACKAGE_BIN_DIR))
    (delete-directory/files (PACKAGE_BIN_DIR)))
  (when (file-exists? (PACKAGE_TAR))
    (delete-file (PACKAGE_TAR)))
  (when (file-exists? (PACKAGE_ZIP))
    (delete-file (PACKAGE_ZIP)))
  )
(define-rule clean-compiled
  (announce "removing compiled artifacts")
  (recursively-delete "compiled" (PWD))
  )
(define-rule clean-doc
  (announce "removing built documentation")
  (recursively-delete "doc" (PWD))
  )
(define-rule clean  (distclean)
  (clean-compiled) (clean-doc))
(define-rule remove
  (execute (RACO) "pkg remove" (DO_DOCS) (PACKAGE_NAME))
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
  (execute (RACO) "test" (TEST_FLAGS) (PWD))
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
