'use strict';

(function () {
  var callbackFailure = function (error) {
    window.localStorage.removeItem('bohemiaHhSearch');

    console.log(error);
    alert(error);
  };

  var callbackSuccess = function (result) {
    var template = document.getElementById('hhListTemplate');
    var listContainer = document.getElementById('hhSearchList');

    // clear prev search result
    listContainer.innerText = '';

    var resultCount = result.getCount();
    if (resultCount === 0) {
      alert('No Result');
    }

    // re-enable map after a successful search
    document.getElementById('hhIdMapButton').classList.remove('d-none');

    for (var i = 0; i < resultCount; i++) {
      var newListItem = document.importNode(template.content, true);

      var fields = newListItem.querySelectorAll('.hh-list-field');
      fields[0].textContent = result.getData(i, 'hh_id');
      fields[1].textContent = result.getData(i, 'hh_name') + ' ' + result.getData(i, 'hh_surname');

      var buttons = newListItem.querySelectorAll('button');
      buttons[0].dataset['rowId'] = result.getRowId(i);
      buttons[0].addEventListener('click', hhOnClick);

      buttons[1].dataset['rowId'] = result.getRowId(i);
      buttons[1].dataset['geoRowId'] = result.getData(i, 'geo_rowId');
      buttons[1].addEventListener('click', navOnClick);

      listContainer.appendChild(newListItem);
    }
  };

  var hhOnClick = function (evt) {
    odkTables.editRowWithSurvey(
      null,
      'census',
      evt.currentTarget.dataset['rowId'],
      'census',
      null
    );
  };

  var navOnClick = function (evt) {
    odkTables.openTableToNavigateView(
      { hhRowId: evt.currentTarget.dataset['rowId'] },
      'hh_geo_location',
      buildWhereClause(),
      ['%' + window.localStorage.getItem('bohemiaHhSearch') + '%'],
      evt.currentTarget.dataset['geoRowId']
    );
  }

  var searchOnClick = function (searchInput) {
    // the search term trimmed, made upper case, and removed space and dash
    return function () {
      var searchTerm = searchInput
        .value
        .trim()
        .toUpperCase()
        .replace(/\s|-/g, '');

      if (searchTerm !== '') {
        window.localStorage.setItem('bohemiaHhSearch', searchTerm);
        odkData.arbitraryQuery(
          'census',
          'SELECT census.*, hh_member.name AS hh_name, hh_member.surname AS hh_surname, hh_geo_location._id AS geo_rowId ' +
          'FROM census LEFT JOIN hh_member ON census.hh_head_new_select = hh_member._id ' +
          'LEFT JOIN hh_geo_location ON census.hh_id = hh_geo_location.hh_id ' +
          'WHERE ' + buildWhereClause('census'),
          ['%' + searchTerm + '%'],
          null,
          null,
          callbackSuccess,
          callbackFailure
        );
      }
    }
  };

  var mapOnClick = function () {
    var currSearchTerm = window.localStorage.getItem('bohemiaHhSearch');
    if (!!currSearchTerm) {
      odkTables.openTableToMapView(
        null,
        'hh_geo_location',
        buildWhereClause(),
        ['%' + currSearchTerm + '%'],
        null
      );
    }
  };

  var navCallback = function () {
    var action = odkCommon.viewFirstQueuedAction();
    odkCommon.removeFirstQueuedAction();

    // when arrive is clicked
    if (!!action && action.jsonValue.status === -1) {
      odkTables.editRowWithSurvey(
        null,
        'census',
        action.dispatchStruct.hhRowId,
        'census',
        null
      );
    }
  };

  var buildWhereClause = function (tableId) {
    tableId = !!tableId ? tableId + '.' : "";
    return 'replace(' + tableId + 'hh_id, "-", "") LIKE ?'
  }

  document.addEventListener('DOMContentLoaded', function () {
    var searchBtn = document.getElementById('hhIdSearchButton');
    var searchInput = document.getElementById('hhIdSearchInput');
    var mapBtn = document.getElementById('hhIdMapButton');

    searchBtn.addEventListener('click', searchOnClick(searchInput));
    searchInput.addEventListener('keyup', function (evt) {
      if (evt.key === 'Enter') {
        searchBtn.click();
        // use blur to hide the keyboard
        searchInput.blur();

        evt.preventDefault();
      }
    });
    searchInput.addEventListener('input', function () {
      // disable map everytime the search changes
      mapBtn.classList.add('d-none');
    });

    mapBtn.addEventListener('click', mapOnClick);

    var currSearchTerm = window.localStorage.getItem('bohemiaHhSearch');
    if (!!currSearchTerm) {
      searchInput.value = currSearchTerm;
      searchBtn.click();
    }

    odkCommon.registerListener(navCallback);
    navCallback();

    document
      .getElementById('wrapper')
      .classList
      .remove('d-none');
  });
})();
