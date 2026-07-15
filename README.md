# bogenherr

`bogenherr` is the public-facing business storefront website for
Carlos Konstanski's Violin and Viola Studio in Pocatello ID.

`bogenherr` is written in Lisp. The server-side is written in SBCL
while the client-side is written in ClojureScript. Additionally the
client-side uses React.js via the Reagent library.

Two of the ClojureScript library dependencies are also written by me:

https://github.com/ckonstanski/org-ckons-cljs.form

https://github.com/ckonstanski/org-ckons-cljs.notifications

`bogenherr` is deployed to production via docker-compose. For local
development I use the standard Emacs, SLIME and CIDER. The
ClojureScript project is managed with Leiningen-bin.
