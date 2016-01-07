gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
connect    = require 'gulp-connect'
less       = require 'gulp-less'
minifyCSS  = require 'gulp-minify-css'
minifyHTML = require 'gulp-minify-html'
sourcemaps = require 'gulp-sourcemaps'
uglify     = require 'gulp-uglify'
watch      = require 'gulp-watch'
bowerMain  = require 'main-bower-files'
gulpFilter = require 'gulp-filter'
rename     = require 'gulp-rename'
flatten    = require 'gulp-flatten'

paths =
	scripts: [
		'dev/coffee/*.coffee'
		'dev/coffee/**/*.coffee'
	]
	libraries: [
		'dev/lib/**'
		'dev/local-lib/**'
	]
	styles: [
		'dev/less/*.less'
	]
	templates: [
		'dev/templates/*.html'
		'dev/templates/**/*.html'
	]
	images: [
		'dev/images/**/*.*'
		'dev/images/*.*'
	]
	app: [
		'www/app/*.js'
		'www/css/*.css'
		'www/templates/**/*.html'
		'www/templates/*.html'
		'www/images/*.*'
		'www/images/**/*.*'
		'www/*.html'
	]

gulp.task 'copy-images', ->
	gulp.src(paths.images)
		.pipe gulp.dest('www/images')
	return

gulp.task 'copy-lib', ->

	jsFilter = gulpFilter('*.js', {restore: true})
	cssFilter = gulpFilter('*.css', {restore: true})
	lessFilter = gulpFilter('*.less', {restore: true})
	fontFilter = gulpFilter(['*.eot', '*.woff', '*.woff2', '*.svg', '*.ttf'], {restore: true})
	imageFilter = gulpFilter(['*.gif', '*.png', '*.svg', '*.jpg', '*.jpeg'], {restore: true})

	gulp.src(bowerMain())
		# JS
		.pipe(jsFilter)
		.pipe(uglify())
		.pipe(rename({
				suffix: ".min"
		}))
		#.pipe(concat('lib.min.js'))
		.pipe(gulp.dest('www/lib/js'))
		.pipe(jsFilter.restore)
		# CSS
		.pipe(cssFilter)
		.pipe(minifyCSS())
		.pipe(rename({
				suffix: ".min"
		}))
		.pipe(gulp.dest('www/lib/css'))
		.pipe(cssFilter.restore)
		# LESS
		.pipe(lessFilter)
		.pipe(less().on('error', (err) ->
			console.log err.message
			@emit 'end'
		))
		.pipe(minifyCSS())
		.pipe(rename({
				suffix: ".min"
		}))
		.pipe(gulp.dest('www/lib/css'))
		.pipe(lessFilter.restore)
		# Fonts
		.pipe(fontFilter)
		.pipe(flatten())
		.pipe(gulp.dest('www/lib/fonts'))
		.pipe(fontFilter.restore)
		# Images
		.pipe(imageFilter)
		.pipe(flatten())
		.pipe(gulp.dest('www/lib/images'))
		.pipe(imageFilter.restore)


gulp.task 'compile-coffee', ->
	gulp.src(paths.scripts)
		.pipe(coffee().on('error', (err) ->
			console.log err.message
			@emit 'end'
		))
		.pipe(uglify())
		.pipe(concat('app.min.js'))
		.pipe gulp.dest('www/app')
	return

gulp.task 'less', ->
	return gulp.src('dev/less/app.less')
		.pipe(less().on('error', (err) ->
			console.log err.message
			@emit 'end'
		))
		.pipe(minifyCSS())
		.pipe(concat('style.min.css'))
		.pipe(gulp.dest('www/css'))

gulp.task 'templates', ->
	gulp.src(paths.templates).pipe(minifyHTML()).pipe gulp.dest('www/templates')
	return

gulp.task 'index', ->
	gulp.src('dev/index.html')
		.pipe(minifyHTML())
		.pipe gulp.dest('www')
	return

gulp.task 'connect', ->
	connect.server
		root: 'www'
		livereload: true
	return

gulp.task 'refresh', ->
	gulp.src(paths.app)
		.pipe connect.reload()
	return

###*
# Watch files
###
gulp.task 'watch', ->
	gulp.watch [ paths.scripts ], [ 'compile-coffee' ]
	gulp.watch [ paths.styles ], [ 'less' ]
	gulp.watch [ paths.templates ], [ 'templates' ]
	gulp.watch [ 'dev/index.html' ], [ 'index' ]
	gulp.watch [ paths.images ], [ 'copy-images' ]
	gulp.watch [ paths.app ], [ 'refresh' ]
	return

gulp.task 'default', [
	'copy-lib'
	'copy-images'
	'compile-coffee'
	'less'
	'templates'
	'index'
	'connect'
	'watch'
]
