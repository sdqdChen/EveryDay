window.onload = function(){
//    alert(0);
    var all = document.getElementById("all");
    all.onclick = function(){
//        alert(0);
//        window.location.href = 'http://www.baidu.com';
        window.location.href = "cx:clickWebView";
    }
}
var beforeScrollTop = document.body.scrollTop;
window.onscroll = function () {
    var afterScrollTop = document.body.scrollTop;
    // console.log(beforeScrollTop, afterScrollTop);
    var delta = afterScrollTop - beforeScrollTop;
    if (delta > 0) {
        window.location.href = "down:scrollDown";
    } else {
        window.location.href = "up:scrollUp";
    }
    beforeScrollTop = afterScrollTop;
}
