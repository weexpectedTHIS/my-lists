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
