var gulp = require('gulp');
var babel = require('gulp-babel');
var compress = require('gulp-yuicompressor');
var concat = require('gulp-concat');
var es = require('event-stream');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var babelify = require('babelify');
var browserify = require('browserify');
var fs = require('fs');
var uglify = require('gulp-uglify');

//variables to set destination, source and node_module paths
var destination = 'app/assets/dist';
var source = 'app/assets/src';
var node_modules = 'node_modules/bootstrap/dist';

//using sass and yui compressor
//using event-stream to create in-memory piece of data
//this will compile, concatenate, minify all files in source
gulp.task('css', function () {
  var compiledCSS =  gulp.src(source + '/**/*.{scss,sass}')
    .pipe(sass().on('error', sass.logError))
  var css = gulp.src(source + '/**/*.css')

  return es.merge(compiledCSS,css)
    .pipe(sourcemaps.init())
    .pipe(concat('app.min.css'))
    .pipe(compress({type: 'css'}))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(destination + '/css'));
});

//using babel and gulp-uglify
//this will concatenate, minify and add es6 js features to all files in source
gulp.task('babel', function () {
  return gulp.src([source + '/**/*.js', node_modules + '/js/bootstrap.min.js'])
    .pipe(sourcemaps.init())
    .pipe(concat('app.min.js'))
    .pipe(babel({presets: ['es2015', 'react']}))
    .pipe(uglify())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(destination + '/js'));
});

//using browserfiy and babelify
//using fs to create bundle.js
gulp.task('babelify', function () {
  return browserify({
      entries: [source + '/js'], //using source + '/js/*.js' creates events.js:154 throw er; //Unhandled 'error' event: Cannot find module
      extensions: ['.js'],
      debug: true})
    .transform("babelify", {presets: ["es2015", "react"]})
    .bundle()
    .pipe(fs.createWriteStream(destination + '/js/bundle.js'))
}); 


// monitor files for changes
gulp.task('watch', function() {
    gulp.watch(source + '/**/*.{css,scss,sass}', ['css']);
    gulp.watch(source + '/**/*.js', ['babel', 'babelify']);
});

// Default Task
gulp.task('default', ['css', 'babel', 'babelify', 'watch']);
