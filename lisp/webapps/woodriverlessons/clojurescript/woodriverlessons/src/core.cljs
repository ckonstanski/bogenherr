(ns woodriverlessons.core
  (:require-macros [hiccups.core :as hiccups :refer [html]])
  (:require [ajax.core :refer [GET POST raw-response-format]]
            [dommy.core :as dommy]
            [hiccups.runtime :as hiccupsrt]
            [cljsjs.showdown :as showdown]
            [clojure.string :as str]
            [cljs-time.format :as time-format]
            [org-ckons-cljs.notifications.core :as ck-notifications]
            [org-ckons-cljs.form.core :as ck-form]))

;; declarations

(enable-console-print!)
(def jquery (js* "$"))
(def sql-formatter (time-format/formatter "yyyy-MM-dd HH:mm:ss"))
(def pretty-formatter (time-format/formatters :rfc822))

(declare date-sql-to-pretty)
(declare markdown-to-html)
(declare reduce-checkboxes)
(declare notifications)
(declare auth-notifications)
(declare template-menu)
(declare template-menu-user)
(declare handler-menu)
(declare handler-menu-user)
(declare render-menu)
(declare template-home)
(declare handler-home)
(declare render-home)
(declare template-login)
(declare handler-login)
(declare render-login)
(declare on-login-submit-clicked)
(declare handler-login-authenticate)
(declare render-login-authenticate)
(declare handler-logout)
(declare render-logout)
(declare template-profile)
(declare handler-profile)
(declare render-profile)
(declare template-profile-view)
(declare handler-profile-view)
(declare render-profile-view)
(declare on-profile-modify-clicked)
(declare template-profile-modify)
(declare handler-profile-modify)
(declare render-profile-modify)
(declare on-profile-modify-submit-clicked)
(declare handler-profile-modify-submit)
(declare render-profile-modify-submit)
(declare template-password)
(declare handler-password)
(declare render-password)
(declare on-password-submit-clicked)
(declare handler-password-submit)
(declare render-password-submit)
(declare template-about-us)
(declare handler-about-us)
(declare render-about-us)
(declare template-testimonials)
(declare handler-testimonials)
(declare render-testimonials)
(declare template-testimonials-view)
(declare handler-testimonials-view)
(declare render-testimonials-view)
(declare on-testimonials-modify-clicked)
(declare template-testimonials-modify)
(declare handler-testimonials-modify)
(declare render-testimonials-modify)
(declare on-testimonials-modify-submit-clicked)
(declare handler-testimonials-modify-submit)
(declare render-testimonials-modify-submit)
(declare template-contact-us)
(declare handler-contact-us)
(declare render-contact-us)
(declare template-contact-us-view)
(declare handler-contact-us-view)
(declare render-contact-us-view)
(declare on-contact-us-email-submit-clicked)
(declare handler-contact-us-email-submit)
(declare render-contact-us-email-submit)
(declare template-messages)
(declare handler-messages)
(declare render-messages)
(declare on-messages-mode-clicked)
(declare template-messages-results)
(declare handler-messages-results)
(declare render-messages-results)
(declare on-messages-mark)
(declare handler-messages-mark)
(declare render-messages-mark)
(declare template-users)
(declare handler-users)
(declare render-users)
(declare template-users-view)
(declare handler-users-view)
(declare render-users-view)
(declare on-users-add-clicked)
(declare template-users-add)
(declare handler-users-add)
(declare render-users-add)
(declare on-users-add-submit-clicked)
(declare handler-users-add-submit)
(declare render-users-add-submit)
(declare template-users-register)
(declare handler-users-register)
(declare render-users-register)
(declare template-users-register-form)
(declare handler-users-register-form)
(declare handler-users-register-form-impl)
(declare render-users-register-form)
(declare on-users-register-submit-clicked)
(declare template-users-register-submit)
(declare handler-users-register-submit)
(declare render-users-register-submit)
(declare on-users-modify-clicked)
(declare template-users-modify)
(declare handler-users-modify)
(declare render-users-modify)
(declare on-users-modify-submit-clicked)
(declare handler-users-modify-submit)
(declare render-users-modify-submit)
(declare on-users-toggle-active-clicked)
(declare handler-users-toggle-active)
(declare render-users-toggle-active)
(declare on-users-delete-clicked)
(declare handler-users-delete)
(declare render-users-delete)
(declare on-menu-clicked)
(declare handler-location)
(declare goto-location)
(declare reset-app)
(declare goto-register)

