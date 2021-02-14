'use strict';

(function () {
  var template = document.getElementById('hhMapListTemplate');
  var listContainer = document.getElementById('hhMapList');

  var callbackFailure = function (error) {
    console.log(error);
    alert(error);
  };

  var callbackSuccess = function (result) {
    var resultCount = result.getCount();

    var selectedOnMap = result.getMapIndex();
    if (selectedOnMap !== undefined && selectedOnMap !== null && selectedOnMap >= 0) {
      addListItem(result, selectedOnMap, true);
    }

    for (var i = 0; i < resultCount; i++) {
      if (i === selectedOnMap) {
        continue;
      }

      addListItem(result, i, false);
    }
  };

  var addListItem = function (result, i, highlight) {
    var newListItem = document.importNode(template.content, true);

    var fields = newListItem.querySelectorAll('.hh-list-field');
    fields[0].textContent = result.getData(i, 'hh_id');

    var anchor = newListItem.querySelector('a');
    anchor.dataset['hh_id'] = result.getData(i, 'hh_id');
    anchor.addEventListener('click', hhOnClick);

    if (highlight) {
      anchor.classList.add('active');
    }

    listContainer.appendChild(newListItem);
  }

  var hhOnClick = function (evt) {
    var hhId = evt.currentTarget.dataset['hh_id'];

    odkData.query(
      'census',
      'hh_id = ?',
      [hhId],
      null,
      null,
      null,
      null,
      1,
      0,
      false,
      function (result) {
        odkCommon.closeWindow(-1, {
          hhId: hhId,
          hhRowId: result.getRowId(0)
        });
      },
      callbackFailure
    );
  };

  document.addEventListener('DOMContentLoaded', function () {
    odkData.getViewData(callbackSuccess, callbackFailure);

    document
      .getElementById('wrapper')
      .classList
      .remove('d-none');
  });
})();
