import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  initialize() {
    // This method is triggered when the Bootstrap modal is loaded
    // You can perform any initialization or setup here
  }

  openModal({ params: { url } }) {
    // Open the Bootstrap modal
    new bootstrap.Modal("#summaryModal").show();
    const modalContentElement = document.getElementById('modal-content');

    // Fetch the data remotely
    fetch(url)
      .then((response) => response.text())
      .then((html) => {
        // Update the modal content with the fetched data
        modalContentElement.innerHTML = html;

        $("#summaryModal .spinner-border").hide();
      });
  }

}
