'use strict';

define(['promptTypes', 'jquery', 'database', 'prompts'], function(promptTypes, $, database) {
  return {
    next_extid: promptTypes.base.extend({
      type: 'next_extid',
      template: function () { return ''; },
      valid: true,
      configureRenderContext: function (ctxt) {
        var that = this;
        var hhId = database.getDataValue('hh_id');

        // query for the maximum ExtID for this household
        // Only the last part of the ID is returned
        odkData.arbitraryQuery(
          'hh_member',
          'SELECT max(CAST(substr(id, 9) AS INT)) AS maxId FROM hh_member WHERE length(id) = 11 AND hh_id = ? AND _savepoint_type = ?',
          [hhId, 'COMPLETE'],
          null,
          null,
          function (result) {
            var rawMaxId = result.get('maxId');
            var next = !!rawMaxId ? Number(rawMaxId) + 1 : 1;

            var nextStr = next.toString();
            if (nextStr.length < 3) {
              nextStr = '0'.repeat(3 - nextStr.length) + nextStr;
            }

            that.setValueDeferredChange(hhId + '-' + nextStr);
            ctxt.success();
          },
          function (error) {
            ctxt.failure({message: error});
          }
        );
      }
    })
  }
});
