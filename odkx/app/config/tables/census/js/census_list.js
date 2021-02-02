'use strict';

(function () {
  var callbackFailure = function (error) {
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

    for (var i = 0; i < resultCount; i++) {
      var newListItem = document.importNode(template.content, true);

      var fields = newListItem.querySelectorAll('.hh-list-field');
      fields[0].textContent = result.getData(i, 'hh_id');
      fields[1].textContent = result.getData(i, 'hh_name') + ' ' + result.getData(i, 'hh_surname');

      var anchor = newListItem.querySelector('a');
      anchor.dataset['rowId'] = result.getRowId(i);
      anchor.addEventListener('click', hhOnClick);

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

  document.addEventListener('DOMContentLoaded', function () {
    var searchBtn = document.getElementById('hhIdSearchButton');
    var searchInput = document.getElementById('hhIdSearchInput');

    searchBtn.addEventListener('click', function () {
      // the search term trimmed, made upper case, and removed space and dash
      var searchTerm = searchInput
        .value
        .trim()
        .toUpperCase()
        .replace(/\s|-/g, '');

      if (searchTerm !== '') {
        odkData.arbitraryQuery(
          'census',
          'SELECT census.*, hh_member.name AS hh_name, hh_member.surname AS hh_surname ' +
          'FROM census LEFT JOIN hh_member ON census.hh_head_new_select = hh_member._id ' +
          'WHERE replace(census.hh_id, "-", "") LIKE ?',
          ['%' + searchTerm + '%'],
          null,
          null,
          callbackSuccess,
          callbackFailure
        );
      }
    });

    searchInput.addEventListener('keyup', function (evt) {
      if (evt.key === 'Enter') {
        searchBtn.click();
        // use blur to hide the keyboard
        searchInput.blur();

        evt.preventDefault();
      }
    });

    document
      .getElementById('wrapper')
      .classList
      .remove('d-none');
  });
})();
