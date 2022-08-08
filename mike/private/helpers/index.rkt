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


#|
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta http-equiv="Refresh" content="0; url='./mike/index.html'"/>
    </head>
</html>
|#


#lang racket/base

(require xml)

(provide (all-defined-out))


(define (index-redirect-xml name)
  ;; prolog
  (document (prolog '() (document-type 'html (external-dtd "") #f) '())
            ;; element
            (xexpr->xml `(html ((lang "en"))
                               (head (meta ((http-equiv "Refresh")
                                            (content ,(string-append
                                                       "0; url='./"
                                                       name
                                                       "/index.html'")))))))
            ;; misc
            '()))

(define (make-index-redirect dir name)
  (with-output-to-file #:exists 'replace (build-path dir "index.html")
    (lambda ()
      (display-xml (index-redirect-xml name)))))
