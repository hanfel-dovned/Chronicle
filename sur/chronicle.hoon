/-  spaces-path
|%
+$  link  [url=@t =path:spaces-path date=@d poster=@p likes=@ud dislikes=@ud liked=? disliked=? saved=? featured=?]
+$  feed  (list link)
+$  action
  $%  [%add =link]
      [%save date=@d]
      [%like date=@d]
      [%dislike date=@d]
      [%feature date=@d]
  ==
+$  update
  $%  [%new =link]
      [%edit date=@d =link]
  ==
--