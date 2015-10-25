// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require bootstrap
//= require autonumeric-min
//= require underscore-min
//= require_tree .

$(function(){
  $.datepicker.setDefaults({dateFormat: 'dd/mm/yy'})
  $(".datepicker").datepicker()
  $('.currency').each(function(){
    var options = {
      aSep: '.',
      aDec: ','
    }
    var min = 0 // $(this).data('min-value') // https://github.com/BobKnothe/autoNumeric/issues/169
    var max = $(this).data('max-value')
    if (max){
      options['vMax'] = max
    }
    options['vMin'] = min
    $(this).autoNumeric('init', options)
  })
  $('.currency').keyup(function(){
    var parent = $(this).closest('.form-group')
    var cents = parent.find('.cents')
    var val = Number($(this).autoNumeric('get')) * 100
    cents.val(val)
    $(this).trigger('cents_field_updated')
  })
  $('.has-error :input').click(function(){
    $('.has-error').removeClass('has-error')
  })
  $('.noinput').
    keydown(function(e) { e.preventDefault() } ).
    bind("paste", function(e) { e.preventDefault() } ).
    focus(function(){ $(this).blur() })
  $('[data-toggle="popover"]').popover({trigger: 'hover click', placement: 'bottom'})
})

var set_flash_messages = function(response){
  var content = response ? response.responseJSON['flash_content'] : ""
  $('#all-flash-messages').html(content)
}
