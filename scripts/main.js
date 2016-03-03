import $ from '../node_modules/jquery/dist/jquery.js';
import pageNavigation from './page-navigation';
import mobileNavigation from './mobile-navigation';

$(document).ready(() => {
  $( "body" ).removeClass( "preload" );
  $( "html" ).removeClass( "no-js" );

  mobileNavigation.setup();
  pageNavigation.cleanup();

});
