'use strict';

(function () {
  var MAP_ACTION = 'MAP';
  var NAV_ACTION = 'NAV';
  var ACTION_KEY = 'CENSUS_LIST_ACTION';

  var platInfo = JSON.parse(odkCommon.getPlatformInfo());

  var callbackFailure = function (error) {
    window.localStorage.removeItem(searchParam.hhId.storageKey);
    window.localStorage.removeItem(searchParam.member.storageKey);

    $('#hhRosterModal').modal('hide');

    console.error(error);
    alert(error);
  };

  var querySuccessCallback = function (type) {
    return function (result) {
      // clear prev search result
      searchParam[type].listContainer.innerText = '';

      var resultCount = result.getCount();
      if (resultCount === 0) {
        searchParam[type].noResult.classList.remove('d-none');
        return;
      } else {
        searchParam[type].noResult.classList.add('d-none');
      }

      // re-enable map after a successful search
      searchParam[type].mapBtn.classList.remove('d-none');

      var template = document.getElementById('hhListTemplate');
      for (var i = 0; i < resultCount; i++) {
        var newListItem = document.importNode(template.content, true);

        var rowId = result.getRowId(i);
        var hhId = result.getData(i, 'hh_id');

        var fields = newListItem.querySelectorAll('.hh-list-field');
        fields[0].textContent = hhId;
        fields[1].textContent = result.getData(i, 'hh_name') + ' ' + result.getData(i, 'hh_surname');

        var buttons = newListItem.querySelectorAll('button');
        buttons[0].dataset['rowId'] = rowId;
        buttons[0].dataset['hhId'] = hhId;
        buttons[0].addEventListener('click', hhOnClick);

        buttons[1].dataset['rowId'] = rowId;
        buttons[1].dataset['hhId'] = hhId;
        buttons[1].dataset['geoRowId'] = result.getData(i, 'geo_rowId');
        buttons[1].addEventListener('click', searchParam[type].navOnClick);

        searchParam[type].listContainer.appendChild(newListItem);
      }
    }
  };

  var openHh = function (hhRowId, hhId) {
    // disable the proceed button before the new roster is populated
    document.getElementById('hhRosterModalProceed').removeEventListener('click', hhRosterConfirm);
    document.getElementById('hhRosterModalProceed').dataset['rowId'] = hhRowId;

    // set the new HH ID and clear the prev. member roster
    document.getElementById('hhRosterModalTitle').textContent = hhId;
    document.getElementById('hhRosterModalBody').textContent = '';

    odkData.arbitraryQuery(
      'hh_member',
      'SELECT name, surname, id FROM hh_member WHERE hh_id = ? ORDER BY id ASC',
      [hhId],
      null,
      null,
      function (result) {
        var rosterList = document.getElementById('hhRosterModalBody');
        var template = document.getElementById('hhRosterTemplate');

        var resultCount = result.getCount();
        for (var i = 0; i < resultCount; i++) {
          var member = document.importNode(template.content, true);

          member.querySelector('span').textContent = result.getData(i, 'name') + ' ' + result.getData(i, 'surname');
          member.querySelector('small').textContent = result.getData(i, 'id');

          rosterList.appendChild(member);
        }

        document.getElementById('hhRosterModalProceed').addEventListener('click', hhRosterConfirm);
      },
      callbackFailure
    );

    $('#hhRosterModal').modal('show');
  }

  var hhRosterConfirm = function (evt) {
    // modified from odkTables.editRowWithSurvey
    // to pass fw_id

    var uri = odkCommon.constructSurveyUri(
      'census',
      'census',
      evt.currentTarget.dataset['rowId'],
      null,
      {
        fw_id: window.localStorage.getItem('FW_ID') || null
      }
    );

    var hashString = uri.substring(uri.indexOf('#'));

    var extrasBundle = {
      url: platInfo.baseUri + 'system/index.html' + hashString
    };

    var intentArgs = {
      data: uri,
      type: "vnd.android.cursor.item/vnd.opendatakit.form",
      action: "android.intent.action.EDIT",
      category: "android.intent.category.DEFAULT",
      extras: extrasBundle
    };

    return odkCommon.doAction(
      null,
      "org.opendatakit.survey.activities.SplashScreenActivity",
      intentArgs
    );
  }

  var hhOnClick = function (evt) {
    openHh(evt.currentTarget.dataset['rowId'], evt.currentTarget.dataset['hhId']);
  };

  var navOnClick = function (type) {
    return function (evt) {
      odkTables.openTableToNavigateView(
        {
          [ACTION_KEY]: NAV_ACTION,
          hhRowId: evt.currentTarget.dataset['rowId'],
          hhId: evt.currentTarget.dataset['hhId']
        },
        'hh_geo_location',
        searchParam[type].sqlWhereClause('hh_id'),
        ['%' + window.localStorage.getItem(searchParam[type].storageKey) + '%'],
        evt.currentTarget.dataset['geoRowId']
      );
    };
  };

  var searchOnClick = function (type) {
    var cbSuccess = querySuccessCallback(type);

    return function () {
      var searchTerm = searchParam[type].processSearchTerm();

      if (searchTerm !== '') {
        window.localStorage.setItem(searchParam[type].storageKey, searchTerm);

        odkData.arbitraryQuery(
          'census',
          'SELECT census.*, ' +
          'hh_member.name AS hh_name, ' +
          'hh_member.surname AS hh_surname, ' +
          'hh_geo_location._id AS geo_rowId ' +
          'FROM census LEFT JOIN hh_member ON census.hh_head_new_select = hh_member._id ' +
          'LEFT JOIN hh_geo_location ON census.hh_id = hh_geo_location.hh_id WHERE ' + searchParam[type].sqlWhereClause('census.hh_id'),
          ['%' + searchTerm + '%'],
          null,
          null,
          cbSuccess,
          callbackFailure
        );
      }
    };
  };

  var mapOnClick = function (type) {
    return function () {
      var searchTerm = window.localStorage.getItem(searchParam[type].storageKey)
      if (!!searchTerm) {
        odkTables.openTableToMapView(
          {[ACTION_KEY]: MAP_ACTION},
          'hh_geo_location',
          searchParam[type].sqlWhereClause('hh_id'),
          ['%' + searchTerm + '%'],
          null
        );
      }
    };
  };

  var actionCallback = function () {
    if (document.visibilityState !== 'visible') {
      return;
    }

    var action = odkCommon.viewFirstQueuedAction();
    if (action === undefined || action === null) {
      return;
    }

    odkCommon.removeFirstQueuedAction();

    if (action.jsonValue.status !== -1) {
      return;
    }

    var hhMetadata;
    if (action.dispatchStruct[ACTION_KEY] === NAV_ACTION) {
      // when arrive is clicked
      hhMetadata = action.dispatchStruct;
    } else if (action.dispatchStruct[ACTION_KEY] === MAP_ACTION) {
      // when a household is selected on the map
      hhMetadata = action.jsonValue.result;
    }

    if (!!hhMetadata.hhRowId && !! hhMetadata.hhId) {
      openHh(hhMetadata.hhRowId, hhMetadata.hhId);
    }
  };

  var configSearch = function (type) {
    searchParam[type].searchBtn = document.getElementById(type + 'SearchButton');
    searchParam[type].searchInput = document.getElementById(type + 'SearchInput');
    searchParam[type].mapBtn = document.getElementById(type + 'MapButton');
    searchParam[type].listContainer = document.getElementById(type + 'SearchList');
    searchParam[type].noResult = document.getElementById(type + 'NoResult');

    var searchBtn = searchParam[type].searchBtn;
    var searchInput = searchParam[type].searchInput;
    var mapBtn = searchParam[type].mapBtn;

    searchBtn.addEventListener('click', searchOnClick(type));
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

    mapBtn.addEventListener('click', mapOnClick(type));

    var searchTerm = window.localStorage.getItem(searchParam[type].storageKey);
    if (!!searchTerm) {
      searchInput.value = searchTerm;
      searchBtn.click();
    }
  };

  var searchParam = {
    hhId: {
      storageKey: 'bohemiaHhSearch',
      sqlWhereClause: function (column) {
        return "replace(" + column + ", '-', '') LIKE ?";
      },
      navOnClick: navOnClick('hhId'),
      processSearchTerm: function () {
        return this.searchInput.value
          .trim()
          .toUpperCase()
          .replace(/\s|-/g, '');
      }
    },
    member: {
      storageKey: 'bohemiaMemberSearch',
      sqlWhereClause: function (column) {
        return column +
          " IN (SELECT DISTINCT hh_id FROM hh_member WHERE lower(replace(name || surname, ' ', '')) LIKE lower(?))";
      },
      navOnClick: navOnClick('member'),
      processSearchTerm: function () {
        return this.searchInput.value
          .trim()
          .replace(/\s/g, '');
      }
    }
  };

  document.addEventListener('DOMContentLoaded', function () {
    configSearch('hhId');
    configSearch('member');

    $('a[data-toggle="pill"]').on('shown.bs.tab', function (evt) {
      odkCommon.setSessionVariable('TAB', '#' + $(evt.target).attr('id'));

      if (!odkCommon.hasListener()) {
        odkCommon.registerListener(actionCallback);
        actionCallback();
      }
    });

    localizeUtil.localizePage();

    document
      .getElementById('wrapper')
      .classList
      .remove('d-none');

    if (!!odkCommon.getSessionVariable('TAB')) {
      $(odkCommon.getSessionVariable('TAB')).tab('show');
    } else {
      odkCommon.registerListener(actionCallback);
      actionCallback();
    }
  });
})();
