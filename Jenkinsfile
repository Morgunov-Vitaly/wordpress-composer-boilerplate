pipeline {
  agent {
    docker { image 'composer:2' }
  }

  stages {
    stage('Validate') {
      steps {
        sh 'composer validate --strict'
      }
    }
    stage('Install') {
      steps {
        sh 'composer install --no-interaction --prefer-dist --no-progress'
      }
    }
    stage('Quality') {
      steps {
        sh 'composer run check'
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'reports/junit.xml'
    }
  }
}
