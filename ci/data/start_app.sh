#!/bin/bash

mkdir -p ~/common-lisp/systems ~/opt
cd ~/opt
git clone -b master git@ns:repos/bogenherr.git
git clone -b master git@github.com:ckonstanski/org-ckons-cljs.form.git
git clone -b master git@github.com:ckonstanski/org-ckons-cljs.notifications
git clone -b master git@github.com:ckonstanski/org-ckons-condition
git clone -b master git@github.com:ckonstanski/org-ckons-core
git clone -b master git@github.com:ckonstanski/org-ckons-file
git clone -b master git@github.com:ckonstanski/org-ckons-http
git clone -b master git@github.com:ckonstanski/org-ckons-json
git clone -b master git@github.com:ckonstanski/org-ckons-serializable
git clone -b master git@github.com:ckonstanski/org-ckons-session
git clone -b master git@github.com:ckonstanski/org-ckons-sql

logdir="/var/log/lisp"
mv -f ${logdir}/bogenherr.log.1 ${logdir}/bogenherr.log.2
mv -f ${logdir}/bogenherr.log ${logdir}/bogenherr.log.1

pushd ~/common-lisp/systems
ln -s ~/opt/bogenherr/lisp/bogenherr.asd bogenherr.asd
ln -s ~/opt/org-ckons-condition/org-ckons-condition.asd org-ckons-condition.asd
ln -s ~/opt/org-ckons-core/org-ckons-core.asd org-ckons-core.asd
ln -s ~/opt/org-ckons-file/org-ckons-file.asd org-ckons-file.asd
ln -s ~/opt/org-ckons-http/org-ckons-http.asd org-ckons-http.asd
ln -s ~/opt/org-ckons-json/org-ckons-json.asd org-ckons-json.asd
ln -s ~/opt/org-ckons-serializable/org-ckons-serializable.asd org-ckons-serializable.asd
ln -s ~/opt/org-ckons-session/org-ckons-session.asd org-ckons-session.asd
ln -s ~/opt/org-ckons-sql/org-ckons-sql.asd org-ckons-sql.asd
popd

pushd ~/opt/bogenherr/lisp/webapps/bogenherr/conf
ln -s /etc/bogenherr/options.lisp options.lisp
popd

pushd ~/opt/bogenherr/lisp/webapps/bogenherr/clojurescript/bogenherr
ln -s /etc/bogenherr/figwheel-main.edn figwheel-main.edn
mkdir checkouts
pushd checkouts
ln -s ~/opt/org-ckons-cljs.form org-ckons-cljs.form
ln -s ~/opt/org-ckons-cljs.notifications org-ckons-cljs.notifications
popd

lein clean
lein fig:build | tee /tmp/bogenherr/lein.log &
popd

SBCL_HOME=/usr/lib/sbcl SBCL_SOURCE_ROOT=/usr/lib/sbcl/src exec sbcl --dynamic-space-size 2048 --userinit /data/bogenherr-starter.lisp | tee /tmp/bogenherr/sbcl.log
