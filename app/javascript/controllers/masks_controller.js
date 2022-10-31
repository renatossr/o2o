window.$ = window.jQuery = require("jquery");
require("jquery-mask-plugin");
require("inputmask/dist/jquery.inputmask");

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.maskFields();
  }

  maskFields() {
    $('[data-masks-target="phone"]').mask("(00) 00000-0009");
    $('[data-masks-target="cpf"]').mask("000.000.000-00");

    $('[data-masks-target="money"]').mask("#.###,##", {
      reverse: true,
      translation: {
        "#": {
          pattern: /-|\d/,
          recursive: true,
        },
      },
      onChange: function (value, e) {
        if (value) {
          e.target.value = value
            .replace(/(?!^)-/g, "")
            .replace(/^\./, "")
            .replace(/^-\./, "-");
        }
      },
    });

    // Clean up negative values with loose '.'
    $('[data-masks-target="money"]').each(function () {
      if (this.value) {
        this.value = this.value
          .replace(/(?!^)-/g, "")
          .replace(/^\./, "")
          .replace(/^-\./, "-");
      }
    });
  }
}
