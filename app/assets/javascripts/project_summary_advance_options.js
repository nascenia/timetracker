document.addEventListener("turbolinks:load", function () {
  const $table = $("#projects-summary");

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

  function projectSummaryTableFilter(settings, data, dataIndex) {
    if (settings.nTable !== $table[0]) return true;
    if (rowState > 0) {
      const tr = dataTable.row(dataIndex).node();
      return rowState === 1
        ? !$(tr).hasClass("selected")
        : $(tr).hasClass("selected");
    }
    return true;
  }

  $.fn.dataTable.ext.search.push(projectSummaryTableFilter);

  $("#advanced-options").remove();

  $table
    .parent()
    .append("<div id='advanced-options' style='display:none;'></div>");

  $("#advanced-options").append(
    "<button id='show-selected-button'>Show Selected</button> "
  );
  $("#advanced-options").append(
    "<button id='show-deleted-button'>Show Deleted</button> "
  );
  $("#advanced-options").append(
    "<button id='show-all-button'>Restore Deleted</button> "
  );
  $("#advanced-options").append(
    "<button id='clear-selection-button'>Clear Selection</button>"
  );

  $table.on("click", "td span.hideRow", function () {
    $(this).closest("tr").toggleClass("selected");
    return false;
  });

  $("#toggle-advanced-options")
    .off("click")
    .on("click", function () {
      advancedVisible = !advancedVisible;

      if (advancedVisible) {
        $("#advanced-options").show();
        $table.find("tbody tr").each(function () {
          const $cell = $(this).find("td:eq(2)");
          if ($cell.find("span.hideRow").length === 0) {
            $cell.append(
              "<span class='hideRow advanced-control' style='margin-left: auto; display: flex; align-items: center;'><a>X</a></span>"
            );
          }
        });
        $(this).text("Hide Advanced Options");
      } else {
        $("#advanced-options").hide();
        $table.find("span.hideRow").remove();
        $(this).text("Show Advanced Options");
      }
    });

  $("#show-selected-button").on("click", function () {
    rowState = 1;
    dataTable.draw();
    return false;
  });

  $("#show-deleted-button").on("click", function () {
    rowState = 2;
    dataTable.draw();
    return false;
  });

  $("#show-all-button").on("click", function () {
    rowState = 0;
    dataTable.draw();
    return false;
  });

  $("#clear-selection-button").on("click", function () {
    rowState = 0;
    $table.find("tr").removeClass("selected");
    dataTable.draw();
    return false;
  });
});

document.addEventListener("turbolinks:before-cache", function () {
  const $table = $("#projects-summary");
  if ($.fn.DataTable.isDataTable($table)) {
    $table.DataTable().destroy();
  }

  $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(
    (fn) => fn !== projectSummaryTableFilter
  );
});
