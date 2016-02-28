var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

var exec = require('child_process').exec;

var browserSync = require("browser-sync").create();

var postcss = require("gulp-postcss");
var autoprefixer = require("autoprefixer");
var cssnext = require("postcss-cssnext");
var precss = require("precss");
var each = require("postcss-each");

// Compiles the SASS files and moves them into the "assets/stylesheets" directory
gulp.task("styles", function () {
  // Looks at the style.scss file for what to include and creates a style.css file

  var processors = [
    autoprefixer({browsers: ["last 1 version"]}),
    cssnext,
    each,
    precss
  ];

  return gulp.src("stylesheets/main.scss")
    .pipe(postcss(processors)).on("error", errorHandler)
    .pipe($.concat('main.css'))
    // AutoPrefix your CSS so it works between browsers
    .pipe(gulp.dest("output/css"))
    // Outputs the size of the CSS file
    .pipe($.size({title: "styles"}))
    // Injects the CSS changes to your browser since Jekyll doesn"t rebuild the CSS
    .pipe(browserSync.reload({stream: true}));
});

gulp.task("server", function() {
  browserSync.init({
    notify: true,
    port: 4000,
    server: {
      baseDir: "output"
    }
  });
});

gulp.task("watch:html", ['html'], function() {
  gulp.watch([
    "nanoc.yaml",
    "Rules",
    "data/**/*",
    "content/**/*",
    "layouts/**/*",
    "lib/**/*"
  ], ["html"]);
});

gulp.task("watch:styles", ['styles'], function() {
  gulp.watch([
    "stylesheets/**/*"
  ], ["styles"]);
});

gulp.task("watch", ["watch:html", "watch:styles"]);

gulp.task('html', function(cb) {
  exec("bundle exec nanoc compile", {maxBuffer: 1024 * 1000}, function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
    cb(err);
  });
});

gulp.task("serve", ["server", "watch"], function() {
  $.util.log($.util.colors.green('*** When you want to stop the server, type `control - c` ***'));
});

gulp.task('build', ['html', 'styles']);

gulp.task('default', ['watch']);

// Handle the error
function errorHandler (error) {
  console.log(error.toString());
  this.emit("end");
}
