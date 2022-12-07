/-  chronicle, spaces-store, visas, membership, spaces-path
/+  default-agent, dbug, server, schooner
/*  chronicle-ui  %html  /app/chronicle-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 active-space=path newsfeed=feed:chronicle]
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
        %connect  `/apps/minesweeper  %minesweeper
    ==
    :*  %pass  /spaces-updates  %agent
        [our.bowl %spaces]  %watch  /spaces
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
        %add
      ?>  =(our.bowl src.bowl)
      ?>  =(our.bowl ship:path:link:action)
      :_  state(newsfeed (snoc newsfeed link:action))
      :~  :*  %give  %fact  
              ~[/updates/(scot %p ship:path:link:action)/(scot %tas space:path:link:action)]  
              %chronicle-update
              !>(`update:chronicle`new+link:action)
      ==  ==
      ::
        %remove
      ?>  =(our.bowl src.bowl)
      ::  ?>  =(our.bowl ship:path:link:action)
      `state
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
        %'GET'
      ?+  site  :_  state 
                %-  send
                :+  404
                  ~ 
                [%plain "404 - Not Found"] 
          [%apps %chronicle ~]
        =/  urltape  (trip url.request.inbound-request)
        =/  query
          ^-  path
          |-
          ?~  urltape  ~
          ?:  =(-.urltape '=')
            (stab (crip +.urltape))
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
    |=  [active=^path fee=feed:chronicle]
    ^-  json
    :-  %a
    :~
      (path active)
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
      ==
    ==
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
    =/  links  (get-link-by-space:hc newsfeed [(slav %p +6:path) +14:path])
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
      [%spaces-updates ~]
    ?+    -.sign  (on-agent:def wire sign)
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
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %visa-reaction
        `this
        ::
          %spaces-reaction
        `this
        ::=/  reaction  !<(reaction:spaces-store q.cage.sign)
        ::?+    -.reaction  `this
        ::    %remove
        ::  :_  this
        ::  ~[[%pass wire %agent [our.bowl %spaces] %leave ~]]
        ::== 
      ==
    ==
    ::
      [%links @ @ ~]
    ?+    -.sign  `this
        %fact
      ?+    p.cage.sign  `this
          %chronicle-update
        =/  update  !<(update:chronicle q.cage.sign)
        ?+    -.update  `this
            %new
          `this(newsfeed (snoc newsfeed link:update))
        ==
      ==
    ==
  ==
::
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::
|%
++  get-link-by-space
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
++  path-help
  |=  x=@ta
  x
--