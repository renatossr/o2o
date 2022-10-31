import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="set-active-link"
export default class extends Controller {
  connect() {
    $('a[href="' + window.location.pathname + '"]')
      .addClass("active")
      .closest("ul")
      .addClass("show");
  }
}
