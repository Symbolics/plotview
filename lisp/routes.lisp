
(in-package :plotview)

(hunchentoot:define-easy-handler (landing :uri "/") ()
  (setf (hunchentoot:content-type*) "text/html")
  (landing-page))


;;;
;;; HTTP data & spec retrieval
;;;

;;; TODO error handling

(hunchentoot:define-easy-handler (data :uri "/data") (pkg sym fmt)
  ;; set defaults
  (alexandria+:unlessf pkg "LS-USER")
  (alexandria+:unlessf fmt "csv")

  ;; We should probably just enforce the use of the LS-USER package
  ;; and DEFDF macros, but for now there are multiple ways to define a
  ;; data frame, so we look it up by symbol instead of searching the
  ;; DF:*DATA-FRAMES* list.
  (let* ((df-pkg (find-package (string-upcase pkg)))
	 (df     (find-symbol  (string-upcase sym) df-pkg))
	 (data   (symbol-value df)))
    (with-output-to-string (s)
		(alexandria:eswitch (fmt :test #'string=)
		  ("vega" (setf (hunchentoot:content-type*) "application/json")
			  (let ((yason:*symbol-encoder*     'vega::encode-symbol-as-metadata)
				(yason:*symbol-key-encoder* 'vega::encode-symbol-as-metadata))
			    (yason:encode data s)))
		  ("sexp" (setf (hunchentoot:content-type*) "text/s-expression") ;does a sexp content type exist?
			  (dfio:write-df df s))
		  ("csv"  (setf (hunchentoot:content-type*) "text/csv")
			  (dfio:write-csv data s :add-first-row t))
		  ("dt" (setf (hunchentoot:content-type*) "application/json")
			  (let ((yason:*symbol-encoder*     'vega::encode-symbol-as-metadata)
				(yason:*symbol-key-encoder* 'vega::encode-symbol-as-metadata))
			    (yason:with-output (s)
			      (yason:with-object ()
				;; (yason:encode-object-element "data" data))) ;if you want an object called 'data'
				(yason:encode-object-element sym data)))))))))

(hunchentoot:define-easy-handler (table :uri "/table") (pkg sym)
  (alexandria+:unlessf pkg "LS-USER")
  (setf (hunchentoot:content-type*) "text/html")
  (let* ((df-pkg (find-package (string-upcase pkg)))
	 (df     (find-symbol  (string-upcase sym) df-pkg))
	 (data   (symbol-value df)))
      (data-table sym)))

;;; Here we look only in the vega:*all-plots* hash table.  Revisit
;;; this when we have more than one plotting back end.
(hunchentoot:define-easy-handler (plot :uri "/plot") (name slot)
  (alexandria+:unlessf slot "spec")
  (let (;(p (gethash (find-symbol (string-upcase name) (find-package "VEGA")) vega::*all-plots*))) ;TODO change to exported symbol once PLOT:src;vega;pkgdcl is updated
	(p (gethash (string-upcase name) vega::*all-plots*)))
    (with-output-to-string (s)
      (alexandria:eswitch (slot :test #'string=)
	("spec" (setf (hunchentoot:content-type*) "application/json")
		(let ((yason:*symbol-encoder*     'vega::encode-symbol-as-metadata)
		      (yason:*symbol-key-encoder* 'vega::encode-symbol-as-metadata))
		  (vega:write-spec p :spec-loc s)))
	("data" (setf (hunchentoot:content-type*) "application/json")
		(let ((yason:*symbol-encoder*     'vega::encode-symbol-as-metadata)
		      (yason:*symbol-key-encoder* 'vega::encode-symbol-as-metadata))
		  (vega:write-spec p :data-loc s)))))))
