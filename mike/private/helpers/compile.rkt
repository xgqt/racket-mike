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
 (only-in compiler/compiler compile-directory-zos)
 (only-in setup/getinfo get-info/full)
 (only-in racket/contract/base contract-out ->))

(provide (contract-out [compile-directory (-> path-string? void)]))


(define (compile-directory path)
  (when (not (file-exists? (build-path path "info.rkt")))
    (error 'failed "No info.rkt file in: ~a" path))
  (compile-directory-zos (path->complete-path path)
                         (get-info/full path)
                         #:skip-doc-sources? #t
                         #:verbose #f))
