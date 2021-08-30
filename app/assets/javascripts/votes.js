$(document).on('turbolinks:load', function() {
  $('p.votes').on('ajax:success', function(e) {
    $(this).find('.result').html(e.detail[0].votes);
  });
});
