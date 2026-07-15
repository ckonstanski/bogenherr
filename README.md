# bogenherr

`bogenherr` is the public-facing business storefront website for
Carlos Konstanski's Violin and Viola Studio in Pocatello ID.

Visit the website: https://www.bogenherr.org/

`bogenherr` is written in Lisp. The server-side is written in SBCL
while the client-side is written in ClojureScript. Additionally the
client-side uses React.js via the Reagent library.

Eight of the Common Lisp libraries are written by me:

https://github.com/ckonstanski/org-ckons-condition

https://github.com/ckonstanski/org-ckons-core

https://github.com/ckonstanski/org-ckons-file

https://github.com/ckonstanski/org-ckons-http

https://github.com/ckonstanski/org-ckons-json

https://github.com/ckonstanski/org-ckons-serializable

https://github.com/ckonstanski/org-ckons-session

https://github.com/ckonstanski/org-ckons-sql

In addition two of the ClojureScript library dependencies are written
by me:

https://github.com/ckonstanski/org-ckons-cljs.form

https://github.com/ckonstanski/org-ckons-cljs.notifications

`bogenherr` is deployed to production via docker-compose. For local
development I use the standard Emacs, SLIME and CIDER. The
ClojureScript project is managed with leiningen-bin.

This repo was made public primarily as a small sample of my
programming work for potential IT hiring managers. I don't expect that
anyone will ever want to run this app locally. But if you do then
message me and I will help with the non-obvious bits, of which there
are a few, mostly having to do with file paths.
