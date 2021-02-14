'use strict';

(function () {
  var doActionCallback = function () {
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

    document.getElementById('fwIdInput').value = action.jsonValue.result.SCAN_RESULT;
    odkCommon.setSessionVariable('fwIdInput', action.jsonValue.result.SCAN_RESULT);
  }

  document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('enterFwIdForm').addEventListener('submit', function (evt) {
      evt.preventDefault();

      window.localStorage.setItem('FW_ID', document.getElementById('fwIdInput').value.trim());
      alert('Fieldworker ID updated');
    });

    document.getElementById('enterFwIdScan').addEventListener('click', function () {
      odkCommon.doAction(
        {},
        'com.google.zxing.client.android.SCAN',
        null
      );
    });

    if (!!odkCommon.getSessionVariable('fwIdInput')) {
      document.getElementById('fwIdInput').value = odkCommon.getSessionVariable('fwIdInput');
    }

    document
      .getElementById('wrapper')
      .classList
      .remove('d-none');

    odkCommon.registerListener(doActionCallback);
    doActionCallback();
  });
})();
