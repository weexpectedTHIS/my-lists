var Util = {
  draw_header: function(ctx, opts) {
    ctx.beginPath();
    ctx.moveTo(0, opts['header_height']);
    ctx.lineTo(0, opts['corner_radius']);
    ctx.arcTo(0, 0, opts['corner_radius'], 0, opts['corner_radius']);
    ctx.lineTo(opts['canvas_width'] - opts['corner_radius'], 0);
    ctx.arcTo(opts['canvas_width'], 0, opts['canvas_width'], opts['corner_radius'], opts['corner_radius']);
    ctx.lineTo(opts['canvas_width'], opts['header_height']);
    ctx.lineTo(0, opts['header_height']);
    ctx.fillStyle = opts['header_color'];
    ctx.fill();
  },
  draw_header_text: function(ctx, opts) {
    ctx.textAlign = 'center';
    ctx.font = opts['header_text_font'];
    ctx.fillStyle = opts['header_text_color'];
    ctx.fillText(opts['header_text'], opts['canvas_width']/2, opts['header_text_top']);
  },
  draw_body: function(ctx, opts) {
    ctx.beginPath();
    ctx.moveTo(0, opts['header_height']);
    ctx.lineTo(opts['canvas_width'], opts['header_height']);
    ctx.lineTo(opts['canvas_width'], opts['canvas_height'] - opts['corner_radius']);
    ctx.arcTo(opts['canvas_width'], opts['canvas_height'], opts['canvas_width'] - opts['corner_radius'], opts['canvas_height'], opts['corner_radius']);
    ctx.lineTo(opts['corner_radius'], opts['canvas_height']);
    ctx.arcTo(0, opts['canvas_height'], 0, opts['canvas_height'] - opts['corner_radius'], opts['corner_radius']);
    ctx.lineTo(0, opts['header_height']);
    ctx.fillStyle = opts['body_color'];
    ctx.fill();
  },
  draw_star: function(ctx, opts) {
    var length = (opts['canvas_height'] - opts['header_height']) / 2;
    ctx.beginPath();
    ctx.translate(opts['header_height'] / 2, opts['header_height']);
    ctx.fillStyle = opts['primary_shape_color'];
    ctx.moveTo(length, 0);
    ctx.lineTo(length * 4/3, length * 2/3);
    ctx.lineTo(length * 2, length);
    ctx.lineTo(length * 4/3, length * 4/3);
    ctx.lineTo(length, length * 2);
    ctx.lineTo(length * 2/3, length * 4/3);
    ctx.lineTo(0, length);
    ctx.lineTo(length * 2/3, length * 2/3);
    ctx.lineTo(length, 0);
    ctx.fill();
    ctx.translate(-1 * opts['header_height'] / 2, -1 * opts['header_height']);
  },
  draw_circle: function(ctx, opts) {
    ctx.beginPath();
    ctx.fillStyle = opts['secondary_shape_color'];
    ctx.arc(opts['canvas_width'] / 2, opts['header_height'] + (opts['canvas_height'] - opts['header_height']) / 2, opts['canvas_width'] / 4, 0, 2 * Math.PI, false);
    ctx.fill();
  },
  colors: function() {
    return ['#556270', '#4ecdc4', '#ff6b6b', '#c44d58', 'purple', 'red', 'gray'];
  },
  random_elem: function(arr) {
    return arr.splice(Math.floor(Math.random() * arr.length), 1)[0];
  },
  draw_icon: function(text, options) {
    if (!options) options = {};
    var colors = Util.colors();
    var opts = {
      canvas_height: 57,
      canvas_width: 57,
      corner_radius: 6,
      header_height: 8,
      header_text: '',
      header_color: '#c7f464',
      header_text_font: 'bold 11px arial',
      header_text_color: Util.random_elem(colors),
      header_text_top: 12,
      body_color: Util.random_elem(colors),
      primary_shape_color: Util.random_elem(colors),
      secondary_shape_color: Util.random_elem(colors),
      body_text_font: 'bold 38px arial',
      body_text_color: Util.random_elem(colors),
      body_text_top: 46
    }
    $.extend(opts, options);
    opts['body_height'] = opts['canvas_height'] - opts['header_height'];

    var canvas = document.createElement('canvas');
    canvas.height = opts['canvas_height'];
    canvas.width = opts['canvas_width'];
    ctx = canvas.getContext('2d');
    // HEADER
    Util.draw_header(ctx, opts);
    // HEADER TEXT
    if (opts['header_text'].length) {
      Util.draw_header_text(ctx, opts);
    }
    // BODY
    Util.draw_body(ctx, opts);
    // STAR
    Util.draw_star(ctx, opts);
    // CIRCLE
    Util.draw_circle(ctx, opts);

    return canvas.toDataURL('image/png');
  },
  draw_favicon: function(text) {
    var opts = {
      canvas_height: 16,
      canvas_width: 16,
      corner_radius: 4,
      header_height: 4,
      header_color: '#888888',
      body_color: '#CCCCCC',
      body_text_font: '8px "helvetica", sans-serif',
      body_text_color: '#111111',
      body_text_top: 12
    }

    var canvas = document.createElement('canvas');
    canvas.height = opts['canvas_height'];
    canvas.width = opts['canvas_width'];
    ctx = canvas.getContext('2d');
    // HEADER
    Util.draw_header(ctx, opts);
    // BODY
    Util.draw_body(ctx, opts);
    // BODY TEXT
    ctx.textAlign = 'center';
    ctx.font = opts['body_text_font'];
    ctx.fillStyle = opts['body_text_color'];
    ctx.fillText(text, opts['canvas_width']/2, opts['body_text_top'], opts['canvas_width']);

    return canvas.toDataURL('image/png');
  },
  add_favicon: function(text) {
    data_url = Util.draw_favicon(text);
    var link = $('<link />');
    link.attr({'rel': 'icon', 'type': 'image/png', 'href': data_url});
    $('head').prepend(link);
  },
  download_icons: function() {
    var zip = new JSZip();
    var alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var i = 0; i < alphabet.length; i++) {
      for (var j = 0; j < alphabet.length; j++) {
        var name = alphabet.charAt(i) + alphabet.charAt(j);
        zip.file(name.toLowerCase() + '.png', Util.draw_icon(name).replace(/^data:image\/(png|jpg);base64,/, ""), {base64: true});
      }
    }
    var content = zip.generate();
    window.location.href = "data:application/zip;base64,"+content;
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
    $('.link_item_finish').click(function(){
      $(this).next().show();
      $(this).hide();
    });
    $('.link_item_unfinish').click(function(){
      $(this).next().show();
      $(this).hide();
    });
    $('.link_item_destroy').click(function(){
      $(this).next().show();
      $(this).hide();
    });
    $('.form_item_renotate').validate();
  }
});
