function hasClass(e,t){return e.className&&(new RegExp("(^|\\s)"+t+"(\\s|$)")).test(e.className)}document.addEventListener("click",function(e){var t=0;var n;for(var r=e.target;r;r=r.parentNode){if(hasClass(r,"dropdown")){u=r.childNodes;for(var i=0;i<u.length;i++){var s=u[i];if(hasClass(s,"dropdown-menu")){var o=s.offsetWidth>0||s.offsetHeight>0;if(!o){s.style.display="block";r.className+=" open";n=r}}}}else if(hasClass(r,"navbar-toggle")){u=document.getElementsByClassName("navbar-collapse");for(var i=0;i<u.length;i++){var s=u[i];if(hasClass(s,"navbar-collapse")){if(hasClass(s,"collapse")){s.className=s.className.replace(" collapse","")}else{s.className+=" collapse"}}}}t++}var u=document.getElementsByClassName("dropdown");for(var i=0;i<u.length;i++){var r=u[i];initerator=r.childNodes;for(var a=0;a<initerator.length;a++){var s=initerator[a];if(hasClass(s,"dropdown-menu")){var o=s.offsetWidth>0||s.offsetHeight>0;if(o&&n!=r){s.style.display="none";r.className=r.className.replace(" open","")}}}}})
function tinyxhr(url,cb,method,post,contenttype){var c=url,a=cb,i=method,f=post,b=contenttype;var d,h;try{h=new XMLHttpRequest()}catch(g){try{h=new ActiveXObject("Msxml2.XMLHTTP")}catch(g){if(console){console.log("tinyxhr: XMLHttpRequest not supported")}return null}}d=setTimeout(function(){h.abort();a(new Error("tinyxhr: aborted by a timeout"),"",h)},10000);h.onreadystatechange=function(){if(h.readyState!=4){return}clearTimeout(d);a(h.status!=200?new Error("tinyxhr: server respnse status is "+h.status):false,h.responseText,h)};h.open(i?i.toUpperCase():"GET",c,true);if(!f){h.send()}else{h.setRequestHeader("Content-type",b?b:"application/x-www-form-urlencoded");h.send(f)}};
function powerOn(hostname)
{
  function callback(err,data,xhr){
    if (err) {
      alert(err)
    } else {
      document.open();
      document.write(data);
      document.close();
    }
  }
  tinyxhr("/vms/"+hostname+"/status",callback,"PUT",'{"power_state":1}',"application/json");
}
function powerOff(hostname)
{
  function callback(err,data,xhr){
    if (err) {
      alert(err)
    } else {
      document.open();
      document.write(data);
      document.close();
    }
  }
  tinyxhr("/vms/"+hostname+"/status",callback,"PUT",'{"power_state":0}',"application/json");
}
function destroy(hostname)
{
  function callback(err,data,xhr){
    if (err) {
      alert(err)
    } else {
      document.open();
      document.write(data);
      document.close();
    }
  }
  tinyxhr("/vms/"+hostname,callback,"DELETE");
}
