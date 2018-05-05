\d .qhttp
hget:{[Host;Path;Headers;QueryParams]
  hd: Headers, (!) . flip ((`Connection;("close";Headers[`Connection])`Connection in key Headers);(`Host;Host));
  header: ("\r\n" sv enlist["HTTP/1.1"],{if[10 <> abs type[y];y:string y]; string[x],": ",trim[y]}'[key hd;value hd]),"\r\n\r\n";
  query: "&" sv {string[x],"=",y}'[key QueryParams;value QueryParams];
  methodstr: ("GET " , (Path;"/")""~Path),"?",query," ",header;
  /show methodstr;
  (`$":http://",Host)methodstr
 };

hpost:{[Host;Path;Headers;ContentType;Body]
  hd: Headers, (!) . flip ((`Connection;("active";Headers[`Connection])`Connection in key Headers);(`host;Host);
                          (`$"content-type";ContentType);(`$"content-length";count Body));
  header: "\r\n" sv enlist["HTTP/1.1"],{if[10 <> abs type[y];y:string y]; string[x],": ",trim[y]}'[key hd;value hd];
  methodstr: ("POST " , (Path;"/")""~Path)," ","\r\n" sv (header;"";Body);
  res:(`$":https://",Host)methodstr;
  parse_return res
 };

parse_return:{[Result]
  ret:"\r\n" vs Result;
  status:" " vs ret 0;
  `version`status`message`headers`body!(status 0;status 1;status 2;parse_return_headers ret;last ret)
 };

parse_return_headers:{[ParsedResult]
  (!) . flip {trim(0;1)_'cut[0,first where ":"=x;x]} each 1_-2_ParsedResult
 };

\d .

//TEST
test_post:{.http.hpost["localhost:4444";"/europa_facts/v1/1";`Connection`Name!("active";"rahul");"application/json";.j.j"test"]};
test_get:{
  incidentid:"a513ff308968836e20584802c2f85293f029abd71e32e4a017f4799b185a1600b2ecca6bc18175c33663f0f46da93897";
  obsid:"f922e8a422d111e897ba186590dd96f7,fa075e9422d111e8a49b186590dd96f7";
  .http.hget["localhost:4444";"/europa_facts/v1/1";`Connection`Name!("active";"rahul");`incident_id`observable_id!(incidentid;obsid)]
 };
/show test_get[];
/exit 0;
// CORRECT REQUEST FORMAT
/  a:"POST /europa_facts/v1/1 HTTP/1.1\r\nConnection: close\r\nHost: localhost:4444\r\nContent-type: application/json\r\n
/  Content-length:13 \r\n\r\n{\"q\":1,\    "w\":2}"
/  (`$":http://localhost:4444") a
