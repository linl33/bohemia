$(document).on('click', '#dt_symptoms table tr', function() {
    var selectedRowIds = $('#dt_symptoms .dataTables_scrollBody table.dataTable').DataTable().rows('.selected')[0];

    var selectedId = "";
    if (selectedRowIds.length === 1) {
        selectedId = $(this).children('td:eq(0)').text();
    } else {
      $('#dt_symptoms tbody tr').removeClass('selected');
    }
    Shiny.onInputChange("dt_symptoms_selected_id", selectedId);
});