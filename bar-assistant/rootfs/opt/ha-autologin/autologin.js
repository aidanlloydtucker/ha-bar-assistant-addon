// Signs in through Salt Rim's SSO callback with a token from /ha-autologin
// whenever the browser has no Bar Assistant token yet.
(function () {
    var hasToken = [localStorage, sessionStorage].some(function (storage) {
        try {
            return Boolean(JSON.parse(storage.getItem("_salt_rim") || "{}").token);
        } catch (e) {
            return false;
        }
    });

    if (hasToken || location.pathname === "/oauth/callback") {
        return;
    }

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
})();
