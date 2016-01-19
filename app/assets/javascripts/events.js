$(document).ready(function(){

  function calculateDuration (argument) {
    var seconds = $("#event_duration_hours").val() * 60 * 60;
    seconds += $("#event_duration_minutes").val() * 60;
    $("#event_duration").val(seconds);
  }

  $("#event_duration_hours option").first().remove();
  calculateDuration();

  $("#event_duration_hours, #event_duration_minutes").on("change", function() {
    calculateDuration();
  });

});

