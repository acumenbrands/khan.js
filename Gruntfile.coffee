module.exports = (grunt)->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-mocha-test')

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffee:
      options:
        join: true
        sourceMap: true
        sourceMapDir: 'tmp/maps'
      compile:
        src: ['src/**/*.coffee']
        dest: 'dist/khan.js'
        ext: '.js'

    copy:
      sourcemap:
        src: 'tmp/khan.src.coffee'
        dest: 'dist/maps/khan.src.coffee'

      map:
        src: 'tmp/mapskhan.js.map'
        dest: 'dist/maps/mapskhan.js.map'

    mochaTest:
      unit:
        options:
          reporter: 'spec'
          require: ['coffee-script', './spec/spec_helper.coffee']
        src: ['spec/**/*.coffee']

    uglify:
      build:
        sourceMap: true
        sourceMapIn: 'tmp/maps/mapskhan.js.map'
        files:
          'dist/khan.min.js' : ['dist/khan.js'],

  grunt.registerTask 'test', ['mochaTest:unit']
  grunt.registerTask 'build', ['coffee','uglify', 'copy']
