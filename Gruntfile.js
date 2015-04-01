module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        coffee: {
            compile: {
                options: {
                    bare: true
                },
                files: {
                    'src/js/game.js': 'src/game.coffee',
                    'src/js/main.js': 'src/main.coffee',
                    'test/js/tests.js': 'test/tests.coffee'
                }
            }
        },

        watch: {
            scripts: {
                files: [
                    'src/game.coffee',
                    'src/main.coffee',
                    'test/tests.coffee'
                ],
                tasks: ['coffee']
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
};