(defn date-sql-to-pretty [sql-date]
  (first (str/split (time-format/unparse pretty-formatter (time-format/parse sql-formatter (first (str/split sql-date ".")))) " Z")))

(defn markdown-to-html [markdown]
  (let [converter (js/showdown.Converter.)]
    (.makeHtml converter markdown)))

(defn reduce-checkboxes [selector]
  "Reduces the names of all checked checkboxes to a pipe-separated
  list. Assumes that the checkboxes are named via the convention
  `chk_something-more'. The important thing is the underscore
  separating the throwaway prefix and the remaining useful
  bit. `selector' will likely be something like: [id^='chk_']"
  (reduce (fn [x y]
            (cond (and x y) (str x "|" y)
                  (and x (not y)) x
                  (and (not x) y) y
                  :else ""))
          (map (fn [elem]
                 (let [this (jquery (str "#" (dommy/attr elem :id)))]
                   (when (-> this (.prop "checked"))
                     (second (str/split (-> this (.prop "id")) "_")))))
               (.toArray (jquery selector)))))

;; notifications

(defn notifications [jsonobj]
  (ck-notifications/maybe-message jsonobj)
  (ck-notifications/maybe-error jsonobj))

(defn auth-notifications [jsonobj]
  (cond (empty? (get jsonobj "errormsg"))
        (notifications jsonobj)
        :else
        (do
          (render-home "" (get jsonobj "errormsg"))
          (render-menu))))

;; menu

