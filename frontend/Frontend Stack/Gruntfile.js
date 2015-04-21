/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    //Setting up slim
    slim: {
      dist: {
        options: {                       // Target options
        pretty: true
      },
        files: [{
          expand: true,
          cwd: 'slim',
          src: ['{,*/}*.slim'],
          dest: 'www',
          ext: '.html'
        }]
      }
    },
    compass: {
      dist: {
        options: {
          config: 'config.rb'
        }
      }
    },

    watch: {
      //Watching all the .slim files in the project
      slimfiles: {
      files: '{,*/}*.slim',
      tasks:['slim']
      },
      scssfiles: {
        files: '{,*/}*.scss',
        tasks:['compass']
      },
      /*csspostprocess: {
				files: 'www/css/*.css',
				tasks: ['autoprefixer'],
			},*/
      livereload: {
      // Here we watch the files the sass task will compile to
      // These files are sent to the live reload server after sass compiles to them
      options: { livereload: true },
      files: ['www/**/*'],
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-slim');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-autoprefixer');

  // Default task.
  grunt.registerTask('default', ['watch']);



};
