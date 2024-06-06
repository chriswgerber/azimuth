$0 ~ "function " fncname {
  print "";
  print "## **`" fncname "`**";
  print "";
  getline;
  while ( $0 ~ /#/ ) {
      gsub(/#/, "");
      if ( " " == $0 ) print "";
      else print "| " $0;
      getline;
  }
}
