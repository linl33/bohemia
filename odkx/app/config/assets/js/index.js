'use strict';

// Button to add a new household
document.addEventListener('DOMContentLoaded', function (evt) {
  document.getElementById('newHhButton').addEventListener('click', function () {
    odkTables.addRowWithSurvey(
      null,
      'census',
      'census',
      null,
      null
    );
  });

  // Button to modify an existing household
  document.getElementById('editHhButton').addEventListener('click', function () {
    odkTables.openTableToListView(null, 'census');
  });

  // Button to sync
  document.getElementById('syncHhButton').addEventListener('click', function () {
    odkCommon.doAction(
      null,
      'org.opendatakit.services.sync.actions.activities.SyncActivity',
      {
        componentPackage: 'org.opendatakit.services',
        componentActivity: 'org.opendatakit.services.sync.actions.activities.SyncActivity'
      }
    );
  });

  window.localStorage.removeItem('bohemiaHhSearch');
  window.localStorage.removeItem('bohemiaMemberSearch');

  document.getElementById('wrapper').style.display = 'inherit';
});
