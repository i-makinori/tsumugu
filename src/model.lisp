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


;; structure of DB

(defstruct user)

(defun user-hash->user-struct (user-hash)
  "(user-hash::list||hash) -> Maybe (user::struct)")


(defstruct article )

(defun user-hash->user-struct (user-hash)
  "(article-hash::list||hash) -> Maybe (article::struct)")



;;


(defun add-user (user-name email password)
  (with-connection (db)
    (execute (insert-into :craftsmans
               (set= :name user-name
                     :email email
                     :password (cl-pass:hash password))))))


(defparameter *num-show-list-articles* 10)
(defun list-articles ()
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :article)
       (limit *num-show-list-articles*)
       ))))




