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
  ------------------------------------------------------------
  */
  $('.select').select2({
    closeOnSelect: false
  });
  $

  $category = $('.select-and-input-cat').select2({ tags: true});
  $item = $('.select-and-input-item').select2({ tags: true});

  $category.on("select2:close", function(data){checkInputOffFocus(data, $category)});
  $item.on("select2:close", function(data){checkInputOffFocus(data, $item)});


function checkInputOffFocus(data, $focusinputitem){
  if(data.params.originalSelect2Event === undefined){
      var newOption = new Option(data.target.lastChild.label, data.target.lastChild.label, true, true);
      $focusinputitem.append(newOption).trigger('change');
    }
}

//
// $('.select-and-input-cat').on("select2:close", function(fulldata){
//   if(fulldata.params.originalSelect2Event === undefined){
//       var newOption = new Option(fulldata.target.lastChild.label, fulldata.target.lastChild.label, true, true);
//       $focusinput.append(newOption).trigger('change');
//     }
//   });
//   var $focusinputitem = $('.select-and-input-item').select2({ tags: true});
//     $('.select-and-input-item').on("select2:close", function(fulldata){
//       if(fulldata.params.originalSelect2Event === undefined){
//           var newOption = new Option(fulldata.target.lastChild.label, fulldata.target.lastChild.label, true, true);
//           $focusinputitem.append(newOption).trigger('change');
//         }
//       });
    // else {
    //     data = fulldata.params.originalSelect2Event.data;
    //     if (Object.values(data).length > 3) {
    //         $focusinput.val(data.id).trigger('change');
    //         console.log(true);
    //       } else {
    //           var newOption = new Option(data.text, data.id, true, true);
    //           $focusinput.append(newOption).trigger('change');
    //   }
    // }



    //  else {
    //     data = fulldata.params.originalSelect2Event.data;
    //       if (Object.values(data).length > 3) {
    //           $focusinputitem.val(data.id).trigger('change');
    //         } else {
    //           var newOption = new Option(data.text, data.id, true, true);
    //           $focusinputitem.append(newOption).trigger('change');
    //         }
    // }


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
