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

  $('.select-and-input').select2({
    tags: true
  });

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
