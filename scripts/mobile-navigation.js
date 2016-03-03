import $ from '../node_modules/jquery/dist/jquery.js';

export default {

  setup() {
    $(".js-mobile-nav").click(function() {
      $("body").toggleClass("mobile-nav-open");
    });
  }

};
