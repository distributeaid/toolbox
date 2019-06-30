/* Ferry: The Distribute Aid software service.
 * Copyright (C) 2018 - J. Taylor Fairbank (taylor@distributeaid.org)
 *
 * Licensed under the AGPLv3. See `/LICENSE.md`.
 */

$(document).ready(function() {

  /*
  Initialize Kube
  ------------------------------------------------------------
  */
  $K.init({
    observer: true
  });

  /*
  Initialize Select2
  Select2 Documentation: https://select2.org/
  ------------------------------------------------------------
  */
  $('.select').select2({
    closeOnSelect: false
  });

 // ensure the select is initialized and blank 
  $category = $('.select-and-input-cat').select2({tags: true,}).val(null).trigger('change');
  $item = $('.select-and-input-item').select2({tags: true,}).val(null).trigger('change');

  $category.on("select2:close", function(data){checkInputOffFocus(data, $category)});
  $item.on("select2:close", function(data){checkInputOffFocus(data, $item)});


function checkInputOffFocus(data, $input){
  var options = data.target.options;
  var test = options[options.length - 1];

  if(data.params.originalSelect2Event === undefined){
    var check = true;
    for(var i = 0; i < options.length; i++){
      if(options[i].label === test.label){
        $input.val(options[i].label).trigger('change');
        check = false;
        break;
      }
    }
    if(check){
      var newOption = new Option(data.target.lastChild.label, data.target.lastChild.label, true, true);
      $input.append(newOption).trigger('change');
    }
  }
}



  /*
  Initialize Datatables
  ------------------------------------------------------------
  */
  $('#group-stock-table').DataTable({
    info: false,
    paging: false,
    language: {
      emptyTable: "No results found.  Try modifying your filters or adding a missing entry?"
    }
  });

  $('#inventory-list').DataTable({
    info: false,
    paging: false,
    language: {
      emptyTable: "No results found.  Try modifying your filters?"
    }
  });

  /* Smooth Scroll to Anchors
   * ------------------------------------------------------
   * Based on: https://www.abeautifulsite.net/smoothly-scroll-to-an-element-without-a-jquery-plugin-2
   */
  $('a[href^="#"]').on('click', function(event) {
    var hash = this.getAttribute('href');
    var $target = $(hash);

    if ($target.length) {
      event.preventDefault();

      $('html, body').stop().animate({
        scrollTop: $target.offset().top - 58 // account for the navbar's height
      }, 1000);

      location.hash = hash.replace('#', '');
    }
  });
});
