window.onload = function(){
    var all = document.getElementById("all");
    all.onclick = function(){
        window.location.href = "cx:clickWebView";
    }
}
var beforeScrollTop = document.body.scrollTop;
window.onscroll = function () {
    var afterScrollTop = document.body.scrollTop;
    var delta = afterScrollTop - beforeScrollTop;
    if (delta > 0) {
        window.location.href = "down:scrollDown";
    } else {
        window.location.href = "up:scrollUp";
    }
    beforeScrollTop = afterScrollTop;
}
