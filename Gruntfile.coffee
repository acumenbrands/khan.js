module.exports = (grunt)->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-es6-module-transpiler');

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffee:
      options:
        join: true
        sourceMap: true
        sourceMapDir: 'tmp/maps/'
        sourceRoot: 'maps'
      compile:
        src: ['src/**/*.coffee']
        dest: 'tmp/khan.js'
        ext: '.js'

    copy:
      source:
        src: 'tmp/khan.src.coffee'
        dest: 'dist/maps/khan.src.coffee'

      map:
        src: 'tmp/maps/khan.js.map'
        dest: 'dist/maps/khan.js.map'

      unuglified:
        src: 'tmp/khan.js'
        dest: 'dist/khan.js'

      uglified:
        src: 'tmp/khan.min.js'
        dest: 'dist/khan.min.js'

    mochaTest:
      unit:
        options:
          reporter: 'spec'
          require: ['coffee-script', './spec/spec_helper.coffee']
        src: ['spec/**/*.coffee']

    uglify:
      build:
        files:
          'tmp/khan.min.js' : ['tmp/khan.js'],

  grunt.registerTask 'test', ['mochaTest:unit']
  grunt.registerTask 'build', ['coffee', 'uglify', 'copy']
