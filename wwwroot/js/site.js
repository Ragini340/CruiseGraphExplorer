document.addEventListener("DOMContentLoaded", function () {

    const routeForm = document.querySelector(".route-form");

    if (routeForm) {

        routeForm.addEventListener("submit", function () {

            const button =
                routeForm.querySelector("button[type='submit']");

            if (button) {

                button.disabled = true;

                button.innerText = "Finding Routes...";

            }

        });
    }

});