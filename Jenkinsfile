pipeline {
    agent any

    environment {
        APP_NAME        = 'meu-app'
        GITHUB_REPO     = 'https://github.com/SEU_USUARIO/SEU_REPO.git'
        DOCKER_IMAGE    = "${APP_NAME}:${BUILD_NUMBER}"
        SONAR_PROJECT   = "${APP_NAME}"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
    }

    triggers {
        // Disparado pelo webhook do GitHub
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Clonando repositório..."
                checkout scm
                script {
                    env.GIT_COMMIT_MSG = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()
                    env.GIT_AUTHOR = sh(
                        script: 'git log -1 --pretty=%an',
                        returnStdout: true
                    ).trim()
                    echo "Commit: ${env.GIT_COMMIT_MSG}"
                    echo "Autor:  ${env.GIT_AUTHOR}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "📦 Instalando dependências..."
                sh '''
                    if [ -f package.json ]; then
                        npm ci
                    elif [ -f requirements.txt ]; then
                        pip install -r requirements.txt
                    elif [ -f pom.xml ]; then
                        mvn dependency:resolve -q
                    else
                        echo "Nenhum gerenciador de pacotes reconhecido."
                    fi
                '''
            }
        }

        stage('Lint & Code Quality') {
            steps {
                echo "🔍 Verificando qualidade do código..."
                sh '''
                    if [ -f package.json ]; then
                        npm run lint || true
                    fi
                '''
            }
        }

        stage('Test') {
            steps {
                echo "🧪 Executando testes..."
                sh '''
                    if [ -f package.json ]; then
                        npm test -- --ci --coverage || true
                    elif [ -f pom.xml ]; then
                        mvn test -q
                    elif [ -f requirements.txt ]; then
                        pytest --junitxml=test-results.xml || true
                    fi
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/test-results.xml, **/surefire-reports/*.xml'
                }
            }
        }

        stage('Build') {
            steps {
                echo "🔨 Fazendo build da aplicação..."
                sh '''
                    if [ -f package.json ]; then
                        npm run build
                    elif [ -f pom.xml ]; then
                        mvn package -DskipTests -q
                    fi
                '''
            }
        }

        stage('Docker Build') {
            when {
                expression { fileExists('Dockerfile') }
            }
            steps {
                echo "🐳 Construindo imagem Docker..."
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Deploy - Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo "🚀 Deploy para Staging..."
                sh './scripts/deploy.sh staging'
            }
        }

        stage('Deploy - Production') {
            when {
                branch 'main'
            }
            steps {
                input message: '⚠️ Confirmar deploy em Produção?', ok: 'Deploy!'
                echo "🚀 Deploy para Produção..."
                sh './scripts/deploy.sh production'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline concluída com sucesso!"
            githubNotify(
                status: 'SUCCESS',
                description: 'Build passou!',
                context: 'ci/jenkins'
            )
        }
        failure {
            echo "❌ Pipeline falhou."
            githubNotify(
                status: 'FAILURE',
                description: 'Build falhou.',
                context: 'ci/jenkins'
            )
            // emailext(
            //     subject: "FALHA: ${currentBuild.fullDisplayName}",
            //     body: "Pipeline falhou. Verifique: ${env.BUILD_URL}",
            //     to: 'time@empresa.com'
            // )
        }
        always {
            cleanWs()
        }
    }
}
