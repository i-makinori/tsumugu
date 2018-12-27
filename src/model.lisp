(in-package :cl-user)
(defpackage tsumugu.model
  (:use :cl :sxql)
  (:import-from :tsumugu.db
                :db
                :with-connection
                :with-transcation
                :write-contents-vector--to--db-directory
                :read-contents-vector--from--db-directory
                :db-contents
                )
  (:import-from :datafly
                :execute
                :retrieve-all
                :retrieve-one)
  (:export :num_enum-to-observer-proclaimed
           :is-trury-the-observer
           :let-loged-in-cookie
           :if-trury-the-observer--then--let-to-hash-session-num_enuem
           :list-articles
           :cosmic_link-article
           :write-file-to-uploader
           :read-file-from-uploader
           :file_name-condition))
(in-package :tsumugu.model)


;; structure of DB
#|
(defstruct observer
  (num_enuem "")
  (cosmic_link "") 
  (name "")
  (password "") 
  (email ""))

(defun is-trury-the-observer (maybe-cosmic-link maybe-password)
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :observer))))
  )

(print
   (with-connection (db)
    (retrieve-all
     (select :*
       (from :observer)
       (where (:= :cosmic-link "the-atmos"))
       ))))


(defun cookie-logd-in (session observer-num_enuem)
  (setf (gethash :observer-num_enuem session) observer-num_enuem)
  )
|#

(defstruct observer
  (num_enuem "")
  (cosmic_link "") 
  (name "")
  (password "") 
  (email ""))

(defun num_enum-to-observer-proclaimed (num_enuem)
  (if num_enuem
      (with-connection (db)
        (retrieve-one
         (select (:num_enuem :cosmic_link :name :email)
           (from :observer)
           (where (:= :num_enuem num_enuem)))))))

(defun is-trury-the-observer (maybe-cosmic-link maybe-password)
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :observer)
       (where (:and
               (:= :password maybe-password)
               (:= :cosmic_link maybe-cosmic-link)))))))

;; (print (getf (is-trury-the-observer "neko_neko_chaos" "dolphins") :num-enuem))
;; (print (is-trury-the-observer "the-atmos" "atoms_password"))
;; select * from observer where password = "dolphins" and cosmic_link = "neko_neko_chaos";

(defun let-loged-in-cookie (session observer-num_enuem)
  (setf (gethash :observer-num_enuem session) observer-num_enuem)
  )

(defun if-trury-the-observer--then--let-to-hash-session-num_enuem
    (session maybe-cosmic-link maybe-password)
  (let* ((observer (is-trury-the-observer maybe-cosmic-link maybe-password))
         (num_enuem (getf observer :num-enuem)))
    (if num_enuem
        (values (let-loged-in-cookie session num_enuem) num_enuem))))
        





(defstruct article )



#|
(defun user-hash->user-struct (user-hash) ;; future name error
  "(article-hash::list||hash) -> Maybe (article::struct)"
  user-hash)
|#



;;;; observer

#|
(defun add-observer (user-name email password)
  (with-connection (db)
    (execute (insert-into :craftsmans
               (set= :name name
                     :email email
                     :password (cl-pass:hash password))))))
|#



;;;; article

(defparameter *num-show-list-articles* 10)
(defun list-articles ()
  (with-connection (db)
    (retrieve-all
     (select :*
       (from :article)
       (limit *num-show-list-articles*)
       ))))

(defun cosmic_link-article (cosmic_link)
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :article)
       (where (:= :cosmic_link cosmic_link))
       ))))




;; (apply #'datafly:connect-toplevel (connection-settings :maindb))
#|
(defun articles* ()
  (datafly:retrieve-one
   (sxql:select :* (sxql:from :articles))))
|#

(defun safe-id-name-p (id-name)
  ;; _-0-9a-zA-Z
  (let ((id-name-chars (concatenate 'list id-name))
        (able-chars (concatenate 'list "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")))
    (every #'(lambda (char) (find char able-chars)) 
           id-name-chars)))

;;;; file uploader


(defun safe-file_name-p (file_name)
  ;; _-.0-9a-zA-Z
  (let ((id-name-chars (concatenate 'list file_name))
        (able-chars (concatenate 'list "_-.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")))
    (every #'(lambda (char) (find char able-chars)) 
           id-name-chars)))

(defun file_name-find-in-db (file_name)
  (find file_name (db-contents) :test #'string=))

(defun file_name-condition (file_name)
  (cond ((not (safe-file_name-p file_name)) :unsafe-file_name)
        ((file_name-find-in-db file_name) :aleady-exists)
        (t t)))


(defun write-file-to-uploader (file_name file_data-params)
  (handler-case 
      (write-contents-vector--to--db-directory
       (unsafe-filename->safe-filename file_name)
       (unsafe-contents-text->safe-contents-text
        (slot-value (car file_data-params) 'flexi-streams::vector)))
    (t (c)
      (format t "error when wrote to db: ~A~%" c)
      nil)))

(defun read-file-from-uploader (file_name)
  file_name
  "<on app.lisp (route ...... (ppcre:scan ... ) ...... ) >"
  nil)



;;;; injection
(defun unsafe-contents-text->safe-contents-text (unsafe-contents-text)
  unsafe-contents-text)

(defun safe-contents-text->unsafe-contents-text (safe-contents-text)
  safe-contents-text)


(defun unsafe-filename->safe-filename (filename)
  filename)

(defun safe-filename->unsafe-filename (safe-filename)
  safe-filename)
