\d .qhttp
/ --------------------
/ PUBLIC API
/ --------------------
/ HTTP GET
/ @param Sec (Boolean) Secure flag => 0 use http, 1 use https
/ @param Host (String) Host name
/ @param Path (String) URI Path
/ @param Header (Dict) Headers dictionary => Keys should be Symbol. Values could be anything.
/ @param QueryParams (Dict) query parameters => Keys should be Symbol. Values should be String.
/ @return (Dict) Dictionary => check output of parse_return function
hget:{[Sec;Host;Path;Headers;QueryParams] hget_req[Sec;"GET";Host;Path;Headers;QueryParams]};

/ HTTP HEAD
/ Params same as hget
hhead:{[Sec;Host;Path;Headers;QueryParams] hget_req[Sec;"HEAD";Host;Path;Headers;QueryParams]};

/ HTTP POST
/ @param Sec (Boolean) Secure flag => 0 use http, 1 use https
/ @param Host (String) Host name
/ @param Path (String) URI Path
/ @param Header (Dict) Headers dictionary => Keys should be Symbol. Values could be anything.
/ @param ContentType (String) content type or "" for default
/ @param Body (String) Body
/ @return (Dict) Dictionary => check output of parse_return function
hpost:{[Sec;Host;Path;Headers;ContentType;Body] hpost_req[Sec;"POST";Host;Path;Headers;ContentType;Body] };

/ HTTP PUT
/ Params same as hpost
hput:{[Sec;Host;Path;Headers;ContentType;Body] hpost_req[Sec;"PUT";Host;Path;Headers;ContentType;Body] };

/ HTTP DELETE
/ Params same as hpost
hdelete:{[Sec;Host;Path;Headers;ContentType;Body] hpost_req[Sec;"DELETE";Host;Path;Headers;ContentType;Body] };

/ --------------------
/ INTERNAL FUNCTIONS
/ --------------------
/ GET reuest helper function
/ @param Method (String) GET | HEAD
/ Rest params are same as hget function
hget_req:{[Sec;Method;Host;Path;Headers;QueryParams]
  protocol:("http";"https") Sec;
  method:Method," ";
  hd:Headers;
  if[not any `host`Host in key Headers;hd[`Host]:Host]; / add only if no host present in header
  hd[`Connection]:("close";Headers[`Connection])`Connection in key Headers;
  header: ("\r\n" sv enlist["HTTP/1.1"],{if[10 <> abs type[y];y:string y]; string[x],": ",trim[y]}'[key hd;value hd]),"\r\n\r\n";
  query: "&" sv {string[x],"=",y}'[key QueryParams;value QueryParams];
  methodstr: (method , (Path;"/")""~Path);
  if[0<count query;methodstr:methodstr,"?",query];
  methodstr:methodstr," ",header;
  show methodstr;
  res:(`$":",protocol,"://",Host)methodstr;
  parse_return res
 };

/ POST request helper function
/ @param Method (String) POST|PUT|DELETE
/ Rest params are same as hpost function
hpost_req:{[Sec;Method;Host;Path;Headers;ContentType;Body]
  method: Method, " ";
  protocol:("http";"https") Sec;
  hd: (!) . flip ((`Connection;("active";Headers[`Connection])`Connection in key Headers); (`host;Host);
                          (`$"content-type";ContentType);(`$"content-length";count Body));
  hd:hd, Headers;
  header: "\r\n" sv enlist["HTTP/1.1"],{if[10 <> abs type[y];y:string y]; string[x],": ",trim[y]}'[key hd;value hd];
  methodstr: (method , (Path;"/")""~Path)," ","\r\n" sv (header;"";Body);
  show methodstr;
  res:(`$":",protocol,"://",Host)methodstr;
  parse_return res
 };

/ Parses the http request return
/ @params Result (String) HTTP request return
/ @return (Dict)
parse_return:{[Result]
  ret:"\r\n" vs Result;
  status:" " vs ret 0;
  `version`status_code`message`headers`body!(status 0;status 1;status 2;parse_return_headers ret;last ret)
 };

/ Parses the http request result headers
/ @param ParsedResult (List) String List
/ @return (Dict) http result headers dict
parse_return_headers:{[ParsedResult]
  (!) . flip {trim(0;1)_'cut[0,first where ":"=x;x]} each 1_-2_ParsedResult
 };

\d .
