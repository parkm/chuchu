module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        coffee: {
            src: {
                options: {
                    bare: true
                },
                expand: true,
                flatten: true,
                cwd: 'src/',
                src: ['*.coffee'],
                dest: 'src/js/',
                ext: '.js'
            },
            tests: {
                options: {
                    bare: true
                },
                expand: true,
                flatten: true,
                cwd: 'test/',
                src: ['*.coffee'],
                dest: 'test/js/',
                ext: '.js'
            }
        },
        watch: {
            scripts: {
                files: ['**/*.coffee'],
                tasks: ['coffee']
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
};
