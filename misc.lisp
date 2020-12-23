(ql:quickload :cffi)

(cffi:define-foreign-library libmysqlclient
    (:darwin (:or "libmysqlclient.so.21.1.22.dylib" "libmysqlclient.dylib"))
    (:unix (:or "libmysqlclient.so.21.1.22" "libmysqlclient.so"))
    (t (:default "libmysqlclient")))

(cffi:use-foreign-library libmysqlclient)

(cffi:defctype t-mysql :pointer)

(cffi:defcfun "mysql_get_client_info" :string)

(cffi:defcfun "mysql_get_client_version" :unsigned-long)

(cffi:defcfun "mysql_library_init" :int
  (argc :int)
  (argv :pointer)
  (groups :pointer))

(cffi:defcfun "mysql_library_end" :void)

(cffi:defcfun "mysql_init" t-mysql
  (mysql t-mysql))

(cffi:defcfun "mysql_real_connect" t-mysql
  (mysql    t-mysql)
  (host     :pointer)
  (user     :pointer)
  (passwd   :pointer)
  (db       :pointer)
  (port     :unsigned-int)
  (unix-socket :pointer)
  (client-flag :unsigned-long))

(cffi:defcfun "mysql_close" :void
  (mysql t-mysql))

(defun w-mysql-real-connect (mysql host user passwd db port clientflag)
  (cffi:with-foreign-strings
      ((host-native host)
       (user-native user)
       (passwd-native passwd)
       (db-native db))
    (mysql-real-connect mysql host-native user-native passwd-native db-native port (cffi:null-pointer) clientflag)))
