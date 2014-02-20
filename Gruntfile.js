module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-jasmine-node');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      options: {
        join: true,
        sourceMap: true,
        sourceMapDir: 'tmp/maps'
      },
      compile: {
        src: ['src/**/*.coffee'],
        dest: 'tmp/khan.js',
        ext: '.js'
      }
    },

    copy: {
      sourcemap: {
        src: 'tmp/khan.src.coffee',
        dest: 'dist/maps/khan.src.coffee'
      },
      map: {
        src: 'tmp/mapskhan.js.map',
        dest: 'dist/maps/mapskhan.js.map'
      }
    },

    jasmine_node: {
      specNameMatcher: "Spec",
      useCoffee: true,
      extensions: 'coffee',
    },

    uglify: {
      build: {
        sourceMap: true,
        sourceMapIn: 'tmp/maps/mapskhan.js.map',
        files: {
          'dist/khan.min.js' : ['tmp/khan.js'],
        }
      }
    }

  });

  grunt.registerTask('test', ['jasmine_node']);
  grunt.registerTask('build', ['coffee','uglify', 'copy']);
};
