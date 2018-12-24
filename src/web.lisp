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
;; render-stateed-page

(defun render-state (template-path &optional env)
  (let ((observer (num_enum-to-observer-proclaimed (gethash :observer-num_enuem *session*))))
    (render template-path `(:observer ,observer ,@env))))


(defun render-blob-page (title contents)
  (render-state
   #P"blob_template.html"
   (list :page-title (format nil "~A " title)
         :page-contents (format nil "~A" contents))))


;;
;; Routing rules

(defroute "/" ()
  (let ((article-heads (article-head-list (list-articles))))
    (render-state #P"index.html" (list :article-heads article-heads))))


;;;; articles

(defroute "/articles/:cosmic-link" (&key |cosmic-link|)
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
   listed-articles))

;; for users

(defroute "/observer" ()
  ;; (or (show updates for/by user) (auth user)
  (render-state #P"user.html" (list :user-session "")
  ))


(defroute ("/observer/auth" :method :GET) ()
  ;; login/logout/making/delete user
  (render-state #P"auth_form.html")
  )

(defroute ("/observer/auth" :method :POST) (&key |observer_cosmic| |observer_password|)
  (let ((maybe-cosmic (car |observer_cosmic|))
        (maybe-password (car |observer_password|)))
    (format nil "~A, ~A => ~A"
            maybe-cosmic maybe-password 
            (if-trury-the-observer--then--let-to-hash-session-num_enuem
             *session* maybe-cosmic maybe-password))))
            ;; (is-trury-the-observer maybe-cosmic maybe-password))))

(defroute ("/observer/auth" :method :POST) (&key |observer_cosmic| |observer_password|)
  (let ((maybe-observer
          (is-trury-the-observer (car |observer_cosmic|) (car |observer_password|))))
    (cond (maybe-observer
           ;; (let-loged-in-cookie *session* (getf maybe-observer :num_enuem))
           (setf (gethash :observer-num_enuem *session*) (getf maybe-observer :num-enuem))
           (render-blob-page "∃∧∃⇒∃"
                             (format nil "observer had uniquely matched : ~A"
                                     (getf maybe-observer :name))))
          (t
           (render-blob-page "∃∧∃⇒!∃" (format nil "let re-auth"))
        ))))



(defroute "/observer/edit-article" ()
  ;; (format nil "environment have been forgot how to listen articles.")
  (render-state #P"editor.html" (list))
  )



(defroute "/observer/observer-config" ()
  ;; user configuration
  (format nil "what is user? what is config? what is observer?")
  )


;; user/upmaterial

(defroute ("/observer/upmaterial" :method :GET) ()
  (render-state #P"upmaterial_form.html" (list)))


(defroute ("/observer/upmaterial" :method :POST) (&key |file_name| |file_data|)
  (let ((file-name (car |file_name|))
        (file-data |file_data|))
    (case (file_name-condition file-name)
      (:unsafe-file_name (render-blob-page "unsafe-file_name"
                                           (format nil "unsafe file_name : ~A~%" file-name)))
      (:aleady-exists (render-blob-page "aleady-exists"
                                        (format nil "already exists : ~A~%" file-name)))
      (t 
       (if (write-file-to-uploader file-name file-data)
           (let ((material-path (format nil "/material/~A" file-name)))
             (render-state #P"upmaterial_success.html" (list :material-path material-path)))
           (format nil "failed to write file"))))))


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
  (render-state #P"life.html" (list)))


;;;; html_test

(defroute "/test/response-request*" ()
  (let ((text (format nil "~A~%" *request*)))
    (setf (getf (response-headers *response*) :content-type) "text/plain")
    (setf (getf (response-headers *response*) :content-length) (length text))
    (setf (response-body *response*) text)))

(defroute "/test/html" ()
  (render-state #P"html_test.html" (list)))


;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (render-state #P"_errors/404.html" 
          (list :uri (request-uri *request*))))
