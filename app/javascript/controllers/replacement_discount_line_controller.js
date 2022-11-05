import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="replacement-discount-line"
export default class extends Controller {
  static targets = [
    "billing_type",
    "description",
    "price",
    "price_per_class",
    "quantity",
    "replacements",
    "remaining_replacements",
    "max_replacements",
  ];

  connect() {}

  fill() {
    this.descriptionTargets.at(-1).value = "Desconto adicional Reposições";
    this.priceTargets.at(-1).value = -this.price_per_classTarget.value;
    this.quantityTargets.at(-1).value = this.replacementsTarget.value;
    this.billing_typeTargets.at(-1).value = "replacement";

    this.remaining_replacementsTarget.value = Math.max(
      this.remaining_replacementsTarget.value - this.replacementsTarget.value,
      0
    );
    this.replacementsTarget.value = this.remaining_replacementsTarget.value;

    setTimeout(() => {
      document.querySelector("#" + this.quantityTargets.at(-1).id).dispatchEvent(new Event("input", { bubbles: true }));
    }, 100);
  }
}
