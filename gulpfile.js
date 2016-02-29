var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

var exec = require('child_process').exec;

var browserSync = require("browser-sync").create();

var postcss = require("gulp-postcss");
var autoprefixer = require("autoprefixer");
var cssnext = require("postcss-cssnext");
var precss = require("precss");
var each = require("postcss-each");

var browserify = require('browserify');
var babelify = require('babelify');
var source = require('vinyl-source-stream');

// Compiles the SASS files and moves them into the "assets/stylesheets" directory
gulp.task("styles", function () {

  var processors = [
    autoprefixer({browsers: ["last 1 version"]}),
    cssnext,
    each,
    precss
  ];

  return gulp.src("stylesheets/main.scss")
    .pipe(postcss(processors)).on("error", errorHandler)
    .pipe($.concat('main.css'))
    .pipe(gulp.dest("output/css"))
    .pipe($.size({title: "styles"}))
    .pipe(browserSync.reload({stream: true}));
});

gulp.task("images", function () {
  return gulp.src("images/**/*")
    .pipe(gulp.dest("output/img"))
    .pipe(browserSync.reload({stream: true}));
});

gulp.task("scripts", function () {
  return browserify({entries: './scripts/main.js', debug: true})
    .transform(babelify, {"presets": ["es2015"]})
    .bundle()
    .pipe(source('main.js'))
    .pipe(gulp.dest('output/js'));
});

gulp.task("server", function() {
  browserSync.init({
    notify: true,
    port: 4000,
    server: {
      baseDir: "output"
    },
    browser: "google chrome"
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

gulp.task("watch:images", ['images'], function() {
  gulp.watch([
    "images/**/*"
  ], ["images"]);
});

gulp.task("watch:styles", ['styles'], function() {
  gulp.watch([
    "stylesheets/**/*"
  ], ["styles"]);
});

gulp.task("watch:scripts", ['scripts'], function() {
  gulp.watch([
    "scripts/**/*"
  ], ["scripts"]);
});

gulp.task("watch", ["watch:html", "watch:styles", "watch:scripts", "watch:images"]);

gulp.task('html', function(cb) {
  exec("bundle exec nanoc compile", {maxBuffer: 1024 * 1000}, function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
    browserSync.reload();
    cb(err);
  });
});

gulp.task("serve", ["server", "watch"], function() {
  $.util.log($.util.colors.green('*** When you want to stop the server, type `control - c` ***'));
});

gulp.task('build', ['html', 'styles', 'scripts', 'images']);

gulp.task('default', ['build', 'serve']);

// Handle the error
function errorHandler (error) {
  console.log(error.toString());
  this.emit("end");
}
