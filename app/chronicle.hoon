/-  *chronicle
/+  default-agent, dbug, server, schooner
/*  chronicle-ui  %html  /app/chronicle-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 =newsfeed]
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
    hc    ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  :_  this(newsfeed ~['hello' 'world' 'these' 'are' 'links'])
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
    ::      [%apps %chroncile %state ~]
    ::    :_  state
    ::    %-  send
    ::    :+  200   
    ::      ~ 
    ::    [%json (enjs-state [settings game-state gameboard])]
      ==
    ==
  ::              
  ++  enjs-state
    =,  enjs:format
    |=  $:  
            settings=[width=@ud height=@ud mines=@ud]
            game-state=[reveals=@ud win=? lose=?]
            grid=(list [revealed=? flagged=? mine=? neighbors=@ud])
        ==
    ^-  json
    :-  %a
    :~ 
      (numb width:settings)
      (numb height:settings)
      (numb mines:settings)
      (numb reveals:game-state)
      [%b win:game-state]
      [%b lose:game-state]
      :-  %a
      %+  turn
        grid
      |=  tile=[revealed=? flagged=? mine=? neighbors=@ud]
      :-  %a
      :~
          [%b revealed:tile]
          [%b flagged:tile]
          [%b mine:tile]
          (numb neighbors:tile)
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
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--