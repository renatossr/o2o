import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="set-active-link"
export default class extends Controller {
  connect() {
    this.element.querySelector('a[href="' + window.location.pathname + '"]').classList.add("active");
    let el = this.element.querySelector('a[href="' + window.location.pathname + '"]').closest("ul.collapse");
    if (el != null) {
      el.classList.add("show");
      el = null;
    }
  }
}
