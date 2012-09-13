//= require mxit_rails/jquery-1.8.0.min
//= require mxit_rails/jquery.cookie

Emulator = (function() {
  return {
    setCookie: function(mxitId, msisdn) {
      // Create cookies.  Use only lowercase cookie names - the server expects this (case insensitivity seems dodgy)
      $.cookie('x-mxit-login', mxitId, {path: '/'});
      $.cookie('x-mxit-userid-r', 'm987654321', {path: '/'});
      $.cookie('x-mxit-device-info', 'DISTRO_CODE,' + msisdn, {path: '/'});

      // Reset the iframe
      $('#center').attr('src', '/' + MXIT_ROOT);
    },

    clearCookie: function() {
      // Create cookies.  Use only lowercase cookie names - the server expects this (case insensitivity seems dodgy)
      $.cookie('x-mxit-login', null, {path: '/'});
      $.cookie('x-mxit-userid-r', null, {path: '/'});
      $.cookie('x-mxit-device-info', null, {path: '/'});

      // Reset the iframe
      $('#center').attr('src', '/' + MXIT_ROOT);
    },

    enterCredentials: function() {
      $('#default').hide();
      $('#inputs').show();
      $('#mxit-id-input').focus();
    },

    saveCredentials: function() {
      localStorage.setItem('mxitId', $('#mxit-id-input').val());
      localStorage.setItem('msisdn', $('#msisdn-input').val());
      $('#default').show();
      $('#inputs').hide();
      Emulator.setCredentials();
    },

    setCredentials: function() {
      mxitId = localStorage.getItem('mxitId');
      msisdn = localStorage.getItem('msisdn');

      Emulator.setCookie(mxitId, msisdn);
      $('#link').hide();
      $('#unlink').show();
      $('#registered').show();
      $('#not-registered').hide();
      $('#mxit-id').html(mxitId);
    },

    clearCredentials: function() {
      localStorage.removeItem('mxitId');
      localStorage.removeItem('msisdn');

      Emulator.clearCookie();
      $('#link').show();
      $('#unlink').hide();
      $('#registered').hide();
      $('#not-registered').show();
    },

    collapse: function() {
      $('#phone').removeClass('collapse');
      $('#fadeout').show();
    },

    expand: function() {
      $('#phone').addClass('collapse');
      $('#fadeout').hide();
    },
  }
})();

$(function() {

  // Check whether there is a Mxit ID and msisdn in local storage
  var mxitId = localStorage.getItem('mxitId');
  var msisdn = localStorage.getItem('msisdn');

  if (mxitId && msisdn) {
    Emulator.setCredentials();

  } else {
    Emulator.clearCredentials();
  }

});
