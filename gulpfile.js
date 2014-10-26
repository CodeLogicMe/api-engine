var gulp = require('gulp');
var coffee = require('gulp-coffee');
var gutil = require('gulp-util');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var del = require('del');

var paths = {
  scripts: [
    'frontend/assets/javascripts/*.coffee'
  ]
};

gulp.task('clean', function(cb){
  del(['./frontend/public/app,js'], cb);
});

gulp.task('scripts', ['clean'], function() {
  // Minify and copy all JavaScript (except vendor scripts)
  // with sourcemaps all the way down
  return gulp.src(paths.scripts)
    .pipe(sourcemaps.init())
      .pipe(coffee())
      .pipe(uglify())
      .pipe(concat('all.min.js'))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('build/js'));
});

gulp.task('watch-js', function() {
  gulp.src('./frontend/assets/javascripts/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./frontend/public/'));
    // .pipe(gulp.dest('build/minified_templates'));
});
