window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageDiscountCodes = function() {
  function elementToValueObject(element) {
    var r = {};
    r[$(element).val()] = $(element).prop("checked");
    return r;
  }

  // function createCheckboxAjaxRequest(selector, url, allowedKey, disallowedKey) {
  //   var streams = $(selector).toArray().map(function(domElement) {
  //     return $(domElement).asEventStream("change").map(function(event){
  //       return elementToValueObject(event.target);
  //     }).toProperty(elementToValueObject(domElement));
  //   });

  //   var ajaxRequest = Bacon.combineAsArray(streams).changes().debounce(800).skipDuplicates(_.isEqual).map(function(valueObjects) {
  //     function isValueTrue(valueObject) {
  //       return _.values(valueObject)[0];
  //     }

  //     var allowed = _.filter(valueObjects, isValueTrue);
  //     var disallowed = _.reject(valueObjects, isValueTrue);

  //     var data = {};
  //     data[allowedKey] = _.keys(ST.utils.objectsMerge(allowed));
  //     data[disallowedKey] = _.keys(ST.utils.objectsMerge(disallowed));

  //     return {
  //       type: "POST",
  //       url: ST.utils.relativeUrl(url),
  //       data: data
  //     };
  //   });
  //   console.log("___FIRING__");
  //   return ajaxRequest;
  // }

  // $(".code-is-active").bind('change', function(){
  //   console.log("___FIRING__");
  //   if (this.checked){
  //     $.ajax({
  //       url: '/en/admin/communities/25452/discount_codes/'+this.value+'/code_active',
  //       type: 'POST',
  //       data: {"completed": this.checked}
  //     });
  //   }
  //   else {
  //     $.ajax({
  //       url: '/en/admin/communities/25452/discount_codes/'+this.value+'/code_active',
  //       type: 'POST',
  //       data: {"completed": this.checked}
  //     });
  //   }
  // });

  // var isActive = createCheckboxAjaxRequest(".code-is-active", "code_active", "code_is_active", "code_is_inactive");
  // // var isAdmin = createCheckboxAjaxRequest(".admin-members-is-admin", "promote_admin", "add_admin", "remove_admin");

  // var ajaxRequest = isActive;
  // var ajaxResponse = ajaxRequest.ajax().endOnError();

  // var ajaxStatus = window.ST.ajaxStatusIndicator(ajaxRequest, ajaxResponse);

  // ajaxStatus.loading.onValue(function() {
  //   $(".ajax-update-notification").show();
  //   $("#admin-members-saving-posting-allowed").show();
  //   $("#admin-members-error-posting-allowed").hide();
  //   $("#admin-members-saved-posting-allowed").hide();
  // });

  // ajaxStatus.success.onValue(function() {
  //   $("#admin-members-saving-posting-allowed").hide();
  //   $("#admin-members-saved-posting-allowed").show();
  // });

  // ajaxStatus.error.onValue(function() {
  //   $("#admin-members-saving-posting-allowed").hide();
  //   $("#admin-members-error-posting-allowed").show();
  // });

  // ajaxStatus.idle.onValue(function() {
  //   $(".ajax-update-notification").fadeOut();
  // });

  // Attach analytics click handler for CSV export
  $(".js-codes-csv-export").click(function(){
    /* global report_analytics_event */
    report_analytics_event('admin', 'export', 'codes');
  });
};
