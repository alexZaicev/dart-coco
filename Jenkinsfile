pipeline {
	agent any
	stages {
		stage('Pre-Build Setup') {
			steps {
				sh """
				    #!/bin/bash -xe
				    git clean -fdx;
				    $DART_HOME/bin/pub get;
				 """
			}
		}
    stage('Tests') {
			steps {
				sh """
				    $DART_HOME/bin/pub run test
				"""
			}
		}
	}
}
