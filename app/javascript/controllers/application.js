import { Application } from "@hotwired/stimulus";
import NestedForm from "stimulus-rails-nested-form";

const application = Application.start();
application.register("nested-form", NestedForm);

document.addEventListener("turbo:before-cache", () => {
  application.controllers.forEach((controller) => {
    if (typeof controller.teardown === "function") {
      controller.teardown();
    }
  });
});

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
