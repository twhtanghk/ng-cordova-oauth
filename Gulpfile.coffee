pkg = require './package.json'
gulp = require 'gulp'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
header = require 'gulp-header'
jshint = require 'gulp-jshint'
clean = require 'gulp-clean'
rename = require 'gulp-rename'
browserify = require 'browserify'
source = require 'vinyl-source-stream'

gulp.task 'default', ['uglify']

gulp.task 'concat', ['browserify'], ->
	gulp.src 'src/*.js'
		.pipe concat("#{pkg.name}.js")
		.pipe gulp.dest('dist')

gulp.task 'uglify', ['concat'], ->
	today = new Date()
	banner = "// #{pkg.name} - v#{pkg.version} (#{today})\n' + '// http://www.nraboy.com\n"
	gulp.src "dist/#{pkg.name}.js"
		.pipe uglify()
		.pipe header(banner)
		.pipe rename(extname: '.min.js')
		.pipe gulp.dest('dist')

gulp.task 'jshint', ['browserify'], ->
	gulp.src 'src/*.js'
		.pipe jshint() 
	
gulp.task 'clean', ->
	gulp.src 'dist/*.min.js'
		.pipe clean()

gulp.task 'browserify', ->
	browserify(entries: ['src/platform.coffee'])
	  	.transform('coffeeify')
	    .bundle()
	    .pipe(source('platform.js'))
	    .pipe(gulp.dest('src'))