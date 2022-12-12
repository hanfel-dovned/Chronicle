/-  chronicle, spaces-store, visas, membership, spaces-path, chat
/+  default-agent, dbug, server, schooner
/*  chronicle-ui  %html  /app/chronicle-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 active-space=@t newsfeed=feed:chronicle]
+$  card  card:agent:gall
-- 
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %.n) bowl)
    hc    +>
++  on-init
  ^-  (quip card _this)
  :_  this(newsfeed ~)
  :~
    :*  %pass  /eyre/connect  %arvo  %e 
        %connect  `/apps/chronicle  %chronicle
    ==
    :*  %pass  /spaces-updates  %agent
        [our.bowl %spaces]  %watch  /spaces
    ==
    :*  %pass  /chats  %agent
        [our.bowl %chat]  %watch  /briefs
    ==
  ==
:: 
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  =(src.bowl our.bowl)
  ?+    mark  (on-poke:def mark vase)
      %chronicle-action
    =^  cards  state
      (handle-action !<(action:chronicle vase))
    [cards this]
    ::
      %handle-http-request
    =^  cards  state
      (handle-http !<([@ta =inbound-request:eyre] vase))
    [cards this]
  ==
  ::
  ++  handle-action
    |=  =action:chronicle
    ^-  (quip card _state)
    ?-    -.action
      ::
      ::  Add a link to your newsfeed.
        %add
      ?>  =(our.bowl src.bowl)
      ?>  =(our.bowl ship:path:link:action)
      :_  state(newsfeed :-(link:action newsfeed))
      :~  :*  %give  %fact  
              ~[/updates/(scot %p ship:path:link:action)/(scot %tas space:path:link:action)]  
              %chronicle-update
              !>(`update:chronicle`new+link:action)
      ==  ==
      ::
      ::  Save to reading list.
        %save
      ?>  =(our.bowl src.bowl)
      =/  i  (get-index-by-date newsfeed date:action)
      =/  old  ^-  link:chronicle  (snag i newsfeed)
      =/  new  ^-  link:chronicle  old(saved !saved:old)
      `state(newsfeed (snap newsfeed i new))
      ::
      ::  If not host, like link and poke host.
      ::  If host, increment likes and send update.
        %like
      =/  i  (get-index-by-date newsfeed date:action)
      =/  old  ^-  link:chronicle  (snag i newsfeed)
      ?>  =(liked:old %.n)
      ?.  =(our.bowl ship:path:old)
        ?>  =(our.bowl src.bowl)
        =/  new  ^-  link:chronicle  old(liked %.y)
        :_  state(newsfeed (snap newsfeed i new))
        :~  :*  %pass  /like  %agent
                [ship:path:new %chronicle]
                %poke  %chronicle-action
                !>([%like date:action])
        ==  ==
        ::
      =/  new  ^-  link:chronicle  old(likes +(likes:old), liked %.y)
      :_  state(newsfeed (snap newsfeed i new))
      :~  :*  
              %give  %fact  ~[/updates/(scot %p ship:path:new)/(scot %tas space:path:new)]
              %chronicle-update 
              !>(`update:chronicle`[%edit date:new new])
      ==  ==
      ::
      ::  If not host, dislike link and poke host.
      ::  If host, decrement likes and send update.
      ::::  Pretty redundant, could maybe be an arm.
        %dislike
      =/  i  (get-index-by-date newsfeed date:action)
      =/  old  ^-  link:chronicle  (snag i newsfeed)
      ?>  =(disliked:old %.n)
      ?.  =(our.bowl ship:path:old)
        ?>  =(our.bowl src.bowl)
        =/  new  ^-  link:chronicle  old(disliked %.y)
        :_  state(newsfeed (snap newsfeed i new))
        :~  :*  %pass  /dislike  %agent
                [ship:path:new %chronicle]
                %poke  %chronicle-action
                !>([%dislike date:action])
        ==  ==
        ::
      =/  new  ^-  link:chronicle  old(dislikes +(dislikes:old), disliked %.y)
      :_  state(newsfeed (snap newsfeed i new))
      :~  :*  
              %give  %fact  ~[/updates/(scot %p ship:path:new)/(scot %tas space:path:new)]
              %chronicle-update 
              !>(`update:chronicle`[%edit date:new new])
      ==  ==
      ::
      ::  If host, flip featured and send update.
        %feature
      ?>  =(our.bowl src.bowl)
      =/  i  (get-index-by-date newsfeed date:action)
      =/  old  ^-  link:chronicle  (snag i newsfeed)
      ?>  =(our.bowl ship:path:old)
      =/  new  ^-  link:chronicle  old(featured !featured:old)
      :_  state(newsfeed (snap newsfeed i new))
      :~  :*  
              %give  %fact  ~[/updates/(scot %p ship:path:new)/(scot %tas space:path:new)]
              %chronicle-update 
              !>(`update:chronicle`[%edit date:new new])
      ==  ==
    ==
  ::
  ++  handle-http
    |=  [eyre-id=@ta =inbound-request:eyre]
    ^-  (quip card _state)
    =/  ,request-line:server
      (parse-request-line:server url.request.inbound-request)
    =+  send=(cury response:schooner eyre-id)
    ?.  authenticated.inbound-request
      :_  state
      %-  send
      [302 ~ [%login-redirect './apps/chronicle']]
    ::           
    ?+    method.request.inbound-request 
      [(send [405 ~ [%stock ~]]) state]
      ::
        %'POST'
      ?~  body.request.inbound-request
        [(send [405 ~ [%stock ~]]) state]
      =/  json  (de-json:html q.u.body.request.inbound-request)
      =/  action  (dejs-action +.json)
      (handle-action action) 
      :: 
        %'GET'
      ?+  site  :_  state 
                %-  send
                :+  404
                  ~ 
                [%plain "404 - Not Found"] 
        ::
          [%apps %chronicle ~]
        =/  urltape  (trip url.request.inbound-request)
        =/  query
          ^-  @t
          |-
          ?~  urltape  ''
          ?:  =(-.urltape '=')
            (crip +.urltape)
          $(urltape +.urltape)
        :_  state(active-space query)
        %-  send  
        :+  200
          ~
        [%html chronicle-ui]  
        ::
          [%apps %chronicle %state ~]
        :_  state
        %-  send
        :+  200   
          ~ 
        [%json (enjs-state [active-space newsfeed])]
      ==
    ==
  ::              
  ++  enjs-state
    =,  enjs:format
    |=  [active=@t fee=feed:chronicle]
    ^-  json
    :-  %a
    :~
      [%s (scot %p our.bowl)]
      [%s active]
      :-  %a
      %+  turn
        fee
      |=  lin=link:chronicle
      :-  %a
      :~
        [%s url:lin]
        (path /(scot %p -:path:lin)/(scot %tas +:path:lin))
        [%s (scot %da date:lin)]
        [%s (scot %p poster:lin)]
        [%n (scot %ud likes:lin)]
        [%n (scot %ud dislikes:lin)] 
        [%b liked:lin]
        [%b disliked:lin]
        [%b saved:lin]
        [%b featured:lin]
        [%s title:lin]
        [%s image-url:lin]
      ==
    ==
    ::
    ++  dejs-action
      =,  dejs:format
      |=  jon=json
      ^-  action:chronicle
      %.  jon
      %-  of
      :~  save+(se %da)
          like+(se %da)
          dislike+(se %da)
          feature+(se %da)
      ==
  ::
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%http-response *]
    `this
    ::
      [%updates @ @ ~]
    ?<  =(src.bowl our.bowl)
    ::  Need to check here if person requesting
    ::  is actually a member of this space.
    ::  Scry spaces agent for members and compare.
    =/  links  (get-links-by-space:hc newsfeed [(slav %p +6:path) +14:path])
    :_  this
    %+  turn  links
    |=  =link:chronicle
    :*  %give  %fact  
        ~  
        %chronicle-update
        !>(`update:chronicle`new+link)
    ==
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%chats ~]
    ?+    -.sign  `this
        %kick
      :_  this
      :~  [%pass /chats %agent [src.bowl %chat] %watch /briefs]  ==
      ::
        %fact
      ?.  =(%chat-brief-update p.cage.sign)  `this
      =/  update  !<([whom:chat brief:briefs:chat] q.cage.sign)
      ?.  ?=(%flag -.-.update)  `this
      ?.  =(p:p:update our.bowl)  `this
      ?:  =(read-id:update ~)  `this
      ::
      =/  post=(pair @da writ:chat)
        %-  head  %~  tap  by
        .^  (map @da writ:chat)
          %gx
          ;:  welp 
            /(scot %p our.bowl)/chat/(scot %da now.bowl)/chat
            /(scot %p p.p.-.update)/[q.p.-.update]/writs/newest/1/noun
          == 
        ==
      ::
      =/  chatmap
        .^  (map flag:chat chat:chat) 
            %gx  
            /(scot %p our.bowl)/chat/(scot %da now.bowl)/chats/noun
        ==
      =/  group  group:perm:(~(got by chatmap) p:update)
      ?.  ?=  %story  
          -.content.q.post  
        `this
      ?.  ?=  [%story [~ [[%link @ @] [%break ~] ~]]]
          content.q.post
        `this
      =/  newurl=@t  p.i.q.p.content.q.post
      ::
      =/  =request:http  [%'GET' newurl ~ ~]
      =/  =task:iris  [%request request *outbound-config:iris]
      =/  iris-card=card:agent:gall  [%pass /http-req/(scot %da now.bowl) %arvo %i task]
      ::
      =/  newlink  :*
                      url=newurl 
                      path=`path:spaces-path`group
                      date=now.bowl 
                      poster=author.q.post
                      likes=0 
                      dislikes=0 
                      liked=%.n
                      disliked=%.n
                      saved=%.n
                      featured=%.n
                      title=newurl
                      image-url=''
                   ==
      :_  this(newsfeed :-(newlink newsfeed))
      :~  iris-card
          :*  %give  %fact  
              ~[/updates/(scot %p ship:path:newlink)/(scot %tas space:path:newlink)]  
              %chronicle-update
              !>(`update:chronicle`new+newlink)
          ==  
      ==
    ==
    ::
      [%spaces-updates ~]
    ?+    -.sign  (on-agent:def wire sign)
        %kick
      :_  this
      :~  [%pass wire %agent [src.bowl %spaces] %watch /spaces]  ==
      ::
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %spaces-reaction
        =/  reaction  !<(reaction:spaces-store q.cage.sign)
        ?+    -.reaction  (on-agent:def wire sign)
            %add
          =/  space-card  
            :*
              %pass  /space/(scot %p ship:path:space:reaction)/(scot %tas space:path:space:reaction)
              %agent  [our.bowl %spaces]
              %watch  /spaces/(scot %p ship:path:space:reaction)/(scot %tas space:path:space:reaction)
            ==
          ?:  =(our.bowl ship:path:space:reaction)
            [~[space-card] this] 
          :_  this
          :~  space-card
            :*
              %pass  /links/(scot %p ship:path:space:reaction)/(scot %tas space:path:space:reaction)
              %agent  [ship:path:space:reaction %chronicle]
              %watch  /updates/(scot %p ship:path:space:reaction)/(scot %tas space:path:space:reaction)
            ==  
          ==
        ==
      ==
    ==
    ::
      [%space @ @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %kick
      :_  this
      :~  [%pass wire %agent [src.bowl %spaces] %watch /spaces/(path-help:hc +6:wire)/(path-help:hc +14:wire)]  ==
      ::
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %visa-reaction
        `this
        ::
          %spaces-reaction
        =/  reaction  !<(reaction:spaces-store q.cage.sign)
        ?+    -.reaction  `this
            %remove
          :-  ~[[%pass wire %agent [our.bowl %spaces] %leave ~]]
          %=  this
            newsfeed  %+  skip  newsfeed
                      |=  =link:chronicle
                      ?:  =(path:link wire)
                        %.y
                      %.n
          ==
        == 
      ==
    ==
    ::
      [%links @ @ ~]
    ?+    -.sign  `this
        %kick
      :_  this
      :~  [%pass wire %agent [src.bowl %chronicle] %watch /spaces/(path-help:hc +6:wire)/(path-help:hc +14:wire)]  ==
      ::
        %fact
      ?+    p.cage.sign  `this
          %chronicle-update
        =/  update  !<(update:chronicle q.cage.sign)
        ?-    -.update
            %new
          `this(newsfeed :-(link:update newsfeed))
          ::
            %edit
          =/  i  (get-index-by-date newsfeed date:update)
          =/  old  ^-  link:chronicle  (snag i newsfeed)
          =/  new  ^-  link:chronicle  link:update
          `this(newsfeed (snap newsfeed i new(saved saved:old)))
        ==
      ==
    ==
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  `this
      ::  Update link with metadata.
      [%http-req @ ~]
    ?+    -.sign-arvo  `this
        %iris
      ?+    +<.sign-arvo  `this
          %http-response
        ?+    -.client-response.sign-arvo  `this
            %finished
          =/  html  (trip `@t`+>+.full-file.client-response.sign-arvo)
          =/  newtitle  (parse-title:hc html)
          =/  newimg  (parse-image:hc html)
          =/  i  (get-index-by-date newsfeed `@da`(slav %da +6:wire))
          =/  old  ^-  link:chronicle  (snag i newsfeed)
          =/  new  
              ^-  link:chronicle  
              %=  old
                title  ?:  =(newtitle '')
                         title:old
                        newtitle
                image-url  ?:  =(newimg '')
                             image-url:old
                           newimg
              ==
          :_  this(newsfeed (snap newsfeed i new))
          :~  :*  
              %give  %fact  ~[/updates/(scot %p ship:path:new)/(scot %tas space:path:new)]
              %chronicle-update 
              !>(`update:chronicle`[%edit date:new new])
          ==  ==
        ==
      ==
    ==
  ==
::
++  on-fail   on-fail:def
--
::
|%
++  parse-title
  |=  html=tape
  ^-  @t
  (parse-html html "og:title\" content=\"")
::
++  parse-image
  |=  html=tape
  ^-  @t
  (parse-html html "og:image\" content=\"")
::
++  parse-html
  |=  [html=tape element=tape]
  ^-  @t
  =/  found  (find element html)
  ?:  =(found ~)
    ''
  =/  snip
    %+  oust
      :-  0
      %+  add 
        +.found
      (lent element)
    html
  =|  title=tape
  |-
  ?:  =(-.snip '"')
    (crip title)
  $(snip +.snip, title (snoc title -.snip))
::
++  get-links-by-space
  |=  [links=(list link:chronicle) =path:spaces-path]
  ^-  (list link:chronicle)
  =/  returns=(list link:chronicle)  ~
  |-
  ?:  =(links ~)
    returns
  ?.  =(+6:-:links path)
    $(links +.links)
  $(links +.links, returns (snoc returns -.links))
::
::  Dates are a unique identifier
++  get-index-by-date
  |=  [links=(list link:chronicle) date=@d]
  ^-  @ud
  =/  i  0
  |-
  ?:  =(+14:-:links date)
    i
  $(links +:links, i +(i))
::
++  path-help
  |=  x=@ta
  x
--