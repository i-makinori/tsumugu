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
    ;;(format nil "heads: ~A" article-heads)))

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


(defroute "/articles" ()
  (let ((articles (list-articles)))
    (format nil "articles: ~A" articles)))



(defroute "/postfile-form" ()
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
#|
(defroute "/getfile/:filename" (&key file-name)
  (let (())
    ))
|#

(defvar -hoge- nil)
(defvar -fuga- nil)

(defroute "/getfile-sample" ()
  (let ((file-vector (read-file-from-uploader "alien1.png")))
    ;; (lambda (env)
    ;; `(200 (:content-type "text/plain") ,(format nil "~A" file-vector))
    
    ;; (format nil "~A" file-vector)
    (setf (getf (response-headers *response*) :content-type) "image/png")
    (setf (response-body *response*) file-vector)
  ))

(print (gethash :user-agent (request-headers -hoge-)))
(print (getf -hoge- :uri))
(print *response*)




(print (read-file-from-uploader "aaa.png"))

;; #<FLEXI-STREAMS::VECTOR-INPUT-STREAM {10028B5893}>
;; (print (coerce (read-file-from-uploader "aaa.png")
;;               '(vector (unsigned-byte 8))))

#|
(defgeneric serve-path (app env file encoding)
  (:method ((this <clack-app-file>) env file encoding)
    (let ((content-type "image/png")
          (univ-time (or (file-write-date file)
                         (get-universal-time))))
      (when (text-file-p content-type)
        (setf content-type
              (format nil "~A;charset=~A"
                      content-type encoding)))
      (with-open-file (stream file
                              :direction :input
                              :if-does-not-exist nil)
        `(200
          (:content-type ,content-type
                         :content-length ,(file-length stream)
                         :last-modified "this is time")
          ,file)))))
|#




;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
