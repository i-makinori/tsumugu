
(in-package :cl-user)
(defpackage :tsumugu-asd
  (:use :cl :asdf))
(in-package :tsumugu-asd)

(defsystem "tsumugu"
  :version "0.1.0"
  :author "i-makinori"
  :license ""
  :depends-on ("clack"
               "lack"
               "lack-session-store-dbi"
               "caveman2"
               "envy"
               "cl-ppcre"
               "uiop"

               ;; for @route annotation
               "cl-syntax-annot"

               ;; HTML Template
               "djula"

               ;; for DB
               "datafly"
               "sxql"

               ;; password hashing
               "cl-pass"
               )
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view" "model"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "model" :depends-on ("db"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "tsumugu-test"))))
