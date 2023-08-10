setTimeout(function() {
    var flashMessage = document.getElementById('flash-message');
    if (flashMessage) {
      flashMessage.remove();
    }
  }, 5000);

// Place this JavaScript code in a <script> tag or a separate JavaScript file

// Create a function to update the history list using AJAX response
function updateHistoryList() {
  $.ajax({
    url: '/search_histories',
    type: 'GET',
    dataType: 'json', // Expect JSON response
    success: function(response) {
      $('#history-container').empty(); // Clear existing history
      
      response.forEach(function(history) {
        var historyHtml = `
          <ul>
            <span style="color: red"><li>Town: ${history.town}</li></span>
            <li>Temperature: ${history.temperature} ℃</li>
            <li>Description: ${history.description}</li>
            <li>Postal Code: ${history.postal_code}</li>
          </ul>
        `;
        $('#history-container').append(historyHtml);
      });      
    }
  });
}

// Run the function on form submit and AJAX callback
$('#forecast-form').on('submit', function(event) {  
  // Your form submission logic here
  // ...

  // Delay the updateHistoryList() function by 3 seconds
  setTimeout(function() {
    updateHistoryList();
  }, 2000); // 3000 milliseconds = 3 seconds
});

// In your AJAX callbacks
// ...
// Call the function to update the history list
updateHistoryList();