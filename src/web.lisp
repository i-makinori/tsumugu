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

(defroute "/user/auth" ()
  ;; login/logout/making/delete user
  (format nil "dolphins")
  )

(defroute "/user/edit-article" ()
  ;; (format nil "environment have been forgot how to listen articles.")
  (render #P"editor.html" (list))
  )



(defroute "/user/user-config" ()
  ;; user configuration
  (format nil "what is user? what is config? what is observer?")
  )


;; user/upmaterial

(defroute ("/user/upmaterial" :method :GET) ()
  (render #P"upmaterial_form.html" (list)))


(defroute ("/user/upmaterial" :method :POST) (&key |file_name| |file_data|)
  (let ((file-name (car |file_name|))
        (file-data |file_data|))
    (case (file_name-condition file-name)
      (:unsafe-file_name (format nil "unsafe file_name : ~A~%" file-name))
      (:aleady-exists (format nil "aleady exists in material uploader : ~A~%" file-name))
      (t 
       (if (write-file-to-uploader file-name file-data)
           (let ((material-path (format nil "/material/~A" file-name)))
             (render #P"upmaterial_success.html" (list :material-path material-path)))
           (format nil "failed to write file")
           )))))
  

;;;; search

(defroute "/resonance" (&key |q|)
  ;; search
  (let ((undefined "<pre>
resonance :: Environment -> Request -> Chaos -> OrFail Response
resonance env r@(GET:_:_) δc = undefined
</pre>"))
    (format nil "-- chaos resonance when quotes = ~A is below<br/> ~A" |q| undefined)))


;;;; game_of_life

(defroute "/life" ()
  (render #P"life.html" (list)))


;;;; html_test

(defroute "/test/response-request*" ()
  (let ((text (format nil "~A~%" *request*)))
    (setf (getf (response-headers *response*) :content-type) "text/plain")
    (setf (getf (response-headers *response*) :content-length) (length text))
    (setf (response-body *response*) text)))

(defroute "/test/html" ()
  (render #P"html_test.html" (list)))


;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (render #P"_errors/404.html" 
          (list :uri (request-uri *request*))))
