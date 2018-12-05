(in-package :cl-user)
(defpackage tsumugu.web
  (:use :cl
        :caveman2
        :tsumugu.config
        :tsumugu.view
        :tsumugu.db
        :tsumugu.model
        :datafly
        :sxql
        :clack)
  (:export :*web*))
(in-package :tsumugu.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (let ((article-heads (article-head-list (list-articles))))
    (render #P"index.html" (list :article-heads article-heads))))


;;;; articles


(defroute "/articles/:post_code" (&key |post_code|)
  )

(defroute "/articles/" ()
  (let ((articles (list-articles)))
    (format nil "articles: ~A" articles)))


(defun article-head-list (listed-articles)
  (mapcar
   #'(lambda (article)
       (list :title (getf article :title)
             :date (getf article :updated-at)
             :author (getf article :user-id)
             :tags (getf article :tags)
             :contents-head (getf article :contents)))
   listed-articles
   ))


;; for users

(defroute "/user" ()
  ;; (or (show updates for/by user) (auth user)
  (format nil "here are no histories.")
  )

(defroute "/user/edit-article" ()
  (format nil "environment have been forgot how to listen articles.")
  )


(defroute "/user/user-config" ()
  ;; user configuration
  (format nil "what is user? what is config? what is observer?")
  )

(defroute "/user/auth" ()
  ;; login/logout/making/delete user
  (format nil "dolphins")
  )


;;;; search

(defroute "/resonance" (&key |q|)
  ;; search
  (let ((undefined "<pre>
resonance :: Environment -> Request -> Chaos -> OrFail Response
resonance env r@(GET:_:_) δc = undefined
</pre>"))
    (format nil "-- chaos resonance when quotes = ~A is below<br/> ~A" |q| undefined)))


;;;; file uploader

(defroute "/postfile/form" ()
  (let ((form-html "
<form action=\"/postfile\" method=\"POST\" enctype=\"multipart/form-data\">
  <input type=\"text\" name=\"file_name\" value=\"message here\" />
  <input type=\"file\" name=\"file_data\" />
  <input type=\"submit\" value=\"Send\" />
</form>"))
    (format nil "~A" form-html)))


(defroute ("/postfile" :method :POST) (&key |file_name| |file_data|)
  (write-file-to-uploader |file_name| |file_data|)
  (format nil "~A ~A ~%" |file_name| |file_data|))


(defroute "/getfile/:filename" (&key filename)
  (let* ((file-data (read-file-from-uploader filename)))
    (unless file-data
      (throw-code "404"))
    (when file-data
      (let ((file-vector (getf file-data :vector))
            (content-type (getf file-data :type))
            (length (getf file-data :length)))
        (setf (getf (response-headers *response*) :content-type) content-type)
        (setf (getf (response-headers *response*) :content-length) length)
        (setf (response-body *response*) file-vector)))))


;; samples

(defroute "/life" ()
  (let ((article-heads (article-head-list (list-articles))))
    (render #P"life.html" (list :article-heads article-heads))))

;;;; game_of_life

;;;; html_test

(defroute "/html_test" ()
  (let ((article-heads (article-head-list (list-articles))))
    (render #P"html_test.html" (list :article-heads article-heads))))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
