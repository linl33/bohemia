define(['promptTypes', 'jquery', 'prompts'], function(promptTypes, $) {
  return {
    linked_table_counting: promptTypes.linked_table.extend({
      configureRenderContext: function (ctxt) {
        var that = this;

        var modifiedCtxt = $.extend({}, ctxt, {
          success: function () {
            var instances = that.renderContext.instances;
            var instanceCount = 0;

            for (var i = 0; i < instances.length; i++) {
              // check for form_id match to make sure that
              // the desired segment of this instance exists
              if (instances[i].form_id === that.getLinkedFormId()) {
                instanceCount++;
              }
            }

            that.setValueDeferredChange(instanceCount);
            ctxt.success();
          }
        });

        promptTypes.linked_table.prototype.configureRenderContext.apply(this, [modifiedCtxt]);
      }
    })
  }
});
