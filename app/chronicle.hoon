/-  *chronicle
/+  default-agent, dbug, server, schooner
/*  chronicle-ui  %html  /app/chronicle-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 newsfeed=feed]
+$  card  card:agent:gall
-- 
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %.n) bowl)
    hc    ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  :_  %=  this
        newsfeed  
        :~  ['http://google.com' 'warpzone' ~2022.8.30..20.47.00..6d02 ~zod 1 1 %.n %.n %.n %.y]
            ['http://facebook.com' 'warpzone' ~2021.7.30..20.47.00..6d91 ~bus 10 2 %.n %.n %.n %.y] 
            ['http://bebo.com' 'temple' ~2021.2.30..20.47.00..6dff ~bus 10 3 %.n %.n %.n %.n]
            ['http://myspace.com' 'temple' ~2021.4.30..20.47.00..7d01 ~bus 12 0 %.n %.n %.n %.n]
        ==
      ==
  :~
    :*  %pass  /eyre/connect  %arvo  %e 
        %connect  `/apps/chronicle  %chronicle
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
      %handle-http-request
    =^  cards  state
      (handle-http !<([@ta =inbound-request:eyre] vase))
    [cards this]
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
        :_  state
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
        [%json (enjs-state newsfeed)]
      ==
    ==
  ::              
  ++  enjs-state
    =,  enjs:format
    |=  fee=feed
    ^-  json
    :-  %a
    %+  turn
      fee
    |=  lin=link
    :-  %a
    :~
      [%s url:lin]
      [%s group:lin]
      [%s (scot %da date:lin)]
      [%s (scot %p poster:lin)]
      [%n (scot %ud likes:lin)]
      [%n (scot %ud dislikes:lin)]
      [%b liked:lin]
      [%b disliked:lin]
      [%b saved:lin]
      [%b featured:lin]
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%http-response *]
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--