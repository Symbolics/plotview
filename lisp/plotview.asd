;;;; plotview.asd

;;; make sure we load hunchentoot at the start with
;;; :hunchentoot-no-ssl on *features*, so that we don't run into
;;; problems loading cl+ssl
(eval-when (:compile-toplevel :load-toplevel :execute)
  (pushnew :HUNCHENTOOT-NO-SSL *features*))


(asdf:defsystem #:plotview
  :description "An HTML plotting UI for sbcl"
  :author "mikel evins <mikel@evins.net>"
  :license  "Apache 2.0"
  :version "0.0.1"
  :serial t
  :depends-on (:hunchentoot :trivial-ws :parenscript :yason :cl-who :plot/vega)
  :components ((:file "package")
               (:file "parameters")
               (:file "http-server")
               (:file "routes")
               (:file "ui")
               (:file "drawing")))

#+nil (asdf:load-system :plotview)
#+nil (plotview::start-server plotview::*http-server-port*)
#+nil (plotview::stop-server)
#+nil (uiop:run-program
       (namestring (asdf:system-relative-pathname :plotview "../webview/win64/plotview.exe")))
#+nil (uiop:run-program
       (namestring (asdf:system-relative-pathname :plotview "../webview/macos-intel/plotview")))
#+nil (uiop:run-program
       (namestring (asdf:system-relative-pathname :plotview "../webview/macos-apple/plotview")))

#+nil (plotview::draw-stroke)
#+nil (plotview::clear-canvas)
#+nil (plotview::embed-vega (vega:defplot grouped-bar-chart
			      '(:mark :bar
				:data (:category #(A A A B B B C C C)
				       :group    #(x y z x y z x y z)
				       :value    #(0.1 0.6 0.9 0.7 0.2 1.1 0.6 0.1 0.2))
				:encoding (:x (:field :category)
					   :y (:field :value :type :quantitative)
					   :x-offset (:field :group)
					   :color    (:field :group)))))

