import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="item-value-calculator"
export default class extends Controller {
  static targets = ["price", "quantity", "item_value"];

  connect() {
    this.calculate_value();
  }

  calculate_value() {
    const event = new CustomEvent("item-value-updated");

    const formatter = new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",

      minimumFractionDigits: 2, // (this suffices for whole numbers, but will print 2500.10 as $2,500.1)
      maximumFractionDigits: 2, // (causes 2500.99 to be printed as $2,501)
    });

    const price = parseInt(this.priceTarget.value.replace(/\D/g, "") || 0);
    const quantity = parseInt(this.quantityTarget.value.replace(/\D/g, "") || 0);
    const item_value = price * quantity;
    this.item_valueTarget.textContent = formatter.format(item_value / 100);

    window.dispatchEvent(event);
  }
}
