(in-package :cl-user)
(defpackage tsumugu.model
  (:use :cl :sxql)
  (:import-from :tsumugu.db
                :db
                :with-connection
                :with-transcation
                :write-contents-vector--to--db-directory
                :read-contents-vector--from--db-directory
                )
  (:import-from :datafly
                :execute
                :retrieve-all
                :retrieve-one)
  (:export :list-articles
           :write-file-to-uploader
           :read-file-from-uploader))
(in-package :tsumugu.model)


;; structure of DB

(defstruct user)

(defun user-hash->user-struct (user-hash)
  "(user-hash::list||hash) -> Maybe (user::struct)"
  user-hash)


(defstruct article )

(defun user-hash->user-struct (user-hash) ;; future name error
  "(article-hash::list||hash) -> Maybe (article::struct)"
  user-hash)



;;;; user


(defun add-user (user-name email password)
  (with-connection (db)
    (execute (insert-into :craftsmans
               (set= :name user-name
                     :email email
                     :password (cl-pass:hash password))))))


;;;; article

(defparameter *num-show-list-articles* 10)
(defun list-articles ()
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :article)
       (limit *num-show-list-articles*)
       ))))


;; (apply #'datafly:connect-toplevel (connection-settings :maindb))
#|
(defun articles* ()
  (datafly:retrieve-one
   (sxql:select :* (sxql:from :articles))))
|#



;;;; file uploader


(defun write-file-to-uploader (file_name-params file_data-params)
  (let ((db-safe-file-name (unsafe-filename->safe-filename
                            (car file_name-params)))
        ;; (procedure for-contents-type)
        (db-safe-vector (unsafe-contents-text->safe-contents-text
                         (slot-value (car file_data-params) 'flexi-streams::vector))))
    (write-contents-vector--to--db-directory
     db-safe-file-name db-safe-vector)))


(let ((content-type<-file-type--list
       '(("image/png" "png")
         ("image/jpeg" "jpeg" "jpg")
         ("image/gif" "gif")
         ("plain/text" "text" "txt")))
      (not-in-list "application/octet-stream"))
  (defun file-type->content-type (file-type)
    (let ((in-list
           (reduce #'(lambda (content-type candi)
                (cond (content-type content-type)
                      ((find file-type (cdr candi) :test #'string=)
                       (car candi))
                      (t content-type)))
                   content-type<-file-type--list :initial-value nil)))
      (if in-list in-list not-in-list))))

(print (file-type->content-type "png"))

(defun read-file-from-uploader (filename)
  (multiple-value-bind (vector type len)
      (read-contents-vector--from--db-directory filename)
    (unless vector nil)
    (when vector
        (let ((content-type (file-type->content-type type)))
          (list :vector vector :type content-type :length len
                )))))




;;;; injection
(defun unsafe-contents-text->safe-contents-text (unsafe-contents-text)
  unsafe-contents-text)

(defun safe-contents-text->unsafe-contents-text (safe-contents-text)
  safe-contents-text)


(defun unsafe-filename->safe-filename (filename)
  filename)

(defun safe-filename->unsafe-filename (safe-filename)
  safe-filename)
