'use strict';

define(['promptTypes', 'opendatakit', 'database', 'jquery', 'prompts'], function(promptTypes, opendatakit, database, $) {
  var countInstances = function (instanceList) {
    var instanceCount = 0;

    for (var i = 0; i < instanceList.length; i++) {
      if (instanceList[i].savepoint_type === opendatakit.savepoint_type_complete) {
        instanceCount++;
      }
    }

    return instanceCount;
  }

  return {
    linked_table_counting: promptTypes.linked_table.extend({
      configureRenderContext: function (ctxt) {
        var that = this;
        var queryDefn = opendatakit.getQueriesDefinition(this.values_list);

        var modifiedCtxt = $.extend({}, ctxt, {
          success: function () {
            var subFormStatusCol = queryDefn.subFormStatusCol;

            if (subFormStatusCol === undefined || subFormStatusCol === null || subFormStatusCol === '') {
              that.setValueDeferredChange(countInstances(that.renderContext.instances));
              ctxt.success();
            } else {
              var modifiedSel = that._cachedSelection || '';
              if (modifiedSel !== '') {
                modifiedSel += ' AND ';
              }
              modifiedSel += '"' + queryDefn.subFormStatusCol + '" = ?';

              var modifiedSelArgs = queryDefn.selectionArgs() || [];
              modifiedSelArgs.push('1');

              database.get_linked_instances($.extend({}, ctxt, {
                success: function (instanceList) {
                  that.setValueDeferredChange(countInstances(instanceList));
                  ctxt.success();
                }
              }), that.getLinkedTableId(), modifiedSel, modifiedSelArgs);
            }
          }
        });

        promptTypes.linked_table.prototype.configureRenderContext.apply(this, [modifiedCtxt]);
      }
    })
  }
});
