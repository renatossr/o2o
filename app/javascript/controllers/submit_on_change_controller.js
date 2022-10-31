import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="submit-on-change"
export default class extends Controller {
  static targets = ["form_to_submit", "submit_trigger"];

  connect() {
    const form = this.form_to_submitTarget;
    $(".js-s2-select").on("select2:select", function (e) {
      form.submit();
    });
  }

  trigger_form_submit() {
    console.log("triggered");
    this.form_to_submitTarget.submit();
  }
}
