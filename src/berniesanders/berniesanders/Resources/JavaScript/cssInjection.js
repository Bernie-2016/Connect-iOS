var styleNode = document.createElement('style');
styleNode.type = "text/css";
var styleText = document.createTextNode('CSS_SENTINEL');
styleNode.appendChild(styleText);
document.getElementsByTagName('head')[0].appendChild(styleNode);
