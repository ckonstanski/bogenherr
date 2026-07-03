#!/bin/bash

curl -o ~/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp
sbcl --load ~/quicklisp.lisp --eval "(quicklisp-quickstart:install)" --eval "(sb-ext:exit)"
sbcl --eval "(loop for pkg in '(cl-ppcre cl-smtp hunchentoot easy-routes cl-log ironclad cl-markdown tmpdir net-telent-date uffi drakma cl-json postmodern fiveam local-time trivial-octet-streams swank) do (ql:quickload (symbol-name pkg)))" --eval "(sb-ext:exit)"

mkdir -p ~/.config/common-lisp
echo "(:source-registry (:tree (:home \"common-lisp/systems\")) :inherit-configuration)" | tee ~/.config/common-lisp/source-registry.conf

exit 0
