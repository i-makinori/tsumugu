(in-package :cl-user)
(defpackage tsumugu.model
  (:use :cl :sxql)
  (:import-from :tsumugu.db
                :db
                :with-connection
                :with-transcation)
  (:import-from :datafly
                :execute
                :retrieve-all
                :retrieve-one)
  (:export :list-articles))
(in-package :tsumugu.model)


(defun add-user (user-name email password)
  (with-connection (db)
    (execute (insert-into :craftsmans
               (set= :name user-name
                     :email email
                     :password (cl-pass:hash password))))))

(defun list-articles ()
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :article)))))