(hiccups/defhtml template-menu [menuitems]
  [:ul {:class "nav nav-pills"}
   (for [menuitem menuitems]
     [:li {:class "nav-item"}
      [:a {:class (cond (= (str/upper-case (get menuitem "handler"))
                           (str/upper-case (dommy/html (dommy/sel1 :#location))))
                        "nav-link active"
                        :else
                        "nav-link")
           :id (get menuitem "id")
           :onclick (str (namespace ::x) ".on_menu_clicked('" (get menuitem "handler") "')")}
       (get menuitem "label")]])])

(hiccups/defhtml template-menu-user [jsonobj]
  [:div {:class "dropdown"}
   [:button {:class "btn btn-primary dropdown-toggle"
             :type "button"
             :id "button-menu-user"
             :data-toggle "dropdown"
             :aria-haspopup "true"
             :aria-expanded "false"}
    (get jsonobj "label")]
   [:div {:class "dropdown-menu" :aria-labelledby "button-menu-user"}
    (for [menuitem (get jsonobj "menuitems")]
      [:a {:class "dropdown-item"
           :onclick (str (namespace ::x) ".on_menu_clicked('" (get menuitem "handler") "')")}
       (get menuitem "label")])]])

(defn handler-menu [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (dommy/set-html! (dommy/sel1 :#menu) (template-menu (get jsonobj "menuitems")))))

(defn handler-menu-user [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (dommy/set-html! (dommy/sel1 :#menu-user) (template-menu-user jsonobj))))

(defn render-menu []
  (GET "/menu" {:handler handler-menu})
  (GET "/menu/user" {:handler handler-menu-user}))

;; home

(hiccups/defhtml template-home [jsonobj]
  [:h1 {:style "text-align: center"} "Carlos Konstanski welcomes you to his violin and viola studio!"]
  [:div {:style "text-align: center"}
   [:img {:style "width: 100%"
          :src "/static/images/instrument-cabinet.jpg"}]])

(defn handler-home [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-home jsonobj))))

(defn render-home
  ([]
   (GET "/home" {:handler handler-home}))
  ([message errormsg]
   (POST  "/home"
          {:format :raw
           :params {:message message
                    :errormsg errormsg}
           :handler handler-home})))

;; login

(hiccups/defhtml template-login [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x))
  [:div {:style "text-align: center"}
   [:a {:href ""} "Forgot password?"]])

(defn handler-login [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-login jsonobj))))

(defn render-login []
  (GET "/login" {:handler handler-login}))

;; login-authenticate

(defn on-login-submit-clicked []
  (when (-> (jquery "#login-form")
            (.get "0")
            (.checkValidity))
    (render-login-authenticate)))

(defn handler-login-authenticate [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (cond (get jsonobj "errormsg")
          (goto-location "/login")
          (get jsonobj "message")
          (do
            (dommy/set-html! (dommy/sel1 :#location) "/home")
            (render-home)
            (render-menu)))))

(defn render-login-authenticate []
  (POST "/login/authenticate"
        {:format :raw
         :params {:username (dommy/value (dommy/sel1 :#username))
                  :pwd (dommy/value (dommy/sel1 :#pwd))}
         :handler handler-login-authenticate}))

;; logout

(defn handler-logout [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (render-home "You are now logged out" "")
    (dommy/set-html! (dommy/sel1 :#location) "/home")
    (render-menu)))

(defn render-logout []
  (GET "/logout" {:handler handler-logout}))

;; profile

(hiccups/defhtml template-profile [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  [:div {:id "content"}]
  [:div {:id "modify"
         :class "modal fade"
         :role "dialog"}
   [:div {:class "modal-dialog modal-lg"}
    [:div {:class "modal-content"}
     [:div {:class "modal-header"}
      [:h5 {:class "modal-title"} "Profile - Modify"]
      [:button {:type "button"
                :class "close"
                :data-dismiss "modal"}
       "&times;"]]
     [:div {:id "modify-body"
            :class "modal-body"
            :style "height: 460px;"}]
     [:div {:class "modal-footer"}
      [:button {:type "submit"
                :class "btn btn-danger btn-default"
                :data-dismiss "modal"}
       [:span {:class "glyphicon glyphicon-remove"}]
       "Cancel"]]]]])

(defn handler-profile [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-profile jsonobj))
    (render-profile-view)))

(defn render-profile []
  (GET "/profile" {:handler handler-profile}))

;; profile-view

(hiccups/defhtml template-profile-view [jsonobj]
  [:div {:style "text-align: right"}
   [:img {:src "/static/images/edit.png"
          :style "cursor:pointer; cursor:hand"
          :onclick (str (namespace ::x) ".on_profile_modify_clicked()")}]]
  [:div {:class "container"}
   [:div {:class "row"}
    [:div {:class "col" :style "text-align: right"} "Username:"]
    [:div {:class "col-10"} (get jsonobj "username")]]
   [:div {:class "row"}
    [:div {:class "col" :style "text-align: right"} "First Name:"]
    [:div {:class "col-10"} (get jsonobj "first_name")]]
   [:div {:class "row"}
    [:div {:class "col" :style "text-align: right"} "Last Name:"]
    [:div {:class "col-10"} (get jsonobj "last_name")]]
   [:div {:class "row"}
    [:div {:class "col" :style "text-align: right"} "Email:"]
    [:div {:class "col-10"} (get jsonobj "email")]]
   [:div {:class "row"}
    [:div {:class "col" :style "text-align: right"} "Phone:"]
    [:div {:class "col-10"} (get jsonobj "phone")]]])

(defn handler-profile-view [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (dommy/set-html! (dommy/sel1 :#content) (template-profile-view jsonobj))))

(defn render-profile-view []
  (GET "/profile/view" {:handler handler-profile-view}))

;; profile-modify

(defn on-profile-modify-clicked []
  (render-profile-modify))

(hiccups/defhtml template-profile-modify [jsonobj]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))

(defn handler-profile-modify [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#modify-body) (template-profile-modify jsonobj))
    (.modal (jquery "#modify"))))

(defn render-profile-modify []
  (POST "/profile/modify" {:handler handler-profile-modify}))

;; profile-modify-submit

(defn on-profile-modify-submit-clicked []
  (when (-> (jquery "#profile-modify-form")
            (.get "0")
            (.checkValidity))
    (.modal (jquery "#modify") "hide")
    (render-profile-modify-submit)))

(defn handler-profile-modify-submit [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/profile")))

(defn render-profile-modify-submit []
  (POST "/profile/modify/submit"
        {:format :raw
         :params {:id (dommy/value (dommy/sel1 :#id))
                  :username (dommy/value (dommy/sel1 :#username))
                  :first_name (dommy/value (dommy/sel1 :#first_name))
                  :last_name (dommy/value (dommy/sel1 :#last_name))
                  :email (dommy/value (dommy/sel1 :#email))
                  :phone (dommy/value (dommy/sel1 :#phone))}
         :handler handler-profile-modify-submit}))

;; password

(hiccups/defhtml template-password [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))

(defn handler-password [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-password jsonobj))))

(defn render-password []
  (GET "/password" {:handler handler-password}))

;; password-submit

(defn on-password-submit-clicked []
  (when (-> (jquery "#password-form")
            (.get "0")
            (.checkValidity))
    (render-password-submit)))

(defn handler-password-submit [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/password")))

(defn render-password-submit []
  (POST "/password/submit"
        {:format :raw
         :params {:id (dommy/value (dommy/sel1 :#id))
                  :pwd (dommy/value (dommy/sel1 :#pwd))
                  :pwd2 (dommy/value (dommy/sel1 :#pwd2))}
         :handler handler-password-submit}))

;; about-us

(hiccups/defhtml template-about-us [jsonobj]
  [:h1 {:style "text-align: center"} "About the Studio"]
  [:h3 "The Teacher"]
  [:p "My name is Carlos Konstanski. I am the principal violist in the Wood River Orchestra. I have previously played in the viola sections of the following college and community orchestras:"]
  [:ul
   [:li "Idaho State Civic Symphony in Pocatello ID"]
   [:li "Health and Wellness Orchestra in Fort Collins CO"]
   [:li "Loveland Orchestra in Loveland CO"]
   [:li "University of Oregon Symphony Orchestra in Eugene OR"]
   [:li "Leipziger Universitätsorchester in Leipzig Germany"]]
  [:p "I started playing the viola at age 10 and picked up the violin decades later. My viola is a fine instrument made by Bronek Cison in 2010, while my violin is a high-quality student instrument made 100 years ago in Bohemia by an unknown luthier."]
  [:p "Most of my musical studies took place at Idaho State University. I was a music major from 1988 to 1993. Then I returned to ISU from 2010 to 2012 to study computer science. It was during this latter period that I had the great fortune and privilege to study with " [:a {:href "https://nafme.org/member-profile/chung-park/" :target "_blank"} "Dr. Chung Park"] ". These two years were an immensely productive and life-changing experience. What I learned from this incomparable master informs every aspect of my playing today, and it is this body of knowledge that I wish to share with my musical community. A high-quality teacher makes all the difference! Every well-trained player has a teacher to whom they owe everything."]
  [:h3 "The Philosophy"]
  [:p "Playing the violin and viola is like any other art form in that it is composed of two parts: the artistic ideas which want to be expressed and the craft which provides the artist with the means to express them. Musicians usually use the word \"technique\" in place of \"craft\". The finest artistic ideas ever conceived will never see the light of day if the performer lacks the technique to express them. Likewise the most tremendous technique in the world will not inspire the audience if it is not informed by artistic intent."]
  [:p "My goal as a teacher is to help you develop a solid technique that you can use to express your own artistic thoughts. I am artistically highly opinionated and I want my students to be equally opinionated even if, and especially if, their ideas differ from mine. If you ask me technical questions then you can expect concrete answers; but artistic questions will generally be met with more questions. I will help you find your way as a violinist or violist, but you must ultimately find your own way as an artist. That said, I will enthusiastically guide you on your artistic journey, providing you with the tools to make smart choices. I just won't make the choices for you, for that would be irresponsible on my part and stifling for you."]
  [:p "A solid technique must be built on a sound foundation. One starts with certain fundamentals and continually revisits them to ensure that they remain strong. Without solid fundamentals the entire structure topples like a house of cards. These fundamentals fall into three physical zones corresponding to the middle, left and right parts of the body: the instrument hold and posture, the left-hand technique and the bow technique. If your fundamentals are rock-solid then the sky is the limit (and you don't need me!). However if your previous training was lacking then you may find it necessary to relearn some things in order to rebuild your foundation. This is a bitter pill for many students to swallow. Since it is so essential to the entire process, you will find that I won't offer any leniency in this area. I went through it myself after having played with a hobbled technique for 30 years and it was the best thing that I ever did. Don't let your ego fool you into thinking that you don't need this. Your ego is a liar. It is not interested in your artistic development. It only wants to make you feel good about yourself. It is the antithesis of truth. Artists seek truth, not palliatives."]
  [:p "The study of the violin or viola is a constant exercise in being drawn out of your comfort zone. This is just another way of saying that it's about exploring what lies beyond the limits of your experience. Approach it with an adventurous spirit. Learn to love taking that next step into the unknown. When you are trying something new and it is uncomfortable, don't give up on it. It will eventually feel natural and then new doors will open for you."]
  [:h3 "The Studio"]
  [:p "Students may come to my house for lessons or I can come to you. My house is conveniently located in Hailey. If I come to you then I will charge for the extra time and travel expense. My rates are highly individual. Everyone is different."]
  [:p "The frequency of lessons also varies depending on the individual. Some students who are highly motivated and have lots of time to practice will have a lesson every week. Most others (those with full-time jobs or other major time commitments) will have a lesson every two weeks. I expect all students to commit to at least some practice every day, even if it's only a half-hour. Missed days should be a rare occurrence. I miss some days myself (as I have a day job), but I feel bad about it. Self-motivation is the #1 ingredient for success. With it you can achieve anything. Without it you can achieve nothing."])

(defn handler-about-us [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-about-us jsonobj))))

(defn render-about-us []
  (GET "/about-us" {:handler handler-about-us}))

;; testimonials

(hiccups/defhtml template-testimonials [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  [:div {:id "content"}]
  [:div {:id "modify"
         :class "modal fade"
         :role "dialog"}
   [:div {:class "modal-dialog modal-lg"}
    [:div {:class "modal-content"}
     [:div {:class "modal-header"}
      [:h5 [:span {:id "modify-title"}]]
      [:button {:type "button"
                :class "close"
                :data-dismiss "modal"}
       "&times;"]]
     [:div {:id "modify-body"
            :class "modal-body"
            :style "height: 460px;"}]
     [:div {:class "modal-footer"}
      [:button {:type "submit"
                :class "btn btn-danger btn-default"
                :data-dismiss "modal"}
       [:span {:class "glyphicon glyphicon-remove"}]
       "Cancel"]]]]])

(defn handler-testimonials [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-testimonials jsonobj))
    (render-testimonials-view)))

(defn render-testimonials []
  (GET "/testimonials" {:handler handler-testimonials}))

;; testimonials-view

(hiccups/defhtml template-testimonials-view [jsonobj]
  (when (get jsonobj "adminP")
    [:div {:style "text-align: right;"}
     [:img {:src "/static/images/edit.png"
            :style "cursor:pointer; cursor:hand"
            :onclick (str (namespace ::x) ".on_testimonials_modify_clicked()")}]])
  [:div {:id "markdown"}])

(defn handler-testimonials-view [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (dommy/set-html! (dommy/sel1 :#content) (template-testimonials-view jsonobj))
    (dommy/set-html! (dommy/sel1 :#markdown) (markdown-to-html (get jsonobj "content")))))

(defn render-testimonials-view []
  (GET "/testimonials/view" {:handler handler-testimonials-view}))

;; testimonials-modify

(defn on-testimonials-modify-clicked []
  (render-testimonials-modify))

(hiccups/defhtml template-testimonials-modify [jsonobj]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))

(defn handler-testimonials-modify [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#modify-title) (get jsonobj "title"))
    (dommy/set-html! (dommy/sel1 :#modify-body) (template-testimonials-modify jsonobj))
    (.modal (jquery "#modify"))))

(defn render-testimonials-modify []
  (POST "/testimonials/modify" {:handler handler-testimonials-modify}))

;; testimonials-modify-submit

(defn on-testimonials-modify-submit-clicked []
  (when (-> (jquery "#testimonials-modify-form")
            (.get "0")
            (.checkValidity))
    (.modal (jquery "#modify") "hide")
    (render-testimonials-modify-submit)))

(defn handler-testimonials-modify-submit [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/testimonials")))

(defn render-testimonials-modify-submit []
  (POST "/testimonials/modify/submit"
        {:format :raw
         :params {:content (dommy/value (dommy/sel1 :#txt-content))}
         :handler handler-testimonials-modify-submit}))

;; contact-us

(hiccups/defhtml template-contact-us [jsonobj]
  [:h1 {:style "text-align: center"} "Reach out to me by filling out the form."]
  [:p {:style "text-align: center"} "Or call me at (970) 294-9708."]
  [:div {:id "content"}])

(defn handler-contact-us [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-contact-us jsonobj))
    (render-contact-us-view)))

(defn render-contact-us []
  (GET "/contact-us" {:handler handler-contact-us}))

;; contact-us-view

(hiccups/defhtml template-contact-us-view [jsonobj]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))

(defn handler-contact-us-view [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#content) (template-contact-us-view jsonobj))))

(defn render-contact-us-view []
  (GET "/contact-us/view" {:handler handler-contact-us-view}))

;; contact-us-email

(defn on-contact-us-email-submit-clicked []
  (render-contact-us-email-submit))

(defn handler-contact-us-email-submit [response]
  (on-menu-clicked "/contact-us"))

(defn render-contact-us-email-submit []
  (POST "/contact-us/email"
        {:format :raw
         :params {:first_name (dommy/value (dommy/sel1 :#first_name))
                  :last_name (dommy/value (dommy/sel1 :#last_name))
                  :email (dommy/value (dommy/sel1 :#email))
                  :phone (dommy/value (dommy/sel1 :#phone))
                  :comments (dommy/value (dommy/sel1 :#comments))}
         :handler handler-contact-us-email-submit}))

;; messages

(hiccups/defhtml template-messages [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x))
  [:div {:id "results"}])

(defn handler-messages [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-messages jsonobj))
    (when (not (empty? (dommy/value (dommy/sel1 :#read))))
      (render-messages-results))))

(defn render-messages []
  (GET "/messages" {:handler handler-messages}))

;; messages-results

(defn on-messages-mode-clicked [read]
  (dommy/set-value! (dommy/sel1 :#read) read)
  (render-messages-results))

(hiccups/defhtml template-messages-results [jsonobj]
  (let [results (get jsonobj "results")
        keys (remove (fn [x]
                       (not (get (first results) x)))
                     (keys (first results)))]
    (cond (empty? results)
          [:h5 {:style "text-align: center"} "No results found."]
          :else
          [:table {:class "table table-hover"}
           [:thead
            [:tr
             (for [key keys]
               [:th key])
             [:th
              (str "Mark " (cond (= (dommy/value (dommy/sel1 :#read)) "read")
                                    "unread"
                                    :else
                                    "read"))]]]
           [:tbody
            (for [rec results]
              (let [onclick "void()"]
                [:tr
                 (for [key keys]
                   [:td {:onclick onclick} (get rec key)])
                 [:td [:img {:src (str "/static/images/"
                                       (cond (= (dommy/value (dommy/sel1 :#read)) "read")
                                             "edit-undo.png"
                                             :else
                                             "edit-redo.png"))
                             :style "cursor: pointer; cursor: hand"
                             :onclick (str (namespace ::x)
                                           ".on_messages_mark("
                                           (cond (= (dommy/value (dommy/sel1 :#read)) "read")
                                                 "'unread'"
                                                 :else
                                                 "'read'")
                                           "," (get rec "id") ")")}]]]))]])))

(defn handler-messages-results [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#results) (template-messages-results jsonobj))))

(defn render-messages-results []
  (POST "/messages/results"
        {:format :raw
         :params {:read (dommy/value (dommy/sel1 :#read))}
         :handler handler-messages-results}))

;; messages-mark

(defn on-messages-mark [read id]
  (render-messages-mark read id))

(defn handler-messages-mark [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/messages")))

(defn render-messages-mark [read id]
  (POST "/messages/mark"
        {:format :raw
         :params {:read read
                  :id id}
         :handler handler-messages-mark}))

;; users

(hiccups/defhtml template-users [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  [:div {:id "content"}]
  [:div {:id "modify"
         :class "modal fade"
         :role "dialog"}
   [:div {:class "modal-dialog modal-lg"}
    [:div {:class "modal-content"}
     [:div {:class "modal-header"}
      [:h5 [:span {:id "modify-title"}]]
      [:button {:type "button"
                :class "close"
                :data-dismiss "modal"}
       "&times;"]]
     [:div {:id "modify-body"
            :class "modal-body"
            :style "height: 450px;"}]
     [:div {:class "modal-footer"}
      [:button {:type "submit"
                :class "btn btn-danger btn-default"
                :data-dismiss "modal"}
       [:span {:class "glyphicon glyphicon-remove"}]
       "Cancel"]]]]])

(defn handler-users [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#body) (template-users jsonobj))
    (render-users-view)))

(defn render-users []
  (GET "/users" {:handler handler-users}))

;; users-view

(hiccups/defhtml template-users-view [jsonobj]
  [:div {:style "text-align: right"}
   [:img {:src "/static/images/add.png"
          :style "cursor:pointer; cursor:hand"
          :onclick (str (namespace ::x) ".on_users_add_clicked()")}]]
  [:table {:class "table table-striped table-hover table-sm"}
   [:thead
    [:tr
     [:th {:scope "col"} "Active?"]
     [:th {:scope "col"} "Last Name"]
     [:th {:scope "col"} "First Name"]
     [:th {:scope "col"} "Username"]
     [:th {:scope "col"} "Email"]
     [:th {:scope "col"} "Phone"]
     [:th {:scope "col"} "Del"]]]
   [:tbody
    (for [user (get jsonobj "users")]
      (let [onclick (str (namespace ::x) ".on_users_modify_clicked(" (get user "id") ")")
            toggle-active (str (namespace ::x) ".on_users_toggle_active_clicked(" (get user "id") ")")]
        [:tr
         [:td [:img {:src (cond (get user "active")
                                "/static/images/yes.png"
                                :else
                                "/static/images/no.png")
                     :onclick toggle-active}]]
         [:td {:onclick onclick} (get user "last_name")]
         [:td {:onclick onclick} (get user "first_name")]
         [:td {:onclick onclick} (get user "username")]
         [:td {:onclick onclick} (get user "email")]
         [:td {:onclick onclick} (get user "phone")]
         [:td [:img {:src "/static/images/delete.png"
                     :onclick (str (namespace ::x) ".on_users_delete_clicked(" (get user "id") ", '" (get user "first_name") "', '" (get user "last_name") "')")}]]]))]])
  
(defn handler-users-view [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (dommy/set-html! (dommy/sel1 :#content) (template-users-view jsonobj))))

(defn render-users-view []
  (GET "/users/view" {:handler handler-users-view}))

;; users-add

(defn on-users-add-clicked []
  (render-users-add))

(hiccups/defhtml template-users-add [jsonobj]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))

(defn handler-users-add [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#modify-title) (get jsonobj "title"))
    (dommy/set-html! (dommy/sel1 :#modify-body) (template-users-add jsonobj))
    (.modal (jquery "#modify"))))

(defn render-users-add []
  (POST "/users/add" {:handler handler-users-add}))

;; users-add-submit

(defn on-users-add-submit-clicked []
  (when (-> (jquery "#users-add-form")
            (.get "0")
            (.checkValidity))
    (.modal (jquery "#modify") "hide")
    (render-users-add-submit)))

(defn handler-users-add-submit [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/users")))

(defn render-users-add-submit []
  (POST "/users/add/submit"
        {:format :raw
         :params {:role_groups (reduce-checkboxes "[id^='chk_']")
                  :first_name (dommy/value (dommy/sel1 :#first_name))
                  :last_name (dommy/value (dommy/sel1 :#last_name))
                  :email (dommy/value (dommy/sel1 :#email))}
         :handler handler-users-add-submit}))

;; users-register

(hiccups/defhtml template-users-register [jsonobj]
  [:h3 {:style "text-align: center"} (get jsonobj "title")]
  [:div {:id "content"}])

(defn handler-users-register [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (dommy/set-html! (dommy/sel1 :#body) (template-users-register jsonobj))
    (render-users-register-form (get jsonobj "hash"))))

(defn render-users-register [hash]
  (POST "/users/register"
        {:format :raw
         :params {:hash hash}
         :handler handler-users-register}))

;; users-register-form

(hiccups/defhtml template-users-register-form [jsonobj]
  (cond (get jsonobj "errormsg")
        [:a {:href (str "javascript:" (namespace ::x) ".reset_app()")}
         "Click here to return to the home page."]
        :else
        (do
          [:p (str "Welcome " (get jsonobj "firstName") " " (get jsonobj "lastName") " to the new user registration page. Please fill out the form below to complete your registration.")]
          [:p "Create a new username and password for your login to the website. Phone number is optional."]
          [:p (str "Your email address is recorded as " (get jsonobj "email") ". This is where notifications will be sent. If this is not the desired email address, you can change it later by visiting the Edit Profile page.")]
          [:p (str "This registration will expire in " (get jsonobj "validFor") ". Please submit this form before that time.")]
          (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))))

(defn handler-users-register-form [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#content) (template-users-register-form jsonobj))))

(defn render-users-register-form [hash]
  (POST "/users/register/form"
        {:format :raw
         :params {:hash hash}
         :handler handler-users-register-form}))

;; users-register-submit

(defn on-users-register-submit-clicked []
  (when (-> (jquery "#users-register-form")
            (.get "0")
            (.checkValidity))
    (render-users-register-submit)))

(hiccups/defhtml template-users-register-submit [jsonobj]
  [:a {:href (str "javascript:" (namespace ::x) ".reset_app()")}
   "Click here to start using the website!"])

(defn handler-users-register-submit [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (notifications jsonobj)
    (cond (get jsonobj "errormsg")
          (do
            (dommy/set-value! (dommy/sel1 :#pwd) "")
            (dommy/set-value! (dommy/sel1 :#pwd2) ""))
          :else
          (dommy/set-html! (dommy/sel1 :#content) (template-users-register-submit jsonobj)))))

(defn render-users-register-submit []
  (POST "/users/register/submit"
        {:format :raw
         :params {:hash (dommy/value (dommy/sel1 :#hash))
                  :username (dommy/value (dommy/sel1 :#username))
                  :pwd (dommy/value (dommy/sel1 :#pwd))
                  :pwd2 (dommy/value (dommy/sel1 :#pwd2))
                  :phone (dommy/value (dommy/sel1 :#phone))}
         :handler handler-users-register-submit}))

;; users-modify

(defn on-users-modify-clicked [id]
  (render-users-modify id))

(hiccups/defhtml template-users-modify [jsonobj]
  (ck-form/template-generic-form (get jsonobj "form") (namespace ::x)))

(defn handler-users-modify [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (dommy/set-html! (dommy/sel1 :#modify-title) (get jsonobj "title"))
    (dommy/set-html! (dommy/sel1 :#modify-body) (template-users-modify jsonobj))
    (.modal (jquery "#modify"))))

(defn render-users-modify [id]
  (POST "/users/modify"
        {:format :raw
         :params {:id id}
         :handler handler-users-modify}))

;; users-modify-submit

(defn on-users-modify-submit-clicked []
  (when (-> (jquery "#users-modify-form")
            (.get "0")
            (.checkValidity))
    (.modal (jquery "#modify") "hide")
    (render-users-modify-submit)))

(defn handler-users-modify-submit [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/users")))

(defn render-users-modify-submit []
  (POST "/users/modify/submit"
        {:format :raw
         :params {:id (dommy/value (dommy/sel1 :#id))
                  :role_groups (reduce-checkboxes "[id^='chk_']")
                  :username (dommy/value (dommy/sel1 :#username))
                  :first_name (dommy/value (dommy/sel1 :#first_name))
                  :last_name (dommy/value (dommy/sel1 :#last_name))
                  :email (dommy/value (dommy/sel1 :#email))
                  :phone (dommy/value (dommy/sel1 :#phone))}
         :handler handler-users-modify-submit}))

;; users-toggle-active

(defn on-users-toggle-active-clicked [id]
  (render-users-toggle-active id))

(defn handler-users-toggle-active [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/users")))

(defn render-users-toggle-active [id]
  (POST "/users/toggle-active"
        {:format :raw
         :params {:id id}
         :handler handler-users-toggle-active}))

;; users-delete

(defn on-users-delete-clicked [id first-name last-name]
  (when (js/confirm (str "Are you sure you want to delete " first-name " " last-name "? This action cannot be undone."))
    (render-users-delete id)))

(defn handler-users-delete [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (auth-notifications jsonobj)
    (on-menu-clicked "/users")))

(defn render-users-delete [id]
  (POST "/users/delete"
        {:format :raw
         :params {:id id}
         :handler handler-users-delete}))

;; location

(defn on-menu-clicked [handler]
  (dommy/set-html! (dommy/sel1 :#location) handler)
  (render-menu)
  (cond (= handler "/home") (render-home)
        (= handler "/login") (render-login)
        (= handler "/logout") (render-logout)
        (= handler "/profile") (render-profile)
        (= handler "/password") (render-password)
        (= handler "/about-us") (render-about-us)
        (= handler "/testimonials") (render-testimonials)
        (= handler "/contact-us") (render-contact-us)
        (= handler "/messages") (render-messages)
        (= handler "/users") (render-users)))

(defn handler-location [response]
  (let [jsonobj (js->clj (js/JSON.parse response))]
    (on-menu-clicked (get jsonobj "location"))
    (notifications jsonobj)))

(defn goto-location [location]
  (POST "/location"
        {:format :raw
         :params {:location location}
         :handler handler-location}))

(defn reset-app []
  (set! (.-location js/document) "/"))

(defn goto-register [hash]
  (dommy/set-html! (dommy/sel1 :#location) "/users/register")
  (render-menu)
  (render-users-register hash))
