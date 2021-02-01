'use strict';

document.addEventListener('DOMContentLoaded', function (evt) {
  document.getElementById('searchButton').addEventListener('click', function () {
    odkTables.openTableToListView(
      null,
      'census',
      null,
      null,
      null
    );
  });

  document.getElementById('mapButton').addEventListener('click', function () {
    odkTables.openTableToMapView(
      null,
      'census',
      null,
      null,
      null
    );
  });

  document.getElementById('navigateButton').addEventListener('click', function () {
    // TODO:
  });

  document.getElementById('wrapper').style.display = 'inherit';
});
