//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets

$(document).on('click', 'a[href^="#"]', function(e) {
  var id = $($(this).attr('href'));
  if (id.size() === 0) return;
  e.preventDefault();
  $('body, html').animate({scrollTop: id.offset().top}, 800);
});

window.setTimeout(function() { $(".alert").alert('close'); }, 8000);
