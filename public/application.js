$(document).ready(function() {

  $(document).on('click', '#hit_form button', function() {
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', '#stay_form button', function() {
    $.ajax({
      type: 'POST',
      url: '/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', '#dealer_hit button', function() {
    $.ajax({
      type: 'POST',
      url: '/dealer_hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', '#double_down button', function() {
    $.ajax({
      type: 'POST',
      url: '/double_down'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

});

//Notes from class on how to do a few other things, please disregard

	// $('#demo_link').click(function() {
 //    alert('hi!');
 //    $('.table_surface').css('background-color', 'yellow');
 //    return false;
 //  });
  //$('#hit_form button').click(function() {
    //alert('hit_button clicked');
    //return false;
  //});
  // $.ajax({
  //   type: 'POST',
  //   url: '/hit'
  //   //data {}
  // }).done(function(msg) {
  //   alert(msg);
  // });
