var Util = {
  add_favicon: function(text) {
    var canvas = document.createElement('canvas');
    canvas.height = canvas.width = 16;
    ctx = canvas.getContext('2d');
    // HEADER
    ctx.beginPath();
    ctx.moveTo(0, 4);
    ctx.arcTo(0, 0, 4, 0, 4);
    ctx.lineTo(12, 0);
    ctx.arcTo(16, 0, 16, 4, 4);
    ctx.lineTo(0, 4);
    ctx.fillStyle = '#888888';
    ctx.fill();
    // BODY
    ctx.beginPath();
    ctx.moveTo(0, 4);
    ctx.lineTo(16, 4);
    ctx.lineTo(16, 12);
    ctx.arcTo(16, 16, 12, 16, 4);
    ctx.lineTo(4, 16);
    ctx.arcTo(0, 16, 0, 12, 4);
    ctx.lineTo(0, 4);
    ctx.fillStyle = '#CCCCCC';
    ctx.fill();
    // TEXT
    ctx.font = '12px "helvetica", sans-serif';
    ctx.fillStyle = '#111111';
    ctx.fillText(text, 1, 14, 14);
    var link = $('<link />');
    link.attr({'rel': 'icon', 'type': 'image/png', 'href': canvas.toDataURL('image/png')});
    $('head').prepend(link);
  }
};

$(document).ready(function(){
  $.validator.addMethod(
    'regex',
    function(value, element, regexp) {
      return this.optional(element) || regexp.test(value);
    },
    'Please check your input.'
  );

  // GLOBAL PREVENTION OF HREF PROPOGATION FOR JS LINKS
  $('a[href^=#], a[data-remote=true]').click(function(e){ e.preventDefault(); });

  // HOME
  if ($('#list_new_form').length > 0) {
    $('#list_new_link').click(function(){
      $('#list_new_form').show().find('input:first-child').focus();
      $(this).hide();
    });
    $('#list_new_form').validate();
    $('#form_list_name').rules('add', { required: true, regex: /^[a-zA-Z0-9_]{1}[a-zA-Z0-9_\s]{2,48}[a-zA-Z0-9_]{1}$/ });

    $('.link_list_edit').click(function(){
      $(this).next().show().find('input:first-child').focus();
      $(this).hide();
    });
    $('.link_list_prioritize').click(function(){
      $(this).next().show().find('select:first-child').focus();
      $(this).hide();
    });
    $('.link_list_rename').click(function(){
      $(this).next().show().find('input:first-child').focus();
      $(this).hide();
    });
    $('.link_list_destroy').click(function(){
      $(this).next().show();
      $(this).hide();
    });
    $('.form_list_rename').validate();
    $('.form_list_rename input[type="text"]').rules('add', { required: true, regex: /^[a-zA-Z0-9_]{1}[a-zA-Z0-9_\s]{2,48}[a-zA-Z0-9_]{1}$/ });
  }


  // LIST
  if ($('#item_new_form').length > 0) {
    $('#item_new_link').click(function(){
      $(this).next().show().find('textarea:first-child').focus();
      $(this).hide();
    });
    $('#item_new_form').validate();

    $('.link_item_edit').click(function(){
      $(this).next().show().find('input:first-child').focus();
      $(this).hide();
    });
    $('.link_item_prioritize').click(function(){
      $(this).next().show().find('select:first-child').focus();
      $(this).hide();
    });
    $('.link_item_renotate').click(function(){
      $(this).next().show().find('textarea:first-child').focus();
      $(this).hide();
    });
    $('.link_item_destroy').click(function(){
      $(this).next().show();
      $(this).hide();
    });
    $('.form_item_renotate').validate();
  }
});
