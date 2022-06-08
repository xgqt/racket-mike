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
 racket/contract
 (only-in racket/list first last)
 (only-in racket/string string-join string-split string-trim))

(provide (all-defined-out))


(define/contract (basename path)
  (-> path-string? string?)
  (path->string (last (explode-path path))))

(define/contract (file-is? path)
  (-> path-string? (or/c #f path-string?))
  (if (or (directory-exists? path) (file-exists? path)) path #f))


;; Variables

;; Variables should refer to other variables when called, not when defined

(define variables
  (make-hash))

(define-syntax-rule (define-variable name body)
  (begin
    (hash-set! variables
               (symbol->string 'name)
               (lambda () (or (getenv (symbol->string 'name)) body)))
    (define/contract (name)
      (-> string?)
      ((hash-ref variables (symbol->string 'name))))))

;; ZZZ=aaa -> key = ZZZ ; val = aaa

(define/contract (set-variable str)
  (-> string? void)
  (let* ([s (string-split str "=")] [key (first s)] [val (lambda () (last s))])
    (hash-set! variables key val)))

;; used to append flags to RUN_FLAGS
;; (append-variable "RUN_FLAGS" "-j 2") -> RUN_FLAGS = -j 2
;; (append-variable "RUN_FLAGS" "-l 1") -> RUN_FLAGS = -j 2 -l 1

(define/contract (append-variable key str)
  (-> string? string? void)
  (let ([s (string-append ((hash-ref variables key)) " " str)])
    (hash-set! variables key (lambda () s))))

(define (display-variables)
  (displayln "+ Variables:")
  (let ([vlst (hash-map variables
                        (lambda (key val) (string-append key "\t=\t" (val))))])
    (displayln (string-join (sort vlst string<?) "\n"))))


;; SYSTEM

(define-variable GIT
  "git")

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
  (cond
    [(file-is? (string-trim (basename (PWD)) "racket-"))]
    [(file-is? (string-trim (basename (PWD)) "scheme-"))]
    [else (basename (PWD))]))

(define-variable PACKAGE_EXE
  (PACKAGE_NAME))

(define-variable PACKAGE_BIN_DIR
  "./bin")

(define-variable PACKAGE_DOC_DIR
  "./doc")

(define-variable PACKAGE_BIN
  (string-append (PACKAGE_BIN_DIR) "/" (PACKAGE_EXE)))

(define-variable PACKAGE_TAR
  (string-append (PACKAGE_NAME) ".tar"))

(define-variable PACKAGE_ZIP
  (string-append (PACKAGE_NAME) ".zip"))

;; COLLECTION - main collection from which the ENTRYPOINT is used
;; this is a directory in PROJECT_ROOT/COLLECTION if this directory
;; does not exist and instead PROJECT_ROOT is the collection,
;; set it to COLLECTION=. on the command-line

(define-variable COLLECTION
  (cond
    [(file-is? (PACKAGE_NAME))]
    [else "."]))

(define-variable ENTRYPOINT
  (string-append (COLLECTION) "/main.rkt"))

(define-variable PACKAGE_SCRBL
  (cond
    [(file-is?
      (string-append (PACKAGE_NAME) "-doc" "/" (PACKAGE_NAME) ".scrbl"))]
    [(file-is? (string-append (PACKAGE_NAME) "-doc" "/main.scrbl"))]
    [(file-is? (string-append (PACKAGE_NAME)
                              "-doc"
                              "/scribblings/"
                              (PACKAGE_NAME)
                              ".scrbl"))]
    [(file-is? (string-append (PACKAGE_NAME) "-doc" "/scribblings/main.scrbl"))]
    [(file-is?
      (string-append (COLLECTION) "/scribblings" "/" (PACKAGE_NAME) ".scrbl"))]
    [(file-is? (string-append (COLLECTION) "/scribblings" "/main.scrbl"))]
    [else
     (string-append (COLLECTION) "/" (PACKAGE_NAME) ".scrbl")]))


;; ARGUMENTS

(define-variable RACKET_RUN_FLAGS
  "")

(define-variable RUN_FLAGS
  "")

(define-variable SCRBL_FLAGS
  (string-append "--dest " (PACKAGE_DOC_DIR) " --quiet ++main-xref-in"))

(define-variable EXE_FLAGS
  (string-append "--orig-exe -v -o " (PACKAGE_BIN)))

(define-variable DO_DOCS
  "--no-docs")

(define-variable INSTALL_FLAGS
  (string-append "--auto --skip-installed " (DO_DOCS)))

(define-variable DEPS_FLAGS
  "--check-pkg-deps --unused-pkg-deps")

(define-variable TEST_FLAGS
  "--heartbeat --no-run-if-absent --submodule test --table")
