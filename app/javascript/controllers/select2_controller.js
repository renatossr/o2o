import { Controller } from "@hotwired/stimulus";

import $ from "jquery";
import select2 from "select2";

export default class extends Controller {
  connect() {
    select2($);

    $(".js-s2-select").select2({
      theme: "bootstrap-5",
      selectionCssClass: "select2--small",
      dropdownCssClass: "select2--small",
      width: $(this).data("width") ? $(this).data("width") : $(this).hasClass("w-100") ? "100%" : "style",
    });

    $(".is-valid").removeClass("is-valid");
  }
}
