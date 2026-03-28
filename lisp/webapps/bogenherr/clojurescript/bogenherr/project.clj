(defproject bogenherr.core "0.1.0-SNAPSHOT"
  :description "FIXME"
  :url "FIXME"
  :license "public domain"
  :min-lein-version "2.7.1"
  :dependencies [[org.clojure/clojure "LATEST"]
                 [org.clojure/clojurescript "LATEST"]
                 [cljs-ajax "LATEST"]
                 [prismatic/dommy "LATEST"]
                 [hiccups "LATEST"]
                 [cljsjs/showdown "LATEST"]
                 [com.andrewmcveigh/cljs-time "LATEST"]
                 [cljsjs/react "LATEST"]
                 [cljsjs/react-dom "LATEST"]
                 [cljsjs/react-dom-server "LATEST"]
                 [reagent "LATEST"]]
  :source-paths ["src"]
  :aliases {"fig:build" ["trampoline" "run" "-m" "figwheel.main" "-b" "dev" "-r"]
            "fig:min"   ["run" "-m" "figwheel.main" "-O" "advanced" "-bo" "dev"]}
  :profiles {:dev {:dependencies [[com.bhauman/figwheel-main "LATEST"]
                                  [org.slf4j/slf4j-nop "LATEST"]
                                  [com.bhauman/rebel-readline-cljs "LATEST"]]
                   :resource-paths ["target"]
                   :clean-targets ^{:protect false} ["target"]}})
