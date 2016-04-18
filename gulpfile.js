var gulp = require('gulp');
var babel = require('gulp-babel');
var compress = require('gulp-yuicompressor');
var concat = require('gulp-concat');
var es = require('event-stream');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');

//variables to set source and destination paths
var destination = 'app/assets/dist';
var source = 'app/assets/src';

//using sass and yui compressor
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

//using babel and yui compressor
//this will concatenate, minify and add es6 js features to all files in source
gulp.task('babel', function () {
  return gulp.src(source + '/**/*.js')
    .pipe(sourcemaps.init())
    .pipe(concat('app.min.js'))
    .pipe(babel({presets: ['es2015'] }))
    .pipe(compress({type: 'js'}))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(destination + '/js'));
});

// monitor files for changes
gulp.task('watch', function() {
    gulp.watch(source + '/**/*.{css,scss,sass}', ['css']);
    gulp.watch(source + '/**/*.js', ['babel']);
});

// Default Task
gulp.task('default', ['css', 'babel', 'watch']);
