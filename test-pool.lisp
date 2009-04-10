;;;; -*- Mode: Lisp -*-
;;;; $Id$
;;;; Author: Steve Knight <stknig@gmail.com>
;;;;
(in-package "CL-MYSQL-TEST")

(in-root-suite)

(defsuite* test-pool)

(deftest test-connection ()
  (let ((test-conn (make-instance 'connection :pointer (cffi:make-pointer 1) :in-use t)))
          ;; Test an in-use connection
	  (is (not (available test-conn)))
	  (is (connected test-conn))
	  ;; Now make it available
	  (setf (in-use test-conn) nil)
	  (is  (available test-conn))
	  (is (connected test-conn))
	  ;; Now 'disconnect' the connection 
	  (setf (pointer test-conn) (cffi:null-pointer))
	  (is (not (connected test-conn)))
	  (is (not (available test-conn)))
	  ;; Finally test an invalid connection does something sensible
	  (setf (in-use test-conn) t)
	  (is (not (connected test-conn)))
	  (is (not (available test-conn)))))

(defmethod test-connection-equal ()
  (is (connection-equal
       (make-instance 'connection :pointer (cffi:null-pointer))
       (make-instance 'connection :pointer (cffi:null-pointer))))
  (is (not (connection-equal
	    (make-instance 'connection :pointer (cffi:make-pointer 1))
	    (make-instance 'connection :pointer (cffi:null-pointer))))))

(defmethod test-aquire-connection ()
  (is (null (aquire (make-instance 'connection :in-use t))))
  (is (aquire (make-instance 'connection :in-use nil))))

(defmethod test-count-connections ()
  (let ((pool (connect :min-connections 1 :max-connections 1)))
    (multiple-value-bind (total available) (count-connections pool)
      (is (eql 1 total))
      (is (eql 1 available)))
    (let ((c (aquire pool nil)))
    (multiple-value-bind (total available) (count-connections pool)
      (is (eql 1 total))
      (is (eql 0 available)))
    (release c)
    (multiple-value-bind (total available) (count-connections pool)
      (is (eql 1 total))
      (is (eql 1 available))))))