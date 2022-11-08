import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="set-active-link"
export default class extends Controller {
  connect() {
    this.element.querySelector('a[href="' + window.location.pathname + '"]').classList.add("active");
    this.element
      .querySelector('a[href="' + window.location.pathname + '"]')
      .closest("ul")
      .classList.add("show");
  }
}
