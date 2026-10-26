// Signs in through Salt Rim's SSO callback with a token from /ha-autologin
// whenever the browser has no working Bar Assistant token.
(function () {
    if (location.pathname === "/oauth/callback") {
        return;
    }

    function autologin() {
        fetch("/ha-autologin", { method: "POST" })
            .then(function (response) {
                return response.ok ? response.json() : null;
            })
            .then(function (data) {
                if (data && data.token) {
                    sessionStorage.setItem("sr_sso_provider", "homeassistant");
                    location.replace("/oauth/callback?code=" + encodeURIComponent(data.token));
                }
            })
            .catch(function () {});
    }

    var token = null;
    [localStorage, sessionStorage].forEach(function (storage) {
        try {
            token = token || JSON.parse(storage.getItem("_salt_rim") || "{}").token;
        } catch (e) {}
    });

    if (!token) {
        autologin();
        return;
    }

    // A token from an expired session or a wiped database is rejected; replace it.
    fetch(window.srConfig.API_URL + "/api/profile", {
        headers: { Accept: "application/json", Authorization: "Bearer " + token },
    })
        .then(function (response) {
            if (response.status === 401) {
                autologin();
            }
        })
        .catch(function () {});
})();
