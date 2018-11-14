(in-package :cl-user)
(defpackage language-popularity.model
  (:use :cl
        :cl-json
        :drakma
        :vecto
        :md5
        :split-sequence)
  (:import-from :language-popularity.config
                :config)
  (:export :get-language-sub-stats
           :pie-chart))

(in-package :language-popularity.model)


