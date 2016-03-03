import $ from '../node_modules/jquery/dist/jquery.js';

export default {

  cleanup() {
    let rows = [];
    $("#page-navigation li").each(function() {
      let position = $(this).position();
      if (!rows[position.top]) { rows[position.top] = []; }
      rows[position.top].push($(this));
    });
    rows.forEach((row) => {
      let last = row[row.length - 1];
      last.removeClass("with-after");
    });
  }

};
