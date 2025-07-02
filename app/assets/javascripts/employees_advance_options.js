document.addEventListener("turbolinks:load", function () {
  const $table = $("#employee-info-table");

  // Destroy if already initialized (but DO NOT empty tbody)
  if ($.fn.DataTable.isDataTable($table)) {
    $table.DataTable().destroy();
  }

  let rowState = 0;
  let advancedVisible = false;

  // Initialize DataTable
  const dataTable = $table.DataTable({
    lengthChange: false,
    pageLength: 100,
    dom: '<"dt-top-left"Tf>lrtip',
    buttons: ["print"],
    select: { style: "multi+shift" },
  });

  // Move employee filter form to DataTable top-left area
  $(".dt-top-left").append($(".employee-filter-form").clone());
  if ($(".employee-filter-form").length > 1) {
    $(".employee-filter-form").hide();
    $(".employee-filter-form").eq(1).show();
  }

  // Handle employee status filter change
  $('select[name="employee_status"]').change(function () {
    $(".employee-filter-form").submit();
  });

  // Filtering logic (scoped to this table)
  function employeeTableFilter(settings, data, dataIndex) {
    if (settings.nTable !== $table[0]) return true;
    if (rowState > 0) {
      const tr = dataTable.row(dataIndex).node();
      return rowState === 1
        ? !$(tr).hasClass("selected")
        : $(tr).hasClass("selected");
    }
    return true;
  }
  // Add filter
  $.fn.dataTable.ext.search.push(employeeTableFilter);

  // Remove old controls if Turbolinks reloaded the page
  $("#employees-advanced-options").remove();

  // Create new control container
  $table
    .parent()
    .append(
      "<div id='employees-advanced-options' style='display:none;'></div>"
    );

  $("#employees-advanced-options").append(
    "<button id='employee-show-selected-button'>Show Selected</button> "
  );
  $("#employees-advanced-options").append(
    "<button id='employee-show-deleted-button'>Show Deleted</button> "
  );
  $("#employees-advanced-options").append(
    "<button id='employee-show-all-button'>Restore Deleted</button> "
  );
  $("#employees-advanced-options").append(
    "<button id='employee-clear-selection-button'>Clear Selection</button>"
  );

  // Handle X toggle
  $table.on("click", "td span.hideRow", function () {
    $(this).closest("tr").toggleClass("selected");
    return false;
  });

  // Toggle advanced options + Xs
  $("#toggle-employees-advanced-options")
    .off("click")
    .on("click", function () {
      advancedVisible = !advancedVisible;

      if (advancedVisible) {
        $("#employees-advanced-options").show();
        $table.find("tbody tr").each(function () {
          // The X should be in the last cell (TTF column)
          const $cell = $(this).find("td:last");
          if ($cell.find("span.hideRow").length === 0) {
            $cell.append(
              "<span class='hideRow advanced-control' style='float:right;'><a>X</a></span>"
            );
          }
        });
        $(this).text("Hide Advanced Options");
      } else {
        $("#employees-advanced-options").hide();
        $table.find("span.hideRow").remove();
        $(this).text("Show Advanced Options");
      }
    });

  // Advanced filter buttons
  $("#employee-show-selected-button").on("click", function () {
    rowState = 1;
    dataTable.draw();
    return false;
  });

  $("#employee-show-deleted-button").on("click", function () {
    rowState = 2;
    dataTable.draw();
    return false;
  });

  $("#employee-show-all-button").on("click", function () {
    rowState = 0;
    dataTable.draw();
    return false;
  });

  $("#employee-clear-selection-button").on("click", function () {
    rowState = 0;
    $table.find("tr").removeClass("selected");
    dataTable.draw();
    return false;
  });
});

// Clean up DataTable and filter before Turbolinks caches the page
document.addEventListener("turbolinks:before-cache", function () {
  const $table = $("#employee-info-table");
  if ($.fn.DataTable.isDataTable($table)) {
    $table.DataTable().destroy();
  }
  // Remove the filter
  $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(
    (fn) => fn !== employeeTableFilter
  );
});
