import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="set-active-link"
export default class extends Controller {
  connect() {
    const link_element = this.element.querySelector('a[href="' + window.location.pathname + '"]');
    if (link_element != null) {
      link_element.classList.add("active");
      let ul_element = link_element.closest("ul.collapse");
      if (ul_element != null) {
        ul_element.classList.add("show");
        ul_element = null;
      }
      link_element.setAttribute("href", "javascript:void(0)");
    }
  }
}
