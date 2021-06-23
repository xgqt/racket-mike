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
 racket/list
 racket/string
 )

(provide
 (all-defined-out)
 )


(define (basename path)
  (path->string (last (explode-path path)))
  )


;; Variables

;; Variables should refer to other variables when called, not when defined

(define variables (make-hash))

(define-syntax-rule (define-variable name body)
  (begin
    (hash-set! variables (symbol->string 'name)
               (lambda () (or (getenv (symbol->string 'name)) body)))
    (define (name) ((hash-ref variables (symbol->string 'name))))
    )
  )

;; ZZZ=aaa -> key = ZZZ ; val = aaa
(define (set-variable str)
  (let* (
         [s   (string-split str "=")]
         [key (first s)]
         [val (lambda () (last s))]
         )
    (hash-set! variables key val)
    )
  )

(define (display-variables)
  (displayln "+ Variables:")
  (let
      ([vlst
        (hash-map variables
                  (lambda (key val) (string-append key "\t=\t" (val))))
        ])
    (displayln (string-join (sort vlst string<?) "\n"))
    )
  )


;; SYSTEM
(define-variable PWD
  (path->string (current-directory)))
(define-variable LN
  "ln -fs")
(define-variable RACKET
  "racket")
(define-variable RACO
  "raco")
(define-variable SCRBL
  (string-append (RACO) " scribble"))

;; PACKAGE
(define-variable PACKAGE_NAME
  (basename (PWD)))
(define-variable PACKAGE_EXE
  (PACKAGE_NAME))
(define-variable PACKAGE_BIN_DIR
  "./bin")
(define-variable PACKAGE_DOC_DIR
  "./doc")
(define-variable PACKAGE_SCRBL
  (string-append (PACKAGE_NAME) "/scribblings" "/" (PACKAGE_NAME) ".scrbl"))
(define-variable PACKAGE_BIN
  (string-append (PACKAGE_BIN_DIR) "/" (PACKAGE_EXE)))
(define-variable PACKAGE_ZIP
  (string-append (PACKAGE_NAME) ".zip"))

;; ARGUMENTS
(define-variable ENTRYPOINT
  (string-append (PACKAGE_NAME) "/main.rkt"))
(define-variable COMPILE_FLAGS
  "-v")
(define-variable RUN_FLAGS
  "")
(define-variable SCRBL_FLAGS
  (string-append "--dest " (PACKAGE_DOC_DIR) " ++main-xref-in"))
(define-variable EXE_FLAGS
  (string-append "--orig-exe -v -o " (PACKAGE_BIN)))
(define-variable DO_DOCS
  "--no-docs")
(define-variable INSTALL_FLAGS
  (string-append "--auto " (DO_DOCS)))
(define-variable DEPS_FLAGS
  "--check-pkg-deps --unused-pkg-deps")
(define-variable TEST_FLAGS
  "--heartbeat --no-run-if-absent --submodule test --table")
