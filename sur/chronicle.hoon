/-  spaces-path
|%
+$  link  [url=@t =path:spaces-path date=@d poster=@p likes=@ud dislikes=@ud liked=? disliked=? saved=? featured=?]
+$  feed  (list link)
+$  action
  $%  [%add =link]
      [%remove date=@d]
  ==
+$  update
  $%  [%new =link]
      [%update date=@d =link]
  ==
--