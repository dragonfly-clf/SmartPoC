##### Function buyBBITokens can be used to get free tokens

###### (https://blog.coinfabrik.com/)

When using this contract you are supposed to call the fallback function in order to buy tokens:

```
function () payable onIcoRunning public {
buyBBITokens(msg.sender, msg.value);   
}

```

But you may bypass this function and directly call buyBBITokens:

This website uses cookies to improve your web experience. Accept