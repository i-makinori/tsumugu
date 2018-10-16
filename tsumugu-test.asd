(in-package :cl-user)
(defpackage :tsumugu-test-asd
  (:use :asdf))
(in-package :tsumugu-test-asd)


(defsystem "tsumugu-test"
  :defsystem-depends-on ("prove-asdf")
  :author "i-makinori"
  :license ""
  :depends-on ("tsumugu"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "tsumugu"))))
  :description "Test system for tsumugu"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
