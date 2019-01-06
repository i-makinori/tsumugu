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
           :maybe-add-article-row-to-db
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
       (from :observer)))))


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



(defun safe-id-name-p (id-name)
  ;; _-0-9a-zA-Z
  (let ((id-name-chars (concatenate 'list id-name))
        (able-chars (concatenate 'list "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")))
    (every #'(lambda (char) (find char able-chars)) 
           id-name-chars)))

(defun current-article-num_enuem-of-db ()
  ;; low abstraction code
  (let ((num_enuem-list
          (with-connection (db)
            (retrieve-all
             (select :num_enuem
               (from :article))))))
    (apply #'max (mapcar #'cadr
                         (remove-if-not #'(lambda (cell)
                                            (integerp (cadr cell)))
                                        num_enuem-list)))))

(defun maybe-add-article-row-to-db (observer-num_enuem cosmic_link title tags content)
  (cond ((not (num_enum-to-observer-proclaimed observer-num_enuem))
         (values nil :not-observer))
        ((not (safe-id-name-p cosmic_link))
         (values nil :cosmic_link-is-not-safe))
        ((cosmic_link-article cosmic_link)
         (values nil :cosmic_link-aleady-exists))
        (t
         (let ((next-num_enuem (1+ (current-article-num_enuem-of-db)))
               (current-time (get-universal-time)))
           (handler-case
               (progn 
                 (with-connection (db)
                   (execute
                    (insert-into :article
                      (set= :num_enuem next-num_enuem
                            :cosmic_link cosmic_link
                            :observer_id observer-num_enuem
                            :authorities ""
                            :updated_at current-time
                            :title title
                            :tags tags
                            :contents content))))
                 (values t :sucessed))
             (t (c)
               (values nil :server-error c))))
           )))


#|
(defun universal-time-to-time-text (universal-time)
  (multiple-value-bind (second minute hour date mouth year)
      (decode-universal-time universal-time)
    (format nil "~A/~A/~A ~A:~A:~A" year mouth date hour minute second)
  ))

(print
 (universal-time-to-time-text 10000))
|#

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
