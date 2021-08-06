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


#lang racket

(require
 "rules.rkt"
 "variables.rkt"
 )


(module+ test
  (require rackunit)


  ;; Helpers

  (check-equal? (basename "/asd/fgh/jkl") "jkl")

  (when (eq? (system-type) 'unix)
    (check-not-false (execute #:verbose #f "true"))
    (check-not-false (file-is? "/"))
    )


  ;; Hashes

  (check-false (hash-empty? rules))
  (check-false (hash-empty? variables))

  (hash-for-each rules (lambda (key val) (check-true (procedure? val))))
  (hash-for-each variables (lambda (key val) (check-true (procedure? val))))

  (set-variable "ASD=asd")
  (check-true (procedure? (hash-ref variables "ASD")))
  (check-equal? ((hash-ref variables "ASD")) "asd")
  )
