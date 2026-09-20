function clip() {
    const public_key = "pub_82qkpMKV77AkpqLSgWsxLlDyfzpPI7Vw";
    
    const raw = JSON.stringify({
        "eventId": "1",
        "eventName": "Test",
        "triggerActions": [
            "SaveClip"
        ],
        "clipOptions": {
            "duration": 10,
            "captureDelayMs": 10000
        }
    });

    const options = {
        method: "POST",
        headers: {
            "publicKey": public_key,
            "Content-Type": "application/json"
        },
        body: raw,
        redirect: "follow"
    }

    fetch("http://localhost:12665/api/v1/event/invoke", options).then(response => response.text()).then(result => console.log(result)).catch(error => console.log("error", error));
}

window.addEventListener("message", (event) => {
    if(event.data.action === "medal_auto_clip") {
        clip();
    }
});