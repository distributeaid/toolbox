/* Ferry: The Distribute Aid software service.
 * Copyright (C) 2018 - J. Taylor Fairbank (taylor@distributeaid.org)
 *
 * Licensed under the AGPLv3. See `/LICENSE.md`.
 */

$(document).ready(function() {

  /*
  Forms
  ------------------------------------------------------------
  */

  // prevent submit on enter when form is selected (default behavior)
  $(document).keydown("form", function(event) {
    if(event.keyCode == 13 | event.keyCode == 108){
      event.preventDefault();
      return false;
    }
  });

  /*
  Initialize Select2
  Select2 Documentation: https://select2.org/
  ------------------------------------------------------------
  // TODO: style alignment better, especially for multi-select
  // TODO: would be nice if clear just cleared & didn't open the input again
  */

  // ensure that custom values are entered if the user clicks off the selectbox after typing them in
  // TODO: for consistencies sake, if the user types in the name of an existing option and then clicks off, this function should select it for them
  // TODO: what happens if the user types in half an option then clicks off?  right now they'll have the text they typed in, instead of the closest matching option
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

  $(".select2--aid-item-category").select2({ // single
    placeholder: "Choose the category this item belongs to..."
  });

  $(".select2--aid-mod-type") // single
    .select2({
      placeholder: "Choose a type for this mod..."
    })
    .on('select2:select', function(e) {
      if (e.params.data.id == "integer") {
        $(".select2--aid-mod-values").parent().hide();
      } else {
        $(".select2--aid-mod-values").parent().show();
      }
    });

  $(".select2--aid-mod-values") // multi, customizable
    .select2({
      placeholder: "Enter two or more values that users can select from...",
      tags: true
    })
    .on("select2:close", function(data) {
      checkInputOffFocus(data, $(this));
    });

  // Initially hide the values field if the Mod's type isn't set, or isn't a
  // select style option. A .select2--aid-mod-type event handler will control
  // it's visibility as the user interacts with the form.
  if ($(".select2--aid-mod-type").select2('data')) {
    var modType = $(".select2--aid-mod-type").select2('data')[0].id;
    if (modType != "select" && modType != "multi-select") {
      $(".select2--aid-mod-values").parent().hide();
    }
  }

  // TODO: show group logos
  $(".select2--map").select2({ // multi, optional
    allowClear: true,
    closeOnSelect: false,
    placeholder: "Select groups to filter the map..."
  });

  $(".select2--role-group").select2({ // single
    placeholder: "Choose a group to add to the shipment..."
  });

  $(".select2--route-type")// single, customizable
    .select2({
      placeholder: "Choose an option or enter your own...",
      tags: true
    })
    .on("select2:close", function(data) {
      checkInputOffFocus(data, $(this));
    });

  $(".select2--shipment-status").select2({ // single
    placeholder: "Select the current status..."
  });

  // TODO: allow custom entries?
  $(".select2--shipment-transport").select2({ // single, optional
    allowClear: true,
    placeholder: "Select a transport size..."
  });

  $(".select2--stock-project").select2({ // single
    placeholder: "Select a project..."
  });

  $(".select2--stock-category") // single, customizable
    .select2({
      placeholder: "Choose a category or enter your own...",
      tags: true
    })
    .on("select2:close", function(data) {
      checkInputOffFocus(data, $(this));
    });


  $(".select2--stock-item") // single, customizable
    .select2({
      placeholder: "Choose an item or enter your own...",
      tags: true
    })
    .on("select2:close", function(data) {
      checkInputOffFocus(data, $(this));
    });

  // TODO: allow custom entries- this becomes more like "tagging" items?
  $(".select2--stock-mod").select2({ // single, optional
    allowClear: true,
    placeholder: "---"
  });

  /*
  Initialize Datatables
  ------------------------------------------------------------
  */

  $('#group-index').DataTable({
    columnDefs: [
      {
        targets: 0,
        orderable: false,
        searchable: false
      }
    ],
    fixedHeader: true,
    info: false,
    language: {
      emptyTable: "No groups have been created... yet!"
    },
    paging: false,
    order: [[1, 'asc']]
  });

  $('#group-stock-table').DataTable({
    columnDefs: [
      {
        targets: 0,
        orderable: false,
        searchable: false
      }
    ],
    fixedHeader: true,
    info: false,
    language: {
      emptyTable: "No results found.  Try another search term or adding missing inventory?"
    },
    paging: false,
    order: [[1, 'asc']]
  });

  $('#inventory-list').DataTable({
    fixedHeader: true,
    info: false,
    language: {
      emptyTable: "No results found.  Try another search term?"
    },
    paging: false,
    order: [[1, 'asc']]
  });

  $('#shipment-overview').DataTable({
    columnDefs: [
      {
        targets: 0,
        orderable: false,
        searchable: false
      },
      {
        targets: -1,
        orderable: false,
        searchable: false
      }
    ],
    fixedHeader: true,
    info: false,
    language: {
      emptyTable: "No shipments have been created... yet!"
    },
    paging: false,
    order: [[1, 'asc']]
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

  /*
  Lazy Load Images
  ------------------------------------------------------------
  Inspired by: https://www.robinosborne.co.uk/2016/05/16/lazy-loading-images-dont-rely-on-javascript/
  */
  var lazy = document.getElementsByClassName('lazy');
  for (var i = 0; i < lazy.length; i++) {
    lazy[i].src = lazy[i].getAttribute('data-src');
  }

});
