(defproject bogenherr "0.1.0-SNAPSHOT"
  :description "FIXME"
  :url "FIXME"
  :license "public domain"
  :dependencies [[org.clojure/clojure "LATEST"]
                 [org.clojure/clojurescript "LATEST"]
                 [cljs-ajax "LATEST"]
                 [prismatic/dommy "LATEST"]
                 [hiccups "LATEST"]
                 [cljsjs/showdown "LATEST"]
                 [com.andrewmcveigh/cljs-time "LATEST"]]
  :plugins [[lein-cljsbuild "LATEST"]]
  :clean-targets ^{:protect false} [:target-path "out" "resources/public/cljs"])
