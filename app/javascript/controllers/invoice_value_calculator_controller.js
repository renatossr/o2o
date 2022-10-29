import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="invoice-value-calculator"
export default class extends Controller {
  static targets = ["item_value", "total_value", "discount_value", "final_value"];

  connect() {}

  calculate_value() {
    const formatter = new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",

      minimumFractionDigits: 2, // (this suffices for whole numbers, but will print 2500.10 as $2,500.1)
      maximumFractionDigits: 2, // (causes 2500.99 to be printed as $2,501)
    });

    let total_value = 0;
    this.item_valueTargets.forEach((element) => {
      total_value += parseInt(element.textContent.replace(/\D/g, "")) || 0;
    });
    this.total_valueTarget.textContent = formatter.format(total_value / 100);
    const discount_value = parseInt(this.discount_valueTarget.value.replace(/\D/g, "")) || 0;
    const final_value = total_value - discount_value;
    this.final_valueTarget.textContent = formatter.format(final_value / 100);
  }
}
