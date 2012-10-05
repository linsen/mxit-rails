//= require mxit_rails/jquery-1.8.0.min
//= require mxit_rails/jquery.cookie
//= require mxit_rails/jquery.history

Emulator = (function() {
  // history.js setup
  var History = window.History; // Note: We are using a capital H instead of a lower h
  History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
      var State = History.getState(); // Note: We are using History.getState() instead of event.state
      if (State.data.url)
        Emulator.setUrl(State.data.url);
  });

  var keys = {
    BACKSPACE: 8,
    ENTER: 13,
    ESCAPE: 27,

    SPACE: 32,

    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,

    ZERO: 48,
    NINE: 57,

    A: 65,
    Z: 90
  };

  return {
    activeLink: 0,

    setCookie: function() {
      // Create cookies.  Use only lowercase cookie names - the server expects this (case insensitivity seems dodgy)
      $.cookie('x-mxit-userid-r', localStorage.getItem('mxit-id'), {path: '/'});
      $.cookie('x-mxit-login', localStorage.getItem('mxit-login'), {path: '/'});
      $.cookie('x-mxit-nick', localStorage.getItem('mxit-nick'), {path: '/'});
      $.cookie('x-mxit-contact', localStorage.getItem('mxit-contact'), {path: '/'});
      $.cookie('x-mxit-location', localStorage.getItem('mxit-location'), {path: '/'});
      $.cookie('x-mxit-profile', localStorage.getItem('mxit-profile'), {path: '/'});
      $.cookie('x-mxit-device-info', localStorage.getItem('mxit-distribution-code') + ',' + localStorage.getItem('mxit-msisdn'), {path: '/'});

      $.cookie('ua-pixels', '240x320', {path: '/'});
      $.cookie('x-device-user-agent', 'EMULATOR', {path: '/'});


      if (MXIT_PATH && (MXIT_PATH != ''))
        Emulator.setUrl(MXIT_PATH);
      else
        Emulator.home();
    },

    home: function() {
      Emulator.setUrl(MXIT_ROOT);
    },

    getUrl: function() {
      if (typeof($('#center').attr('src')) != 'undefined') {
        var url = Emulator.iframe().location.pathname;
        if (Emulator.iframe().location.search)
          url += Emulator.iframe().location.search;
        return url;
      }
      return null;
    },

    setUrl: function(path) {
      if (Emulator.getUrl() == path)
        return;

      var url = path;
      if (url[0] != '/')
        url = '/' + url;
      $('#center').attr('src', url);
    },

    editCredentials: function() {
      $('#center').hide();
      $('#inputs').show();
      $('#link').hide();

      values = ['id', 'login', 'nick', 'contact', 'location', 'profile', 'distribution-code', 'msisdn'];
      for (var i in values) {
        var str = values[i];
        var value = localStorage.getItem('mxit-' + str);
        $('#mxit-' + str + '-input').val(value);
      }
    },

    clearCredentials: function() {
      values = ['id', 'login', 'nick', 'contact', 'location', 'profile', 'distribution-code', 'msisdn'];
      for (var i in values) {
        var str = values[i];
        $('#mxit-' + str + '-input').val('');
      }
    },

    saveCredentials: function() {
      values = ['id', 'login', 'nick', 'contact', 'location', 'profile',, 'distribution-code', 'msisdn'];
      for (var i in values) {
        var str = values[i];
        var val = $('#mxit-' + str + '-input').val();
        if (val == '')
          val = $('#mxit-' + str + '-input').attr('placeholder');
        localStorage.setItem('mxit-' + str, val);
      }

      $('#inputs').hide();
      $('#center').show();
      $('#link').show();
      Emulator.setCredentials();
    },

    setCredentials: function() {
      Emulator.setCookie();

      $('#registered').show();
      $('#not-registered').hide();

      if (localStorage.getItem('mxit-login')) {
        $('#mxit-login-id-label').html('Login');
        $('#mxit-login-id').html(localStorage.getItem('mxit-login'));
      } else if (localStorage.getItem('mxit-id')) {
        $('#mxit-login-id-label').html('ID');
        $('#mxit-login-id').html(localStorage.getItem('mxit-id'));
      } else {
        $('#not-registered').show();
        $('#registered').hide();
      }
    },

    iframe: function() {
      return $('#center')[0].contentWindow;
    },
    iframeElement: function(queryString) {
      return $(queryString, Emulator.iframe().document);
    },

    collapse: function() {
      $('body').removeClass('collapse');
    },

    expand: function() {
      $('body').addClass('collapse');
    },

    expandCollapse: function(val) {
      if (val) {
        if (val == 'expand')
          localStorage.setItem('expanded', true);
        else
          localStorage.removeItem('expanded');
      }

      var expanded = localStorage.getItem('expanded');
      if (expanded) {
        Emulator.expand();
      } else {
        Emulator.collapse();
      }
    },

    refresh: function() {
      Emulator.iframe().location.reload();
    },

    updateIframe: function() {
      var newPath = Emulator.getUrl();
      if (newPath) {
        History.pushState({url: newPath}, '', '/emulator' + newPath);
      }

      Emulator.iframeElement('body').addClass('emulator');
      Emulator.iframeElement('body').on('keydown', $.proxy(Emulator, 'key'));

      if (this.hasInput()) {
        $('#phone-input').attr('disabled', false);
        this.activeLink = this.numLinks();    
      } else {
        $('#phone-input').attr('disabled', 'disabled').blur();
        this.activeLink = 0;
      }
      this.focusLink();

      // Look for Rails default stacktrace and expand if it's there.  Otherwise use the localstorage expanded setting
      if ((Emulator.iframeElement('#env_dump').length > 0) && (Emulator.iframeElement('#session_dump').length > 0)) {
        Emulator.expand();
      } else {
        Emulator.expandCollapse();
      }
    },

    key: function(e) {
      if ((e.keyCode == keys.UP) || (e.keyCode == keys.DOWN)) {
        if (e.keyCode == keys.UP) {
          this.activeLink--;
        } else {
          this.activeLink++
        }
        this.focusLink();
      }
    },

    hasInput: function() {
      return Emulator.iframeElement('form').length > 0;
    },

    numLinks: function() {
      return Emulator.iframeElement('a').length;
    },

    focusLink: function() {
      var num = this.numLinks();
      var max = this.hasInput() ? num : num - 1;

      if (this.activeLink < 0) this.activeLink = max;
      if (this.activeLink > max) this.activeLink = 0;

      if (this.activeLink == num) {
        this.focusInput();
      } else {
        $(Emulator.iframeElement('a')[this.activeLink]).focus();
      }
    },

    focusInput: function() {
      if (this.hasInput()) {
        $('#phone-input').attr('disabled', false).focus();
      } else {
        $('#phone-input').attr('disabled', 'disabled').blur();
      }
    },

    submit: function(e) {
      if (e.charCode == keys.ENTER) {
        if (Emulator.iframeElement('form').length > 0) {
          Emulator.iframeElement('input[type=text]').val($('#phone-input').val());
          Emulator.iframeElement('input[type=submit]').click();

          $('#phone-input').val('');
        }
      }
    },
  }
})();



$(function() {

  Emulator.setCredentials();

  Emulator.expandCollapse();


  $('body').on('keydown', $.proxy(Emulator, 'key'));
  $('#phone-input').on('keypress', $.proxy(Emulator, 'submit'))

});
