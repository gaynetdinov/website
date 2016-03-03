import hello from './hello';

import $ from '../node_modules/jquery/dist/jquery.js';

window.onload = () => {
  $( "body" ).removeClass( "preload" );
  $( "html" ).removeClass( "no-js" );


  $(".js-mobile-nav").click(function() {
      $("body").toggleClass("mobile-nav-open");
  });

}
