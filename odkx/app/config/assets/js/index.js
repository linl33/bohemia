'use strict';

// Button to add a new household
document.addEventListener('DOMContentLoaded', function () {
  document.getElementById('enterFwId').addEventListener('click', function () {
    odkTables.launchHTML(
      null,
      'config/assets/enterFwId.html'
    );
  });

  document.getElementById('newHhButton').addEventListener('click', function () {
    odkTables.addRowWithSurvey(
      null,
      'census',
      'census',
      null,
      {
        fw_id: window.localStorage.getItem('FW_ID') || null
      }
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

  document.getElementById('fwIdSpan').textContent = window.localStorage.getItem('FW_ID') || '';

  if (!window.localStorage.getItem('FW_ID')) {
    document.getElementById('newHhButton').disabled = true;
    document.getElementById('editHhButton').disabled = true;
  }

  localizeUtil.localizePage();

  document.getElementById('wrapper').classList.remove('d-none');
});
