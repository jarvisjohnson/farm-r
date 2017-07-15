var setupFieldsNeeded, setupManaged, setupStandalone;
$(document).ready(function() {
  setupManaged();
  setupStandalone();
  return setupFieldsNeeded();
});
setupManaged = function() {
  var container, countrySelect, createButton, form, tosEl;
  container = $('#stripe-managed');
  if (container.length === 0) {
    return;
  }
  tosEl = container.find('.tos input');
  countrySelect = container.find('.country');
  form = container.find('form');
  createButton = form.find('.btn');
  tosEl.change(function() {
    return createButton.toggleClass('disabled', !tosEl.is(':checked'));
  });
  form.submit(function(e) {
    if (!tosEl.is(':checked')) {
      e.preventDefault();
      return false;
    }
    return createButton.addClass('disabled').val('...');
  });
  return countrySelect.change(function() {
    var termsUrl;
    termsUrl = "https://stripe.com/" + (countrySelect.val().toLowerCase()) + "/terms";
    return tosEl.siblings('a').attr({
      href: termsUrl
    });
  });
};
setupStandalone = function() {
  var container, countrySelect, createButton, form;
  container = $('#stripe-standalone');
  if (container.length === 0) {
    return;
  }
  countrySelect = container.find('.country');
  form = container.find('form');
  createButton = form.find('.btn');
  return form.submit(function(e) {
    return createButton.addClass('disabled').val('...');
  });
};
setupFieldsNeeded = function() {
  var container, form;
  container = $('.needed');
  if (container.length === 0) {
    return;
  }
  form = container.find('form');
  return form.submit(function(e) {
    var baContainer, button, tokenField;
    button = form.find('.buttons .btn');
    button.addClass('disabled').val('Saving...');
    if ((baContainer = form.find('#bank-account')).length > 0) {
      Stripe.setPublishableKey(baContainer.data('publishable'));
      tokenField = form.find('#bank_account_token');
      if (tokenField.is(':empty')) {
        e.preventDefault();
        Stripe.bankAccount.createToken(form, function(_, resp) {
          if (resp.error) {
            button.removeClass('disabled').val('Save Info');
            
            return alert(resp.error.message);
          } else {
            tokenField.val(resp.id);
            return form.get(0).submit();
          }
        });
        return false;
      }
    }
  });
};
