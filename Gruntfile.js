module.exports = function(grunt) {

	grunt.initConfig({
		pkg: grunt.file.readJSON("package.json"),
		watch: {
			asm: {
				files: "src/**/*.s",
				tasks: ["build"]
			}
		},
		shell: {
			options: {
				stderr: false
			},
			asm: {
				command: [
					"ca65 -t nes src/main.s -o obj/main.o",
					"ld65 -t nes obj/main.o -o rom.nes"
				].join("&&")
			},
			clean: {
				command:
				[
					"rm obj/main.o",
					"rm rom.nes"

				].join("&&"),
				options: {
					failOnError: false
				}
			}
		}
	});
	grunt.loadNpmTasks("grunt-contrib-watch");
	grunt.loadNpmTasks("grunt-shell");
	grunt.registerTask("default", ["build", "watch"]);

	grunt.registerTask("clean", ["shell:clean"]);
	grunt.registerTask("build", ["clean", "shell:asm"]);

}
