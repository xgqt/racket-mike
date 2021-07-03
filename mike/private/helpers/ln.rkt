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
 (only-in racket/file delete-directory/files)
 (only-in racket/contract/base contract-out ->)
 )

(provide
 (contract-out [ln       (-> path-string? path-string? path-string? void)])
 (contract-out [ln-force (-> path-string? path-string? path-string? void)])
 )

;; Wrapper for `make-file-or-directory-link'
;; Not to be confused with natural logarithm ;P


(define (ln in-dir origin-from link-to)
  (parameterize ([current-directory in-dir])
    (make-file-or-directory-link origin-from link-to)
    )
  )

(define (ln-force in-dir origin-from link-to)
  (let  ([link-wanted (build-path in-dir link-to)])
    (when (or (directory-exists? link-wanted) (file-exists? link-wanted))
      (delete-directory/files link-wanted)
      )
    )
  (ln in-dir origin-from link-to)
  )
