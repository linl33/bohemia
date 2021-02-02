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
    // odkTables.openTableToMapViewArbitraryQuery(
    //   null,
    //   'hh_geo_location',
    //   'SELECT hh_geo_location.*, census._id AS hh_rowId, hh_member.name AS hh_name, hh_member.surname AS hh_surname FROM hh_geo_location LEFT JOIN census ON hh_geo_location.hh_id = census.hh_id LEFT JOIN hh_member ON census.hh_head_new_select = hh_member._id',
    //   [],
    //   null
    // );

    odkTables.openTableToMapView(
      null,
      'hh_geo_location',
      null,
      [],
      null
    );
  });

  document.getElementById('navigateButton').addEventListener('click', function () {
    // TODO:
  });

  document.getElementById('wrapper').style.display = 'inherit';
});
